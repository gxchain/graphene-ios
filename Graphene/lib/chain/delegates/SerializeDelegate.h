//
//  SerializeDelegate.h
//  Graphene
//
//  Created by David Lan on 2018/3/15.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SerializeDelegate
-(NSData*)serialize;
-(NSDictionary*)dictionaryValue;
@end
