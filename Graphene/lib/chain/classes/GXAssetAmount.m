//
//  AssetAmount.m
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GXAssetAmount.h"
#import "NSMutableData+ProtoBuff.h"

@implementation GXAssetAmount

-(instancetype)initWithAsset:(NSString*)asset_id amount:(int64_t)amount{
    self=[self init];
    self.asset_id=asset_id;
    self.amount=amount;
    return self;
}

-(NSDictionary *)dictionaryValue{
    return @{
             @"asset_id":_asset_id,
             @"amount":@(_amount)
             };
}
@end
