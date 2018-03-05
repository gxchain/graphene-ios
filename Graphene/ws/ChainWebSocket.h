//
//  ChainWebSocket.h
//  Graphene
//
//  Created by David Lan on 2018/2/25.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChainWebSocket : NSObject
-(instancetype)initWithAddress:(NSString*)address;
-(void)connect:(void(^)(BOOL connected,NSString* status))callback timeout:(NSTimeInterval)timeout;
-(void)call:(NSArray*)params callback:(void (^)(NSError * error, id response))callback;
-(void)close;
-(void)login:(NSString*)user password:(NSString*)password callback:(void (^)(NSError * error, id response))callback;
@end
