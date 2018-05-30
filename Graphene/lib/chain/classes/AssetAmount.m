//
//  AssetAmount.m
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "AssetAmount.h"
#import "NSMutableData+ProtoBuff.h"

@implementation AssetAmount

-(instancetype)initWithAsset:(NSString*)asset_id amount:(int64_t)amount{
    self=[self init];
    self.asset_id=asset_id;
    self.amount=amount;
    return self;
}

-(NSData *)serialize{
    NSMutableData* result = [NSMutableData data];
    [result appendBytes:&_amount length:sizeof(_amount)];
    NSArray* protocol_ids= [self.asset_id componentsSeparatedByString:@"."];
    if([[protocol_ids objectAtIndex:0] isEqualToString:@"1"]&&[[protocol_ids objectAtIndex:1] isEqualToString:@"3"]){
        int32_t protocol_id = [[protocol_ids objectAtIndex:2] intValue];
        [result writeVarInt32:protocol_id];
    }
    else{
        [[NSException exceptionWithName:@"AssetAmount" reason:@"Serialize fail" userInfo:nil] raise];
    }
    return result;
}

-(NSDictionary *)dictionaryValue{
    return @{
             @"asset_id":_asset_id,
             @"amount":@(_amount)
             };
}
@end
