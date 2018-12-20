//
//  CallContractOperation.h
//  Graphene
//
//  Created by David Lan on 2018/12/10.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GXBaseOperation.h"

/*
export const call_contract = new Serializer("call_contract", {
    fee: asset,
    account: protocol_id_type ("account"),
    contract_id: protocol_id_type("account"),
    amount:optional (asset),
    method_name: name_type,
    data: bytes(),
    extensions: set (future_extensions)
});
*/
@interface GXCallContractOperation : GXBaseOperation
@property (nonatomic,strong) NSString* account;
@property (nonatomic,strong) NSString* contract_id;
@property (nonatomic,strong) GXAssetAmount* amount;
@property (nonatomic,strong) NSString* method_name;
@property (nonatomic,strong) NSData* data;
@property (nonatomic,strong) NSArray* extensions;
@end
