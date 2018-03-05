//
//  PublicKeyTests.m
//  GrapheneTests
//
//  Created by David Lan on 2018/3/1.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PublicKey.h"

@interface PublicKeyTests : XCTestCase

@end

@implementation PublicKeyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFromString {
    NSLog(@"%ld",sizeof(uint32_t));
    PublicKey* pubKey=[PublicKey fromString:@"GXC7XzFVivuBtuc2rz3Efkb41JCN4KH7iENAx9rch9QkowEmc4UvV"];
    NSLog(@"%lu,%lu",(unsigned long)[pubKey.publicKeyData length],[[pubKey publicKeyWithCompression:NO] length]);
    NSAssert(pubKey!=nil, @"Invalid pubkey");
}

@end
