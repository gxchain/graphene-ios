//
//  PrivateKey.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "PrivateKey.h"
#import "BTCBigNumber.h"

static int BTCRegenerateKey(EC_KEY *eckey, BIGNUM *priv_key);
static void * ecies_key_derivation(const void *input, size_t ilen, void *output, size_t *olen);
static int ECDSA_SIG_recover_key_GFp(EC_KEY *eckey, ECDSA_SIG *ecsig, const unsigned char *msg, int msglen, int recid, int check);

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
    BIGNUM *bignum = BN_bin2bn(instance.privateKeyData.bytes, (int)instance.privateKeyData.length, BN_new());
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
    NSData* pubkeyData=[self publicKeyWithCompression:YES];
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

-(NSData*)sign:(NSData*)data{
    NSData* sig=[self compactSignatureForHash:BTCSHA256(data)];
    return sig;
}

- (NSData*) compactSignatureForHash:(NSData*)hash {
    NSData* my_pub_key = [self publicKeyWithCompression:YES]; // just for good measure

    while( true )
    {
        NSMutableData* sigdata = [NSMutableData dataWithLength:65];
        unsigned char* sigbytes = sigdata.mutableBytes;
        const unsigned char* hashbytes = hash.bytes;
        int hashlength = (int)hash.length;
        unsigned char *p64 = (sigbytes + 1); // first byte is reserved for header.
        
        ECDSA_SIG *sig = ECDSA_do_sign(hashbytes, hashlength, self._key);
        
        if (sig==NULL) {
            return nil;
        }
        memset(p64, 0, 64);
        
        int nBitsR = BN_num_bits(sig->r);
        int nBitsS = BN_num_bits(sig->s);
        if (nBitsR <= 256 && nBitsS <= 256)
        {
            int nRecId = -1;
            EC_KEY* key = EC_KEY_new_by_curve_name( NID_secp256k1 );
            NSAssert( key,@"Null key should not happen");
            EC_KEY_set_conv_form( key, POINT_CONVERSION_COMPRESSED );
            for (int i=0; i<4; i++)
            {
                if (ECDSA_SIG_recover_key_GFp(key, sig, hashbytes, hashlength, i, 1) == 1) {
                    PublicKey* _pubkey=[PublicKey new];
                    _pubkey._key=key;
                    NSData* key_data=[_pubkey publicKeyWithCompression:YES];
                    if ( [key_data isEqual:my_pub_key] )
                    {
                        nRecId = i;
                        break;
                    }
                }
            }
            EC_KEY_free( key );
            
            if (nRecId == -1)
            {
                [[NSException exceptionWithName:@"unable to construct recoverable key" reason:@"" userInfo:nil] raise];
            }
            unsigned char* result = NULL;
            i2d_ECDSA_SIG( sig, &result );
            int lenR = result[3];
            int lenS = result[5+lenR];
            if( lenR != 32 ) { free(result); continue; }
            if( lenS != 32 ) { free(result); continue; }
            memcpy( &sigbytes[1], &result[4], lenR );
            memcpy( &sigbytes[33], &result[6+lenR], lenS );
            free(result);
            sigbytes[0] = nRecId+27+4;//(fCompressedPubKey ? 4 : 0);
        }
        return sigdata;
    } // while true
}

- (NSMutableData*) publicKeyWithCompression:(BOOL)compression {
    if (!self._key) return nil;
    EC_KEY_set_conv_form(self._key, compression ? POINT_CONVERSION_COMPRESSED : POINT_CONVERSION_UNCOMPRESSED);
    int length = i2o_ECPublicKey(self._key, NULL);
    if (!length) return nil;
    NSAssert(length <= 65, @"Pubkey length must be up to 65 bytes.");
    NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
    unsigned char* bytes = [data mutableBytes];
    if (i2o_ECPublicKey(self._key, &bytes) != length) return nil;
    return data;
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

// Perform ECDSA key recovery (see SEC1 4.1.6) for curves over (mod p)-fields
// recid selects which key is recovered
// if check is non-zero, additional checks are performed
static int ECDSA_SIG_recover_key_GFp(EC_KEY *eckey, ECDSA_SIG *ecsig, const unsigned char *msg, int msglen, int recid, int check) {
    if (!eckey) return 0;
    
    int ret = 0;
    BN_CTX *ctx = NULL;
    
    BIGNUM *x = NULL;
    BIGNUM *e = NULL;
    BIGNUM *order = NULL;
    BIGNUM *sor = NULL;
    BIGNUM *eor = NULL;
    BIGNUM *field = NULL;
    EC_POINT *R = NULL;
    EC_POINT *O = NULL;
    EC_POINT *Q = NULL;
    BIGNUM *rr = NULL;
    BIGNUM *zero = NULL;
    int n = 0;
    int i = recid / 2;
    
    const EC_GROUP *group = EC_KEY_get0_group(eckey);
    if ((ctx = BN_CTX_new()) == NULL) { ret = -1; goto err; }
    BN_CTX_start(ctx);
    order = BN_CTX_get(ctx);
    if (!EC_GROUP_get_order(group, order, ctx)) { ret = -2; goto err; }
    x = BN_CTX_get(ctx);
    if (!BN_copy(x, order)) { ret=-1; goto err; }
    if (!BN_mul_word(x, i)) { ret=-1; goto err; }
    if (!BN_add(x, x, ecsig->r)) { ret=-1; goto err; }
    field = BN_CTX_get(ctx);
    if (!EC_GROUP_get_curve_GFp(group, field, NULL, NULL, ctx)) { ret=-2; goto err; }
    if (BN_cmp(x, field) >= 0) { ret=0; goto err; }
    if ((R = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    if (!EC_POINT_set_compressed_coordinates_GFp(group, R, x, recid % 2, ctx)) { ret=0; goto err; }
    if (check) {
        if ((O = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
        if (!EC_POINT_mul(group, O, NULL, R, order, ctx)) { ret=-2; goto err; }
        if (!EC_POINT_is_at_infinity(group, O)) { ret = 0; goto err; }
    }
    if ((Q = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    n = EC_GROUP_get_degree(group);
    e = BN_CTX_get(ctx);
    if (!BN_bin2bn(msg, msglen, e)) { ret=-1; goto err; }
    if (8*msglen > n) BN_rshift(e, e, 8-(n & 7));
    zero = BN_CTX_get(ctx);
    if (!BN_zero(zero)) { ret=-1; goto err; }
    if (!BN_mod_sub(e, zero, e, order, ctx)) { ret=-1; goto err; }
    rr = BN_CTX_get(ctx);
    if (!BN_mod_inverse(rr, ecsig->r, order, ctx)) { ret=-1; goto err; }
    sor = BN_CTX_get(ctx);
    if (!BN_mod_mul(sor, ecsig->s, rr, order, ctx)) { ret=-1; goto err; }
    eor = BN_CTX_get(ctx);
    if (!BN_mod_mul(eor, e, rr, order, ctx)) { ret=-1; goto err; }
    if (!EC_POINT_mul(group, Q, eor, R, sor, ctx)) { ret=-2; goto err; }
    if (!EC_KEY_set_public_key(eckey, Q)) { ret=-2; goto err; }
    
    ret = 1;
    
err:
    if (ctx) {
        BN_CTX_end(ctx);
        BN_CTX_free(ctx);
    }
    if (R != NULL) EC_POINT_free(R);
    if (O != NULL) EC_POINT_free(O);
    if (Q != NULL) EC_POINT_free(Q);
    return ret;
}

