//
//  GrapheneApi.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GrapheneApi.h"

@interface GrapheneApi()
@property (nonatomic,strong) ChainWebSocket* ws_rpc;
@property (nonatomic,strong) NSString* api_name;
@property (nonatomic,strong) NSString* api_id;
@end

@implementation GrapheneApi
-(instancetype)initWithName:(NSString*)api_name websocket:(ChainWebSocket*)ws_rpc{
    self=[self init];
    self.api_name=api_name;
    self.ws_rpc = ws_rpc;
    return self;
}

-(void)initialize:(void(^)(NSError* err,id response))callback{
    [self.ws_rpc call:@[@1,self.api_name,@[]] callback:^(NSError *error, id response) {
        if(!error){
            self.api_id = response;
            callback(nil,self.api_id);
        }
        else{
            NSLog(@"%@ Api initialize failed:%@",self.api_name,error);
            callback(error,response);
        }
    }];
}

-(void)exec:(NSString*)method params:(NSArray*)params callback:(void(^)(NSError* err,id resp))callback{
    if(!self.api_id){
        NSLog(@"%@",@[self.api_id,method,params]);
        NSLog(@"%@ Api is not initialized",self.api_name);
        callback([NSError errorWithDomain:self.api_name code:-1 userInfo:nil],nil);
    }
    else{
        [self.ws_rpc call:@[self.api_id,method,params] callback:^(NSError *error, id response) {
            if(error){
                NSLog(@"%@:\n%@",@[self.api_id,method,params],error);
            }
            callback(error,response);
        }];
    }
}
@end
