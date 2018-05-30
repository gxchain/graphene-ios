//
//  MemoData.m
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "MemoData.h"
#import "ChainConfig.h"
#import "PublicKey.h"
#import "PrivateKey.h"
#import "BTCData.h"
#import "GHAES.h"
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
    return value;
}

@implementation MemoData

+(instancetype)memoWithPrivate:(NSString*)privateKey public:(NSString*)publicKey message:(NSString*)message{
    MemoData* memo_data = [[MemoData alloc] init];
    PrivateKey* privKey = [PrivateKey fromWif:privateKey];
    NSString* fromPublic = [[privKey getPublic] toString];
    memo_data.from=fromPublic;
    memo_data.to=publicKey;
    memo_data.nonce=unique_nonce_uint64();
    memo_data.message = [GHAES encrypt_with_checksum:privKey publicKey:[PublicKey fromString:publicKey] nonce:[NSString stringWithFormat:@"%llu",memo_data.nonce] message:message];
    return memo_data;
}

-(NSData *)serialize{
    NSMutableData* result = [NSMutableData data];
    if([_from rangeOfString:ADDRESS_PREFIX].location!=0){
        [[NSException exceptionWithName:@"MemoData" reason:@"invalid from key" userInfo:@{@"value":_from}] raise];
    }
    else{
        [result appendData:[[PublicKey fromString:_from] curvePoint].data];
    }
    if([_to rangeOfString:ADDRESS_PREFIX].location!=0){
        [[NSException exceptionWithName:@"MemoData" reason:@"invalid to key" userInfo:@{@"value":_to}] raise];
    }
    else{
        [result appendData:[[PublicKey fromString:_to] curvePoint].data];
    }
    [result appendBytes:&_nonce length:sizeof(_nonce)];
    [result writeVarInt32:(int32_t)(_message.length)];
    [result appendData:_message];
    return result;
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
