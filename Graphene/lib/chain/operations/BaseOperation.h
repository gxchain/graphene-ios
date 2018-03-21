//
//  BaseOperation.h
//  Graphene
//
//  Created by David Lan on 2018/3/8.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializeDelegate.h"
#import "AssetAmount.h"

@interface BaseOperation : NSObject<SerializeDelegate>
@property (nonatomic,strong) AssetAmount* fee;
@property(nonatomic,readonly) int32_t operation_id;
@property(nonatomic,readonly) NSArray* operation;
@end
