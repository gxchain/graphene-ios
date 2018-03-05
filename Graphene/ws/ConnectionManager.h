//
//  ConnectionManager.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionManager : NSObject
+(instancetype)sharedInstance;
-(void)connectWithFallback:(NSArray*)urls callback:(void(^)(BOOL connected,NSString* url))callback;
@end
