//
//  PublicKey.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "PublicKey.h"
#import "ChainConfig.h"


@interface PublicKey()

@end

@implementation PublicKey
+(instancetype)fromString:(NSString*)pubKeyString{
    NSString* prefix = [pubKeyString substringToIndex:[ADDRESS_PREFIX length]];
    NSAssert([prefix isEqualToString:ADDRESS_PREFIX], @"Expecting key to begin with $%@, instead got %@",ADDRESS_PREFIX,prefix);
    NSMutableData* pubKeyData = BTCDataFromBase58CheckRIPEMD160([pubKeyString substringFromIndex:[prefix length]]);
    return [PublicKey fromData:pubKeyData];
}

+(instancetype)fromData:(NSData*)pubKeyData{
    PublicKey* instance = [[PublicKey alloc]init];
    NSAssert(pubKeyData!=nil, @"Invalid public key, checksum did not match");
    const unsigned char* bytes = pubKeyData.bytes;
    EC_KEY* _key =EC_KEY_new_by_curve_name(NID_secp256k1);
    o2i_ECPublicKey(&_key, &bytes, pubKeyData.length);
    instance._key=_key;
    instance.publicKeyData = pubKeyData;
    
    return instance;
    
}

-(NSString*)toString{
    return [NSString stringWithFormat:@"%@%@",ADDRESS_PREFIX,BTCBase58CheckStringWithDataRIPEMD160([self publicKeyWithCompression:YES])];
}

-(NSData*) publicKeyWithCompression:(BOOL)compression{
    if(!self._key){
        return nil;
    }
    EC_KEY_set_conv_form(self._key, compression ? POINT_CONVERSION_COMPRESSED : POINT_CONVERSION_UNCOMPRESSED);
    int length = i2o_ECPublicKey(self._key, NULL);
    if (!length) return nil;
    NSAssert(length <= 65, @"Pubkey length must be up to 65 bytes.");
    NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
    unsigned char* bytes = [data mutableBytes];
    if (i2o_ECPublicKey(self._key, &bytes) != length) return nil;
    return data;
}

- (BTCCurvePoint*) curvePoint {
    const EC_POINT* ecpoint = EC_KEY_get0_public_key(self._key);
    BTCCurvePoint* cp = [[BTCCurvePoint alloc] initWithEC_POINT:ecpoint];
    return cp;
}
@end

