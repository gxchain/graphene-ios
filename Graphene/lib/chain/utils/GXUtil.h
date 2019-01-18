//
//  GXUtil.h
//  Graphene
//
//  Created by David Lan on 2018/12/12.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXUtil : NSObject
+(uint64_t) string_to_name:(NSString*)str;
+(NSString*) name_to_string :(uint64_t)name;
+(NSString*) serialize_action_data:(NSString*)action params:(NSDictionary*)params abi:(NSDictionary*)abi;
+(NSString*) serialize_transaction:(NSDictionary*)transaction;
@end

