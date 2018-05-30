//
//  TransactionBuilder.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "TransactionBuilder.h"
#import "NSArray+Expand.h"
#import "NSDictionary+Expand.h"
#import "ChainConfig.h"
#import "NSMutableData+ProtoBuff.h"

@interface TransactionBuilder()
@property(nonatomic,strong) NSMutableArray<PrivateKey*>* signer_private_keys;
@end

@implementation TransactionBuilder
-(instancetype)initWithOperations:(NSArray<BaseOperation*>*)operations{
    self = [self init];
    self.operations=operations;
    self.signer_private_keys=[NSMutableArray array];
    return self;
}

-(void)add_signer:(PrivateKey*)private_key{
    [self.signer_private_keys addObject:private_key];
}

-(void)sign{
    NSString* chain_id = [[ApiInstances sharedInstance] chain_id];
    if(chain_id == nil){
        chain_id = DEFAULT_CHAIN_ID;
    }
    NSMutableData* data=[NSMutableData data];
    [data appendData:BTCDataFromHex(chain_id)];
    [data appendData:[self serialize]];
    NSLog(@"%@",BTCHexFromData(data));
    NSMutableArray* signatures = [NSMutableArray array];
    [_signer_private_keys enumerateObjectsUsingBlock:^(PrivateKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData* signature=[obj sign:data];
        [signatures addObject:signature];
    }];
    self.signatures=signatures;
}

-(void)setRequiredFees:(void(^)(void))callback{
    NSMutableArray* operations = [NSMutableArray array];
    NSString* asset_id = [(BaseOperation*)[self.operations objectAtIndex:0] fee].asset_id;
    
    [self.operations enumerateObjectsUsingBlock:^(BaseOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [operations addObject:[obj operation]];
    }];
    [[ApiInstances sharedInstance]._db exec:@"get_required_fees" params:@[operations,asset_id] callback:^(NSError *err, id resp) {
        __block int index=0;
        [self.operations enumerateObjectsUsingBlock:^(BaseOperation * _Nonnull op, NSUInteger idx, BOOL * _Nonnull stop) {
            [self setFee:resp[index++] forOperation:op];
            SEL sel_proposed_ops = NSSelectorFromString(@"proposed_ops");
            if([op respondsToSelector:sel_proposed_ops]){
                NSArray* proposed_ops = [op performSelector:sel_proposed_ops];
                [proposed_ops enumerateObjectsUsingBlock:^(BaseOperation *  _Nonnull pop, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self setFee:resp[index++] forOperation:pop];
                }];
            }
        }];
        if(callback){
            callback();
        }
    }];
}

-(void)setFee:(NSDictionary*)fee forOperation:(BaseOperation*)op{
    op.fee.amount=[[fee objectForKey:@"amount"] longValue];
    op.fee.asset_id=[fee objectForKey:@"asset_id"];
}

-(void)setBlockHeader:(void(^)(void))callback{
    __block TransactionBuilder* _self = self;
    [[ApiInstances sharedInstance]._db exec:@"get_objects" params:@[@[@"2.1.0"]] callback:^(NSError *err, id resp) {
        NSDate* time = [_self dateFromUTCString:[[resp objectAtIndex:0] objectForKey:@"time"]];
        _self.expiration=[time timeIntervalSince1970]+EXPIRE_IN_SECOND;
        _self.ref_block_num = [resp[0][@"head_block_number"] longValue] & 0xFFFF;
        NSData* head_block_id = BTCDataFromHex([[resp objectAtIndex:0] objectForKey:@"head_block_id"]);
        uint32_t ref_block_prefix;
        const size_t length = sizeof(ref_block_prefix);
        Byte byte[length] = {};
        [head_block_id getBytes:byte range:NSMakeRange(4, 4+length)];
        ref_block_prefix = (uint32_t) (((byte[0] & 0xFF))
                       | ((byte[1] & 0xFF)<<8)
                       | ((byte[2] & 0xFF)<<16)
                       | (byte[3] & 0xFF)<<24);
        _self.ref_block_prefix = ref_block_prefix;
        if(callback){
            callback();
        }
    }];
}
-(NSData *)dataWithHexString:(NSString *)hexString {
    const char *chars = [hexString UTF8String];
    int i = 0;
    NSUInteger len = hexString.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

-(NSDate*)dateFromUTCString:(NSString*)dateStr{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setTimeZone:timeZone];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [df dateFromString:dateStr];
}

