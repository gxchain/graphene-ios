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
