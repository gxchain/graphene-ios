//
//  TransferOperation.h
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "BaseOperation.h"
#import "AssetAmount.h"
#import "MemoData.h"

@interface TransferOperation : BaseOperation
@property (nonatomic,strong) NSString* from;
@property (nonatomic,strong) NSString* to;
@property (nonatomic,strong) AssetAmount* amount;
@property (nonatomic,strong) MemoData* memo;
@property (nonatomic,strong) NSArray* extensions;
@end
