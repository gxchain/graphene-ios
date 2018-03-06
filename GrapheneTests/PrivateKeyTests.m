//
//  PrivateKeyTests.m
//  GrapheneTests
//
//  Created by David Lan on 2018/3/1.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PrivateKey.h"
#import <ASKSecp256k1/CKSecp256k1.h>

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
    NSString* wifKey=@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7";
    PrivateKey* privateKey=[PrivateKey fromWif:wifKey];
    NSAssert(privateKey!=nil, @"Invalid private key");
    NSAssert([wifKey isEqualToString:[privateKey toWif]], @"Bad private key");
}

- (void)testSharedSecret{
    PrivateKey* privateKey=[PrivateKey fromWif:@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7"];
    
    NSLog(@"public:%@",[[privateKey getPublic] toString]);
    NSLog(@"shared:%@",[privateKey sharedSecret:[privateKey getPublic]]);
//    PublicKey* pub1= [privateKey getPublic];
//    PublicKey* pub2= [privateKey getPublic2];
//    PublicKey* pubKey=[PublicKey fromString:@"GXC7XzFVivuBtuc2rz3Efkb41JCN4KH7iENAx9rch9QkowEmc4UvV"];
//    NSLog(@"%@\n%@",pubKey.publicKeyData,[privateKey getPublic].publicKeyData);
}

@end
