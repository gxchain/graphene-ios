//
//  ApiInstances.h
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChainWebSocket.h"
#import "GrapheneApi.h"

@interface ApiInstances : NSObject

@property (nonatomic,strong) NSString* chain_id;
@property (nonatomic,strong) GrapheneApi* _db;
@property (nonatomic,strong) GrapheneApi* _net;
@property (nonatomic,strong) GrapheneApi* _hist;
@property (nonatomic,strong) GrapheneApi* _crypt;

+(instancetype)sharedInstance;
-(void)connect:(NSString*)url timeout:(NSTimeInterval)timeout statusCallback:(void(^)(BOOL connected,NSString* status))callback;
-(void)close;
@end
