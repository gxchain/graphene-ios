//
//  BaseOperation.h
//  Graphene
//
//  Created by David Lan on 2018/3/8.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXSerializeDelegate.h"
#import "GXAssetAmount.h"

@interface GXBaseOperation : NSObject<GXSerializeDelegate>
@property (nonatomic,strong) GXAssetAmount* fee;
@property(nonatomic,readonly) int32_t operation_id;
@property(nonatomic,readonly) NSArray* operation;
@end
