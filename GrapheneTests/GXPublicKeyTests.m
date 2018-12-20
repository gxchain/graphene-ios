//
//  PublicKeyTests.m
//  GrapheneTests
//
//  Created by David Lan on 2018/3/1.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXPublicKey.h"

@interface GXPublicKeyTests : XCTestCase

@end

@implementation GXPublicKeyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFromString {
    NSString* pubkeyString = @"GXC7XzFVivuBtuc2rz3Efkb41JCN4KH7iENAx9rch9QkowEmc4UvV";
    GXPublicKey* pubKey=[GXPublicKey fromString:pubkeyString];
    EC_POINT* pubkeyP = EC_KEY_get0_public_key(pubKey._key);
    GXPublicKey* pubKey2= [GXPublicKey fromData:[pubKey publicKeyWithCompression:NO]];
    NSLog(@"%@",[pubKey2 toString]);
    NSAssert([[pubKey toString] isEqualToString:pubkeyString], @"Invalid pubkey");
}

@end
