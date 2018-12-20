//
//  CallContractOperation.m
//  Graphene
//
//  Created by David Lan on 2018/12/10.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GXCallContractOperation.h"
#import "BTCData.h"
#import "NSMutableData+ProtoBuff.h"
#import "GXUtil.h"

@implementation GXCallContractOperation

-(int32_t)operation_id{
    return 75;
}

-(NSData *)serialize{
    NSMutableData* result = [NSMutableData data];
    // fee
    [result appendData:[self.fee serialize]];
    // account
    NSArray* protocol_ids= [_account componentsSeparatedByString:@"."];
    if([[protocol_ids objectAtIndex:0] isEqualToString:@"1"]&&[[protocol_ids objectAtIndex:1] isEqualToString:@"2"]){
        int32_t protocol_id = [[protocol_ids objectAtIndex:2] intValue];
        [result writeVarInt32:protocol_id];
    }
    // contract_id
    protocol_ids= [_contract_id componentsSeparatedByString:@"."];
    if([[protocol_ids objectAtIndex:0] isEqualToString:@"1"]&&[[protocol_ids objectAtIndex:1] isEqualToString:@"2"]){
        int32_t protocol_id = [[protocol_ids objectAtIndex:2] intValue];
        [result writeVarInt32:protocol_id];
    }
    //optional(amount)
    if(_amount!=nil){
        uint8_t i = 1;
        [result appendBytes:&i length:sizeof(i)];
        [result appendData:[_amount serialize]];
    }
    else{
        uint8_t i = 0;
        [result appendBytes:&i length:sizeof(i)];
    }
    // method
    uint64_t method= [GXUtil string_to_name:_method_name];
    [result appendBytes:&method length:sizeof(method)];
    // data
    [result writeVarInt32:(int32_t)_data.length];
    [result appendData:_data];
    //extensions
    int32_t size = (int32_t)(_extensions?_extensions.count:0);
    [result writeVarInt32:size];
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

-(NSDictionary *)dictionaryValue{
    NSMutableDictionary* result=@{
                                  @"fee":[self.fee dictionaryValue],
                                  @"account":_account,
                                  @"contract_id":_contract_id,
                                  @"method_name":_method_name,
                                  @"data": BTCHexFromData(_data),
                                  }.mutableCopy;
    if(_amount!=nil){
        [result setObject:[_amount dictionaryValue] forKey:@"amount"];
    }
    NSMutableArray* exts=[NSMutableArray array];
    if(_extensions){
        [_extensions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj respondsToSelector:NSSelectorFromString(@"dictionaryValue")]){
                [exts addObject:[obj performSelector:NSSelectorFromString(@"dictionaryValue") withObject:nil]];
            }
            else{
                NSLog(@"Unknow extension object,%@", obj);
            }
        }];
    }
    [result setObject:exts forKey:@"extensions"];
    return result;
}
@end
