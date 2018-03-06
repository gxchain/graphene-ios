//
//  PublicKey.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTCBase58.h"
#import <CommonCrypto/CommonCrypto.h>
#import <openssl/ec.h>
#import <openssl/ecdsa.h>
#import <openssl/evp.h>
#import <openssl/obj_mac.h>
#import <openssl/bn.h>
#import <openssl/rand.h>
#import "BTCCurvePoint.h"

@interface PublicKey : NSObject
@property (nonatomic,assign) EC_KEY* _key;
@property (nonatomic,strong) NSData* publicKeyData;
+(instancetype)fromString:(NSString*)pubKeyString;
+(instancetype)fromData:(NSData*)pubKeyData;
-(NSData*) publicKeyWithCompression:(BOOL)compression;
-(NSString*)toString;
-(BTCCurvePoint*) curvePoint;
@end
