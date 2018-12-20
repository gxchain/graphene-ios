//
//  PrivateKey.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTCBase58.h"
#import "BTCData.h"
#import "GXPublicKey.h"
#import <openssl/sha.h>
#import <openssl/ec.h>
#import <openssl/ecdh.h>
#import <openssl/ecdsa.h>
#import <openssl/evp.h>
#import <openssl/obj_mac.h>
#import <openssl/bn.h>
#import <openssl/rand.h>

@interface GXPrivateKey : NSObject
@property (nonatomic,assign) EC_KEY* _key;
@property (nonatomic,strong) NSData* privateKeyData;

+(instancetype)fromWif:(NSString*)wifKey;
-(NSString*)toWif;
-(GXPublicKey*)getPublic;
-(NSData*)sharedSecret:(GXPublicKey*)publicKey;
-(NSData*)sign:(NSData*)data;
@end
