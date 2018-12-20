//
//  BaseOperation.m
//  Graphene
//
//  Created by David Lan on 2018/3/8.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GXBaseOperation.h"
#import "GXChainConfig.h"

@implementation GXBaseOperation
-(instancetype)init{
    self=[super init];
    self.fee=[[GXAssetAmount alloc] initWithAsset:GX_DEFAULT_ASSET_ID amount:0];
    return self;
}

-(int32_t)operation_id{
    return -1;
}

-(NSArray*)operation{
    return @[@(self.operation_id),self.dictionaryValue];
}

-(NSData*)serialize{
    return nil;
}

-(NSDictionary*)dictionaryValue{
    return nil;
}
@end
