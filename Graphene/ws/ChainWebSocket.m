//
//  GrapheneWS.m
//  Graphene
//
//  Created by David Lan on 2018/2/25.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "ChainWebSocket.h"
#import <SocketRocket/SRWebSocket.h>
@interface ChainWebSocket()<SRWebSocketDelegate>
{
    uint32_t cbId;
}
@property (nonatomic,strong) SRWebSocket* socket;
@property (nonatomic,assign) BOOL connected;
@property (nonatomic,readwrite,copy) void(^connctCallback)(BOOL connected,NSString* status);
@property (atomic,strong) NSMutableDictionary* callbackMaps;
@property (atomic,strong) NSMutableDictionary* broadcastCallbackMaps;
@property (nonatomic,strong) NSTimer* timeoutTimer;
@property (nonatomic,assign) BOOL connectTimeout;
@end

@implementation ChainWebSocket
-(instancetype)initWithAddress:(NSString*)address{
    self=[self init];
    cbId=0;
    self.callbackMaps=[NSMutableDictionary dictionary];
    self.broadcastCallbackMaps=[NSMutableDictionary dictionary];
    self.socket=[[SRWebSocket alloc] initWithURL:[NSURL URLWithString:address]];
    self.socket.delegate=self;
    [self.socket open];
    return self;
}

#pragma mark - custom methods
-(void)timeout{
    [self.timeoutTimer invalidate];
    self.timeoutTimer=nil;
    if(!self.connectTimeout){
        self.connectTimeout=YES;
        self.connctCallback(NO, @"timeout");
    }
}

-(void)connect:(void(^)(BOOL connected,NSString* status))callback timeout:(NSTimeInterval)timeout{
    self.connctCallback=callback;
    self.connectTimeout=NO;
    self.timeoutTimer=[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timeout) userInfo:nil repeats:NO];
    if(self.connected && self.connctCallback){
        self.connctCallback(YES,@"open");
    }
    else{
        [self.socket open];
    }
}

-(void)call:(NSArray*)params callback:(void (^)(NSError * error, id response))callback{
    if(!self.connected){
        callback([NSError errorWithDomain:@"GrapheneWS" code:-1 userInfo:nil],nil);
    }
    else{
        NSString* _cbId = [NSString stringWithFormat:@"%u",++cbId];
        [self.callbackMaps setObject:callback forKey:_cbId];
        NSString* method = params[1];
        if([method isEqualToString:@"broadcast_transaction_with_callback"]){
            id bradcast_callback = params[2][0];
            [self.broadcastCallbackMaps setObject:bradcast_callback forKey:_cbId];
            NSMutableArray* mutableParams= params.mutableCopy;
            mutableParams[2]=@[_cbId,params[2][1]];
            params=mutableParams;
        }
        
        NSDictionary* request=@{@"method":@"call",@"params":params,@"id":_cbId};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                           options:0
                                                             error:&error];
        if (!jsonData) {
            NSLog(@"Got an error: %@", error);
            callback(error,nil);
        }
        else{
            [self.socket send:jsonData];
        }
    }
}

-(void)login:(NSString*)user password:(NSString*)password callback:(void (^)(NSError * error, id response))callback{
    if(self.connected){
        [self call:@[@1,@"login",@[user,password]] callback:^(NSError *error, id response) {
            callback(error,response);
        }];
    } else{
        callback([NSError errorWithDomain:@"GrapheneWS" code:-1 userInfo:nil],nil);
    }
}

-(void)close{
    [self.socket close];
    self.connctCallback=nil;
}

#pragma mark - websocket delegate methods
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"\n>>%@\n",message);
    NSError* error;
    NSDictionary *string2dic = [NSJSONSerialization JSONObjectWithData: [message dataUsingEncoding:NSUTF8StringEncoding]
                                                               options: NSJSONReadingMutableContainers
                                                                 error: &error];
    if([string2dic objectForKey:@"id"]){
        NSString* _cbId = [[string2dic objectForKey:@"id"] stringValue];
        void(^cb)(NSError*,id result) = [self.callbackMaps objectForKey:_cbId];
        if(cb){
            cb(nil,string2dic[@"result"]);
            [self.callbackMaps removeObjectForKey:_cbId];
        }
    }
    else if([[string2dic objectForKey:@"method"] isEqualToString:@"notice"]){
        NSString* _cbId = [string2dic[@"params"][0] stringValue];
        void(^cb)(NSError*,id result) = [self.broadcastCallbackMaps objectForKey:_cbId];
        if(cb){
            cb(nil,string2dic[@"params"][1]);
            [self.broadcastCallbackMaps removeObjectForKey:_cbId];
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    self.connected=YES;
    [self.timeoutTimer invalidate];
    if(self.connctCallback && !self.connectTimeout){
        self.connctCallback(YES,@"open");
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    self.connected=NO;
    [self.timeoutTimer invalidate];
    [webSocket close];
    NSLog(@"socket connect failed:%@",error.localizedDescription);
    if(self.connctCallback && !self.connectTimeout){
        self.connctCallback(NO,@"error");
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    self.connected=NO;
    [self.timeoutTimer invalidate];
    NSLog(@"socket connect lost:%@,%ld,%d",reason,(long)code,wasClean);
    if(self.connctCallback && !self.connectTimeout){
        self.connctCallback(NO,@"closed");
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    [self.timeoutTimer invalidate];
    NSLog(@"pong:%@",[[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding]);
}
@end

