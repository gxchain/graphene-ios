//
//  MemoData.m
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GXMemoData.h"
#import "GXChainConfig.h"
#import "GXPublicKey.h"
#import "GXPrivateKey.h"
#import "BTCData.h"
#import "GXAES.h"
#import "NSMutableData+ProtoBuff.h"

uint64_t unique_nonce_uint64(){
    FILE *fp = fopen("/dev/random", "r");
    if (!fp) {
        perror("randgetter");
        exit(-1);
    }

    uint64_t value = 0;
    int i;
    for (i=0; i<sizeof(value); i++) {
        uint8_t c = fgetc(fp);
        value |= (c << (8 * i));
    }
    fclose(fp);
    return (uint64_t)value & 0xFFFFFFFF;
}

@implementation GXMemoData

+(instancetype)memoWithPrivate:(NSString*)privateKey public:(NSString*)publicKey message:(NSString*)message{
    GXMemoData* memo_data = [[GXMemoData alloc] init];
    GXPrivateKey* privKey = [GXPrivateKey fromWif:privateKey];
    NSString* fromPublic = [[privKey getPublic] toString];
    memo_data.from=fromPublic;
    memo_data.to=publicKey;
    memo_data.nonce=unique_nonce_uint64();
    memo_data.message = [GXAES encrypt_with_checksum:privKey publicKey:[GXPublicKey fromString:publicKey] nonce:[NSString stringWithFormat:@"%llu",memo_data.nonce] message:message];
    return memo_data;
}

-(NSDictionary *)dictionaryValue{
    return @{
             @"from":_from,
             @"to":_to,
             @"nonce":@(_nonce),
             @"message":BTCHexFromData(_message)
             };
}
@end
