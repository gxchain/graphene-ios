//
//  Graphene.m
//  Graphene
//
//  Created by David Lan on 2018/2/8.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "Graphene.h"

@implementation Graphene
+(instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    static Graphene* grapheneAPI;
    dispatch_once(&onceToken, ^{
        grapheneAPI = [[Graphene alloc] init];
    });
    return grapheneAPI;
}
@end
