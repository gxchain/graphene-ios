//
//  GHAES.h
//  Graphene
//
//  Created by David Lan on 2018/3/21.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXPrivateKey.h"
#import "GXPublicKey.h"

@interface GXAES : NSObject
+(instancetype)fromSeed:(NSData*)seed;
+(NSData*)encrypt_with_checksum:(GXPrivateKey*)privKey publicKey:(GXPublicKey*)publicKey nonce:(NSString*)nonce message:(NSString*)message;
+(NSData*)decrypt_with_checksum:(GXPrivateKey*)privKey publicKey:(GXPublicKey*)publicKey nonce:(NSString*)nonce message:(NSString*)message;
@end
