//
//  GXApiInstances.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GXApiInstances.h"

@implementation GXApiInstances

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static GXApiInstances* instance;
    dispatch_once(&onceToken, ^{
        instance=[[GXApiInstances alloc]init];
    });
    return instance;
}

-(void)connect:(NSString*)url timeout:(NSTimeInterval)timeout statusCallback:(void(^)(BOOL connected,NSString* status))callback{
    if(self.ws_rpc){
        [self.ws_rpc close];
    }
    self.ws_rpc=[[GXChainWebSocket alloc] initWithAddress:url];
    [self.ws_rpc connect:^(BOOL connected, NSString *status) {
        callback(connected,status);
        if(connected&&[status isEqualToString:@"open"]){
            [self.ws_rpc login:@"" password:@"" callback:^(NSError *error, id response) {
                if(!error){
                    NSLog(@"Conncted to API node:%@",url);
                    self.initCount=0;
                    self._db=[[GXGrapheneApi alloc] initWithName:@"database" websocket:self.ws_rpc];
                    self._net=[[GXGrapheneApi alloc] initWithName:@"network_broadcast" websocket:self.ws_rpc];
                    self._hist=[[GXGrapheneApi alloc] initWithName:@"history" websocket:self.ws_rpc];
                    self._crypt=[[GXGrapheneApi alloc] initWithName:@"crypto" websocket:self.ws_rpc];
                    [self._db initialize:^(NSError *err, id response) {
                        if(!err){
                            self.initCount+=1;
                            if(self.initCount==4){
                                callback(YES,@"ready");
                            }
                            [self._db exec:@"get_chain_id" params:@[] callback:^(NSError *err, id resp) {
                                if(!err){
                                    self.chain_id=resp;
                                }
                            }];
                        }else{
                            callback(NO,@"initFail");
                        }
                    }];
                    [self._net initialize:^(NSError *err, id response) {
                        if(!err){
                            self.initCount+=1;
                            if(self.initCount==4){
                                callback(YES,@"ready");
                            }
                        }else{
                            callback(NO,@"initFail");
                        }
                    }];
                    [self._hist initialize:^(NSError *err, id response) {
                        if(!err){
                            self.initCount+=1;
                            if(self.initCount==4){
                                callback(YES,@"ready");
                            }
                        }else{
                            callback(NO,@"initFail");
                        }
                    }];
                    [self._crypt initialize:^(NSError *err, id response) {
                        if(!err){
                            self.initCount+=1;
                            if(self.initCount==4){
                                callback(YES,@"ready");
                            }
                        }else{
                            callback(NO,@"initFail");
                        }
                    }];
                } else{
                    NSLog(@"Login to %@ failed:%@",url,error.localizedDescription);
                }
            }];
        }
    } timeout:timeout];
}

-(void)close{
    if(self.ws_rpc){
        [self.ws_rpc close];
        self.ws_rpc=nil;
    }
}
@end
