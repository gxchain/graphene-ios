//
//  GrapheneTests.m
//  GrapheneTests
//
//  Created by David Lan on 2018/3/1.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConnectionManager.h"
#import "ApiInstances.h"

@interface ConnectionManagerTests : XCTestCase

@end

@implementation ConnectionManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConnect {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Connection Exception"];
    [[ConnectionManager sharedInstance] connectWithFallback:@[@"wss://node1.gxb.io",@"wss://node5.gxb.io",@"wss://node8.gxb.io",@"wss://node11.gxb.io",@"wss://node18.gxb.io"] callback:^(BOOL connected, NSString *url) {
        if(connected){
            NSLog(@"Conncted to:%@",url);
        }
        [[ApiInstances sharedInstance]._db exec:@"get_objects" params:@[@[@"2.1.0"]] callback:^(NSError *err, id resp) {
            NSLog(@"%@",resp);
            [expectation fulfill];
        }];
        
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

@end