-(NSString*)utcStringFromDate:(NSDate*)date{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setTimeZone:timeZone];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [df stringFromDate:date];
}

-(void)broadcast:(void(^)(NSError *err,NSDictionary* tx))callback{
    [[ApiInstances sharedInstance]._net exec:@"broadcast_transaction_with_callback" params:@[^(NSError *err, id resp) {
        if(err){
            NSLog(@"%@",err.description);
        }
        callback(err,resp);
    },[self signedTransaction]] callback:^(NSError *err, id resp) {
        NSLog(@"boradcasted:%@",resp);
    }];
}

-(void)processTransaction:(void(^)(NSError *err,NSDictionary* tx))callback broadcast:(BOOL)broadcast{
    if(_signer_private_keys==nil||_signer_private_keys.count==0){
        [[NSException exceptionWithName:@"Process transaction" reason:@"no signer key" userInfo:nil] raise];
    }
    __weak TransactionBuilder* weakSelf = self;
    [self setRequiredFees:^(){
        __strong TransactionBuilder* strongSelf = weakSelf;
        __weak TransactionBuilder* weakSelf = strongSelf;
        [strongSelf setBlockHeader:^(){
            __strong TransactionBuilder* strongSelf = weakSelf;
            if (broadcast) {
                [strongSelf broadcast:callback];
            }
            else{
                callback(nil,[strongSelf signedTransaction]);
            }
        }];
    }];
}


-(NSDictionary*)signedTransaction{
    [self sign];
    NSMutableDictionary* tx=[self dictionaryValue].mutableCopy;
    NSMutableArray* signatures = [NSMutableArray array];
    [self.signatures enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [signatures addObject:BTCHexFromData(obj)];
    }];
    [tx setObject:signatures forKey:@"signatures"];
    return tx;
}

#pragma mark - serialize delegate methods
-(NSData*)serialize{
    NSMutableData* result =  [NSMutableData data];
    [result appendBytes:&_ref_block_num length:sizeof(_ref_block_num)];
    [result appendBytes:&_ref_block_prefix length:sizeof(_ref_block_prefix)];
    [result appendBytes:&_expiration length:sizeof(_expiration)];
    int32_t size = (int32_t)(_operations?_operations.count:0);
    [result writeVarInt32:size];
    if(size>0){
        _operations=[self sortedOperations];
        [_operations enumerateObjectsUsingBlock:^(BaseOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            int32_t op_id = obj.operation_id;
            [result writeVarInt32:op_id];
            [result appendData:[obj serialize]];
        }];
    }
    int32_t size2 = (int32_t)(_extensions?_extensions.count:0);
    [result writeVarInt32:size2];
    if(_extensions){
        [_extensions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj respondsToSelector:NSSelectorFromString(@"serialize")]){
                [result appendData:[obj performSelector:NSSelectorFromString(@"serialize") withObject:nil]]; //No Warning
            }
            else{
                NSLog(@"Unknow extension object,%@", obj);
            }
        }];
    }
    
    return result;
}

-(NSArray*)sortedOperations{
    return [_operations sortedArrayUsingComparator:^NSComparisonResult(BaseOperation*  _Nonnull op1, BaseOperation*  _Nonnull op2) {
        return op1.operation_id-op2.operation_id;
    }];
}

-(NSDictionary *)dictionaryValue{
    NSDate* _exp = [NSDate dateWithTimeIntervalSince1970:_expiration];
    NSMutableDictionary* result=@{
                                  @"ref_block_num":@(_ref_block_num),
                                  @"ref_block_prefix":@(_ref_block_prefix),
                                  @"expiration":[self utcStringFromDate:_exp]
                                  }.mutableCopy;
    NSMutableArray* ops=[NSMutableArray array];
    if(_operations){
        _operations=[self sortedOperations];
        [_operations enumerateObjectsUsingBlock:^(BaseOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [ops addObject:[obj operation]];
        }];
    }
    [result setObject:ops forKey:@"operations"];
    if(!_extensions){
        _extensions=@[];
    }
    NSMutableArray* exts = [NSMutableArray array];
    [_extensions enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:NSSelectorFromString(@"dictionaryValue")]){
            [exts addObject:[obj performSelector:NSSelectorFromString(@"dictionaryValue")]];
        }
        else{
            NSLog(@"Unknow extension object,%@", obj);
        }
    }];
    [result setObject:exts forKey:@"extensions"];
    return result;
}
@end
