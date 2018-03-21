//
//  MemoData.h
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializeDelegate.h"

@interface MemoData : NSObject<SerializeDelegate>
@property(nonatomic,strong) NSString* from;
@property(nonatomic,strong) NSString* to;
@property(nonatomic,assign) uint64_t nonce;
@property(nonatomic,strong) NSData* message;
+(instancetype)memoWithPrivate:(NSString*)privateKey public:(NSString*)publicKey message:(NSString*)message;
@end
