//
//  GXTransactionBuilder.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXBaseOperation.h"
#import "GXConnectionManager.h"
#import "GXApiInstances.h"
#import "GXSerializeDelegate.h"
#import "GXPrivateKey.h"

@interface GXTransactionBuilder : NSObject<GXSerializeDelegate>
@property(nonatomic,assign) uint16_t ref_block_num;
@property(nonatomic,assign) uint32_t ref_block_prefix;
@property(nonatomic,assign) uint32_t expiration;
@property (nonatomic,strong) NSArray<GXBaseOperation*>* operations;
@property(nonatomic,strong) NSArray* extensions;
@property (nonatomic,strong) NSArray* signatures;

-(instancetype)initWithOperations:(NSArray<GXBaseOperation*>*)operations;
-(void)processTransaction:(void(^)(NSError *err,NSDictionary* tx))callback broadcast:(BOOL)broadcast;
-(void)add_signer:(GXPrivateKey*)private_key;
-(NSDictionary*)signedTransaction;
@end
