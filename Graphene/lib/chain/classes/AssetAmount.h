//
//  AssetAmount.h
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializeDelegate.h"

@interface AssetAmount : NSObject<SerializeDelegate>
@property (nonatomic,strong) NSString* asset_id;
@property (nonatomic,assign) int64_t amount;
-(instancetype)initWithAsset:(NSString*)asset_id amount:(int64_t)amount;
@end
