//
//  NSDictionary+Expand.m
//  gongfudai
//
//  Created by David Lan on 15/8/14.
//  Copyright (c) 2015年 dashu. All rights reserved.
//

#import "NSDictionary+Expand.h"

@implementation NSDictionary(Expand)
-(NSString *)json{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    if (! jsonData) {
        NSLog(@"json转换失败: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return result;
    }
}

@end
