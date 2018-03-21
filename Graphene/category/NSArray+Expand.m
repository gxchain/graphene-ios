//
//  NSArray+Expand.m
//  gongfudai
//
//  Created by David Lan on 15/7/29.
//  Copyright (c) 2015年 dashu. All rights reserved.
//

#import "NSArray+Expand.h"

@implementation NSArray(Expand)
- (NSString*)json
{
//    NSMutableString* json = nil;
    NSString* json = nil;
    
    NSError* error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    json = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return (error ? nil : json);
}
@end
