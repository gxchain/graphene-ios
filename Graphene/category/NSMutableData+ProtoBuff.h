//
//  NSMutableData+ProtoBuff.h
//  Graphene
//
//  Created by David Lan on 2018/3/21.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (ProtoBuff)
- (void)writeVarInt32:(int32_t)value;
@end
