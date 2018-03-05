//
//  GrapheneApi.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChainWebSocket.h"

@interface GrapheneApi : NSObject
-(instancetype)initWithName:(NSString*)api_name websocket:(ChainWebSocket*)ws_rpc;
-(void)initialize:(void(^)(NSError* err,id response))callback;
-(void)exec:(NSString*)method params:(NSArray*)params callback:(void(^)(NSError* err,id resp))callback;
@end
