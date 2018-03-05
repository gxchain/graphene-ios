//
//  PublicKey.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicKey : NSObject
@property (nonatomic,strong) NSData* publicKeyData;
+(instancetype)fromString:(NSString*)pubkeyString;
-(NSData*) publicKeyWithCompression:(BOOL)compression;
@end
