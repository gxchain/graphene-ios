//
//  PrivateKeyTests.m
//  GrapheneTests
//
//  Created by David Lan on 2018/3/1.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PrivateKey.h"

@interface PrivateKeyTests : XCTestCase

@end

@implementation PrivateKeyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFromWif {
    PrivateKey* privateKey=[PrivateKey fromWif:@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7"];
    NSAssert(privateKey!=nil, @"Invalid private key");
}

@end
