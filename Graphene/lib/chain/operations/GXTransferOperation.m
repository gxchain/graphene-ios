//
//  TransferOperation.m
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GXTransferOperation.h"
#import "BTCData.h"
#import "NSMutableData+ProtoBuff.h"
@interface GXTransferOperation()
@end

@implementation GXTransferOperation

-(int32_t)operation_id{
    return 0;
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
