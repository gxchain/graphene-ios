//
//  GHAES.m
//  Graphene
//
//  Created by David Lan on 2018/3/21.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GHAES.h"
#import "NSData+BTCData.h"
#import "BTCData.h"
@interface GHAES()
@property (nonatomic,strong) NSData* iv;
@property (nonatomic,strong) NSData* key;
@end

@implementation GHAES
+(instancetype)fromSeed:(NSData*)seed{
    GHAES* aes = [[GHAES alloc] init];
    NSData* hashedSeedData =BTCSHA512(seed);
    NSString* hashedSeed = BTCHexFromData(hashedSeedData);
    aes.key=BTCDataFromHex([hashedSeed substringWithRange:NSMakeRange(0, 64)]);
    aes.iv=BTCDataFromHex([hashedSeed substringWithRange:NSMakeRange(64, 32)]);
    return aes;
}

+(NSData*)encrypt_with_checksum:(PrivateKey*)privKey publicKey:(PublicKey*)publicKey nonce:(NSString*)nonce message:(NSString*)message{
    NSData* sharedSecret = [privKey sharedSecret:publicKey];
    NSMutableData* secretWithNonce = [NSMutableData data];
    [secretWithNonce appendData:[nonce dataUsingEncoding:NSUTF8StringEncoding]];
    [secretWithNonce appendData:[BTCHexFromData(sharedSecret) dataUsingEncoding:NSUTF8StringEncoding]];
    GHAES * aes =[GHAES fromSeed:secretWithNonce];
    NSData* checksum = [[[message dataUsingEncoding:NSUTF8StringEncoding] SHA256] subdataWithRange:NSMakeRange(0, 4)];
    NSMutableData* payload = checksum.mutableCopy;
    [payload appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    return [aes encrypt:payload];
}

+(NSData*)decrypt_with_checksum:(PrivateKey*)privKey publicKey:(PublicKey*)publicKey nonce:(NSString*)nonce message:(NSString*)message{
    NSData* sharedSecret = [privKey sharedSecret:publicKey];
    
    NSMutableData* secretWithNonce = [NSMutableData data];
    [secretWithNonce appendData:[nonce dataUsingEncoding:NSUTF8StringEncoding]];
    [secretWithNonce appendData:sharedSecret];
    GHAES * aes =[GHAES fromSeed:secretWithNonce];
    NSData* payload = [aes decrypt:BTCDataFromHex(message)];
    NSData* checksum = [payload subdataWithRange:NSMakeRange(0, 4)];
    NSData* plaintext = [payload subdataWithRange:NSMakeRange(4, payload.length-1)];
    
    NSData* new_checksum = [[[message dataUsingEncoding:NSUTF8StringEncoding] SHA256] subdataWithRange:NSMakeRange(0, 4)];
    
    if(![checksum isEqualToData:new_checksum]){
        [NSException exceptionWithName:@"decrypt_with_checksum" reason:@"fail to decrypt message with checksum" userInfo:nil];
    }
    return plaintext;
}

-(NSData*)encrypt:(NSData*)payload{
    return [NSMutableData encryptData:payload key:self.key iv:self.iv];
}

-(NSData*)decrypt:(NSData*)payload{
    return [NSMutableData decryptData:payload key:self.key iv:self.iv];
}

@end
