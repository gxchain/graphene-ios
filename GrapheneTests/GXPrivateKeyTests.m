//
//  PrivateKeyTests.m
//  GrapheneTests
//
//  Created by David Lan on 2018/3/1.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXPrivateKey.h"

@interface GXPrivateKeyTests : XCTestCase

@end

@implementation GXPrivateKeyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFromWif {
    NSString* wifKey=@"5JNFf2y7JN75HMytcTJVANPVXAzv5iQbxdVDrtJNWfcSsyWUrXU";
    GXPrivateKey* privateKey=[GXPrivateKey fromWif:wifKey];
    NSAssert(privateKey!=nil, @"Invalid private key");
    NSAssert([wifKey isEqualToString:[privateKey toWif]], @"Bad private key");
}

- (void)testSharedSecret{
    GXPrivateKey* privateKey=[GXPrivateKey fromWif:@"5JNFf2y7JN75HMytcTJVANPVXAzv5iQbxdVDrtJNWfcSsyWUrXU"];
    NSLog(@"public:%@",[[privateKey getPublic] toString]);
    NSLog(@"shared:%@",BTCHexFromData([privateKey sharedSecret:[privateKey getPublic]]));
}

-(void)testSignature{
    NSString* message = @"😜";
    GXPrivateKey* privateKey=[GXPrivateKey fromWif:@"5JNFf2y7JN75HMytcTJVANPVXAzv5iQbxdVDrtJNWfcSsyWUrXU"];
    NSData* signature=[privateKey sign:[message dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"signature:%@",BTCHexFromData(signature));
}

@end
