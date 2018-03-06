//
//  PrivateKey.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "PrivateKey.h"
#import <ASKSecp256k1/CKSecp256k1.h>
#import "BTCBigNumber.h"

static int BTCRegenerateKey(EC_KEY *eckey, BIGNUM *priv_key);
static void * ecies_key_derivation(const void *input, size_t ilen, void *output, size_t *olen);

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
    EC_KEY* _key =EC_KEY_new_by_curve_name(NID_secp256k1);
    BIGNUM *bignum = BN_bin2bn(privKeyData.bytes, (int)privKeyData.length, BN_new());
    BTCRegenerateKey(_key, bignum);
    instance._key=_key;
    BN_clear_free(bignum);
    return instance;
}

-(NSString*)toWif{
    const uint8_t version = 0x80;
    NSMutableData* data=[NSMutableData dataWithBytes:&version length:sizeof(uint8_t)];
    [data appendData:self.privateKeyData];
    return BTCBase58CheckStringWithData(data);
}

- (BTCCurvePoint*) curvePoint {
    const EC_POINT* ecpoint = EC_KEY_get0_public_key(self._key);
    BTCCurvePoint* cp = [[BTCCurvePoint alloc] initWithEC_POINT:ecpoint];
    return cp;
}

-(PublicKey*)getPublic{
    NSData* pubkeyData=[CKSecp256k1 generatePublicKeyWithPrivateKey:self.privateKeyData compression:YES];
    return [PublicKey fromData:pubkeyData];
}

-(NSData*)sharedSecret:(PublicKey*)publicKey{
    BTCBigNumber* pk = [[BTCBigNumber alloc] initWithUnsignedBigEndian:self.privateKeyData];
    publicKey= [PublicKey fromData:[publicKey publicKeyWithCompression:NO]];
    BTCCurvePoint* sharedPoint = [publicKey.curvePoint multiply:pk];
    NSMutableData* hash = BTCSHA512(sharedPoint.x.unsignedBigEndian);
    [pk clear];
    [sharedPoint clear];
    return hash;
}

@end

static void * ecies_key_derivation(const void *input, size_t ilen, void *output, size_t *olen)
{
    if (*olen < SHA512_DIGEST_LENGTH) {
        return NULL;
    }
    *olen = SHA512_DIGEST_LENGTH;
    return (void*)SHA512((const unsigned char*)input, ilen, (unsigned char*)output);
}

static int BTCRegenerateKey(EC_KEY *eckey, BIGNUM *priv_key) {
    BN_CTX *ctx = NULL;
    EC_POINT *pub_key = NULL;
    
    if (!eckey) return 0;
    
    const EC_GROUP *group = EC_KEY_get0_group(eckey);
    
    BOOL success = NO;
    if ((ctx = BN_CTX_new())) {
        if ((pub_key = EC_POINT_new(group))) {
            if (EC_POINT_mul(group, pub_key, priv_key, NULL, NULL, ctx)) {
                EC_KEY_set_private_key(eckey, priv_key);
                EC_KEY_set_public_key(eckey, pub_key);
                success = YES;
            }
        }
    }
    
    if (pub_key) EC_POINT_free(pub_key);
    if (ctx) BN_CTX_free(ctx);
    
    return success;
}
