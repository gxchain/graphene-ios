//
//  TransferOperation.h
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GXBaseOperation.h"
#import "GXAssetAmount.h"
#import "GXMemoData.h"

/*
export const transfer = new Serializer ("transfer",{
    fee: asset,
    from: protocol_id_type ("account"),
    to: protocol_id_type ("account"),
    amount: asset,
    memo: optional (memo_data),
    extensions: set (future_extensions)
});
*/
@interface GXTransferOperation : GXBaseOperation
@property (nonatomic,strong) NSString* from;
@property (nonatomic,strong) NSString* to;
@property (nonatomic,strong) GXAssetAmount* amount;
@property (nonatomic,strong) GXMemoData* memo;
@property (nonatomic,strong) NSArray* extensions;
@end
