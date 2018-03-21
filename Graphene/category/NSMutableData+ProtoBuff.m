//
//  NSMutableData+ProtoBuff.m
//  Graphene
//
//  Created by David Lan on 2018/3/21.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "NSMutableData+ProtoBuff.h"

int64_t convertUInt32ToInt32(uint32_t v) {
    union { int32_t i; uint32_t u; } u;
    u.u = v;
    return u.i;
}

int32_t logicalRightShift32(int32_t value, int32_t spaces) {
    return convertUInt32ToInt32((convertUInt32ToInt32(value) >> spaces));
}

@implementation NSMutableData (ProtoBuff)

- (void)writeVarInt32:(int32_t)value {
    while (YES) {
        if ((value & ~0x7F) == 0) {
            [self writeRawByte:value];
            return;
        } else {
            [self writeRawByte:((value & 0x7F) | 0x80)];
            value = logicalRightShift32(value, 7);
        }
    }
}

- (void)writeRawByte:(uint8_t)value {
    [self appendBytes:&value length:sizeof(value)];
}
@end
