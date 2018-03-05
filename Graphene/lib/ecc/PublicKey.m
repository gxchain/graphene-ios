//
//  PublicKey.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "PublicKey.h"
#import "ChainConfig.h"
#import "BTCBase58.h"
#include <CommonCrypto/CommonCrypto.h>
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/evp.h>
#include <openssl/obj_mac.h>
#include <openssl/bn.h>
#include <openssl/rand.h>
#import "BTCCurvePoint.h"

@interface PublicKey()
@property (nonatomic,assign) EC_KEY* key;
@end

@implementation PublicKey
+(instancetype)fromString:(NSString*)pubkeyString{
    PublicKey* instance = [[PublicKey alloc]init];
    NSString* prefix = [pubkeyString substringToIndex:[ADDRESS_PREFIX length]];
    NSAssert([prefix isEqualToString:ADDRESS_PREFIX], @"Expecting key to begin with $%@, instead got %@",ADDRESS_PREFIX,prefix);
    NSMutableData* pubKeyData = BTCDataFromBase58CheckRIPEMD160([pubkeyString substringFromIndex:[prefix length]]);
    NSAssert(pubKeyData!=nil, @"Invalid public key, checksum did not match");
    const unsigned char* bytes = pubKeyData.bytes;
    EC_KEY* _key =EC_KEY_new_by_curve_name(NID_secp256k1);
    o2i_ECPublicKey(&_key, &bytes, pubKeyData.length);
    instance.key=_key;
    instance.publicKeyData = pubKeyData;
    return instance;
}

-(NSData*) publicKeyWithCompression:(BOOL)compression{
    if(!self.key){
        return nil;
    }
    EC_KEY_set_conv_form(self.key, compression ? POINT_CONVERSION_COMPRESSED : POINT_CONVERSION_UNCOMPRESSED);
    int length = i2o_ECPublicKey(self.key, NULL);
    if (!length) return nil;
    NSAssert(length <= 65, @"Pubkey length must be up to 65 bytes.");
    NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
    unsigned char* bytes = [data mutableBytes];
    if (i2o_ECPublicKey(self.key, &bytes) != length) return nil;
    return data;
}
@end

