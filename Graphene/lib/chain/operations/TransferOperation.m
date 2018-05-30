//
//  TransferOperation.m
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "TransferOperation.h"
#import "BTCData.h"
#import "NSMutableData+ProtoBuff.h"
@interface TransferOperation()
@end

@implementation TransferOperation

-(int32_t)operation_id{
    return 0;
}

-(NSData *)serialize{
    NSMutableData* result = [NSMutableData data];
    [result appendData:[self.fee serialize]];
    NSArray* protocol_ids= [_from componentsSeparatedByString:@"."];
    if([[protocol_ids objectAtIndex:0] isEqualToString:@"1"]&&[[protocol_ids objectAtIndex:1] isEqualToString:@"2"]){
        int32_t protocol_id = [[protocol_ids objectAtIndex:2] intValue];
        [result writeVarInt32:protocol_id];
    }
    protocol_ids= [_to componentsSeparatedByString:@"."];
    if([[protocol_ids objectAtIndex:0] isEqualToString:@"1"]&&[[protocol_ids objectAtIndex:1] isEqualToString:@"2"]){
        int32_t protocol_id = [[protocol_ids objectAtIndex:2] intValue];
        [result writeVarInt32:protocol_id];
    }
    [result appendData:[_amount serialize]];
    if (_memo) {
        uint8_t i = 1;
        [result appendBytes:&i length:sizeof(i)];
        [result appendData:[_memo serialize]];
    }
    else{
        uint8_t i = 0;
        [result appendBytes:&i length:sizeof(i)];
    }
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
                                  @"from":_from,
                                  @"to":_to,
                                  @"amount":[_amount dictionaryValue]
                                  }.mutableCopy;
    if(_memo){
        [result setObject:[_memo dictionaryValue] forKey:@"memo"];
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
