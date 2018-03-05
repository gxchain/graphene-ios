//
//  ConnectionManager.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "ConnectionManager.h"
#import "ApiInstances.h"
#import "ChainWebSocket.h"

@interface ConnectionManager()
@property (nonatomic,strong) ApiInstances* Api;
@end

@implementation ConnectionManager

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static ConnectionManager* instance;
    dispatch_once(&onceToken, ^{
        instance=[[ConnectionManager alloc] init];
        instance.Api=[ApiInstances sharedInstance];
    });
    return instance;
}

-(void)connect:(NSString*)url callback:(void(^)(BOOL connected))callback{
    [self.Api connect:url timeout:4 statusCallback:^(BOOL connected, NSString *status) {
        if(!connected && ![status isEqualToString:@"closed"]){ //error, timeout, initFail
            [self.Api close];
        }
        else if(!connected&&[status isEqualToString:@"closed"]){ // closed
            NSLog(@"Connection closed: %@",url);
            callback(NO);
        }
        else if(connected&&[status isEqualToString:@"ready"]){ // connected and initialized
            callback(YES);
        }
        // no more case
    }];
}

-(void)checkConnect:(NSString*)url callback:(void(^)(NSArray* info))callback{
    ChainWebSocket* conn = [[ChainWebSocket alloc]initWithAddress:url];
    NSDate* start = [NSDate date];
    [conn connect:^(BOOL connected, NSString *status) {
        [conn close];
        if(connected){
            callback(@[url,@([[NSDate date] timeIntervalSinceDate:start])]);
        }
        else{
            callback(@[url,@(-1)]);
        }
    } timeout:4];
}

-(void)checkConnections:(NSArray*)urls callback:(void(^)(NSArray* urlInfo))callback{
    NSMutableArray* results=[NSMutableArray array];
    [urls enumerateObjectsUsingBlock:^(NSString* url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self checkConnect:url callback:^(NSArray *info) {
            [results addObject:info];
            if([results count]==[urls count]){
                callback(results);
            }
        }];
    }];
}

-(void)tryConnect:(NSArray*)urls index:(NSInteger)index callback:(void(^)(BOOL connected,NSString* url))callback{
    if(index<[urls count]){
        NSString* url = [[urls objectAtIndex:index] objectAtIndex:0];
        [self connect:url callback:^(BOOL connected) {
            if(connected){
                callback(YES,url);
            }
            else{
                [self tryConnect:urls index:index+1 callback:callback];
            }
        }];
    }
    else{
        callback(NO,nil);
    }
}

-(void)connectWithFallback:(NSArray*)urls callback:(void(^)(BOOL connected,NSString* url))callback{
    [self checkConnections:urls callback:^(NSArray *urlInfo) {
        NSMutableArray* arr = [NSMutableArray array];
        [urlInfo enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj[1] integerValue]>-1){
                [arr addObject:obj];
            }
        }];
        [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1[1] doubleValue]>[obj2[1] doubleValue];
        }];
        NSLog(@"%@",arr);
        [self tryConnect:arr index:0 callback:^(BOOL connected,NSString* url) {
            if(!connected){
                NSLog(@"Tried %lu connections, none of which worked,%@",(unsigned long)[arr count],arr);
            }
            callback(connected,url);
        }];
    }];
}


@end

