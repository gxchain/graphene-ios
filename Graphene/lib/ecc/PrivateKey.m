//
//  PrivateKey.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "PrivateKey.h"
#import "BTCBase58.h"
#import "PublicKey.h"
#include <openssl/ec.h>
#import <openssl/ecdh.h>
#include <openssl/ecdsa.h>
#include <openssl/evp.h>
#include <openssl/obj_mac.h>
#include <openssl/bn.h>
#include <openssl/rand.h>

@interface PrivateKey()
@property (nonatomic,assign) EC_KEY* key;
@end

@implementation PrivateKey
+(instancetype)fromWif:(NSString*)wifKey{
    PrivateKey* instance = [[PrivateKey alloc]init];
    NSMutableData* private_wif = BTCDataFromBase58(wifKey);
    uint8_t version;
    [private_wif getBytes:&version length:sizeof(uint8_t)];
    NSAssert(version==0x80, @"Expected version %d, instead got %d",0x80,version);
    NSMutableData* privKeyData = BTCDataFromBase58Check(wifKey);
    NSAssert(privKeyData!=nil, @"Invalid private key, checksum does not match");
    instance.privateKeyData=[privKeyData subdataWithRange:NSMakeRange(1, [privKeyData length]-1)];
    return instance;
}

//-(NSString*)sharedSecret:(NSString*)publicKey{
//    ECDH_compute_key(<#void *out#>, <#size_t outlen#>, <#const EC_POINT *pub_key#>, <#EC_KEY *ecdh#>, <#void *(*KDF)(const void *, size_t, void *, size_t *)#>)
//    return @"";
//}
@end
