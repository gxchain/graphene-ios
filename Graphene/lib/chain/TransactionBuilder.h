//
//  TransactionBuilder.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseOperation.h"
#import "ConnectionManager.h"
#import "ApiInstances.h"
#import "SerializeDelegate.h"
#import "PrivateKey.h"

@interface TransactionBuilder : NSObject<SerializeDelegate>
@property(nonatomic,assign) uint16_t ref_block_num;
@property(nonatomic,assign) uint32_t ref_block_prefix;
@property(nonatomic,assign) uint32_t expiration;
@property (nonatomic,strong) NSArray<BaseOperation*>* operations;
@property(nonatomic,strong) NSArray* extensions;
@property (nonatomic,strong) NSArray* signatures;

-(instancetype)initWithOperations:(NSArray<BaseOperation*>*)operations;
-(void)processTransaction:(void(^)(NSError *err,NSDictionary* tx))callback broadcast:(BOOL)broadcast;
-(void)add_signer:(PrivateKey*)private_key;
-(NSDictionary*)signedTransaction;
@end
