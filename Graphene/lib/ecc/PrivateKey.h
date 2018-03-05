//
//  PrivateKey.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrivateKey : NSObject
@property (nonatomic,strong) NSData* privateKeyData;
+(instancetype)fromWif:(NSString*)wifKey;
@end
