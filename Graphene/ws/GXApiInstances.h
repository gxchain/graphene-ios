//
//  GXApiInstances.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXChainWebSocket.h"
#import "GXGrapheneApi.h"

@interface GXApiInstances : NSObject

@property (nonatomic,strong) NSString* chain_id;
@property (nonatomic,strong) GXGrapheneApi* _db;
@property (nonatomic,strong) GXGrapheneApi* _net;
@property (nonatomic,strong) GXGrapheneApi* _hist;
@property (nonatomic,strong) GXGrapheneApi* _crypt;
@property (nonatomic,strong) GXChainWebSocket* ws_rpc;
@property (atomic,assign) NSInteger initCount;

+(instancetype)sharedInstance;
-(void)connect:(NSString*)url timeout:(NSTimeInterval)timeout statusCallback:(void(^)(BOOL connected,NSString* status))callback;
-(void)close;
@end
