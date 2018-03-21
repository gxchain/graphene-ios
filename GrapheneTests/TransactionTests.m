//
//  TransactionTests.m
//  GrapheneTests
//
//  Created by David Lan on 2018/3/16.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConnectionManager.h"
#import "TransactionBuilder.h"
#import "TransferOperation.h"
#import "AssetAmount.h"
#import "PrivateKey.h"
#import "NSDictionary+Expand.h"

@interface TransactionTests : XCTestCase

@end

@implementation TransactionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTransfer {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Connection Exception"];
    [[ConnectionManager sharedInstance] connectWithFallback:@[@"ws://192.168.1.119:28090"] callback:^(BOOL connected, NSString *url) {
        TransferOperation* transferOp=[[TransferOperation alloc] init];
        transferOp.from=@"1.2.19";
        transferOp.to=@"1.2.21";
        transferOp.amount=[[AssetAmount alloc] initWithAsset:@"1.3.1" amount:1000000];
        transferOp.fee=[[AssetAmount alloc] initWithAsset:@"1.3.1" amount:0];
        transferOp.memo=[MemoData memoWithPrivate:@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7" public:@"GXC67KQNpkkLUzBgDUkWqEBtojwqPgL78QCmTRRZSLugzKEzW4rSm" message:@"123a"];
        TransactionBuilder* tx = [[TransactionBuilder alloc] initWithOperations:@[transferOp]];
        [tx add_signer:[PrivateKey fromWif:@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7"]];
        [tx processTransaction:^(NSError* err,NSDictionary *transaction) {
            NSLog(@"%@",transaction.json);
            [expectation fulfill];
        } broadcast:YES];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

-(void)testMemoSerialize{
    MemoData* memo=[MemoData memoWithPrivate:@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7" public:@"GXC67KQNpkkLUzBgDUkWqEBtojwqPgL78QCmTRRZSLugzKEzW4rSm" message:@"123"];
    NSLog(@"%@",BTCHexFromData([memo serialize]));
}

- (void)testTransferSign{
    TransferOperation* transferOp=[[TransferOperation alloc] init];
    transferOp.fee=[[AssetAmount alloc] initWithAsset:@"1.3.1" amount:2500];
    transferOp.from=@"1.2.19";
    transferOp.to=@"1.2.21";
    transferOp.amount=[[AssetAmount alloc] initWithAsset:@"1.3.1" amount:1000000];
    transferOp.fee=[[AssetAmount alloc] initWithAsset:@"1.3.1" amount:2500];
    transferOp.memo=[MemoData memoWithPrivate:@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7" public:@"GXC67KQNpkkLUzBgDUkWqEBtojwqPgL78QCmTRRZSLugzKEzW4rSm" message:@"123a"];
    TransactionBuilder* tx = [[TransactionBuilder alloc] initWithOperations:@[transferOp]];
    tx.ref_block_num=53519;
    tx.ref_block_prefix=2568833528;
    tx.expiration=1521578798;
    tx.extensions=@[];
    [tx add_signer:[PrivateKey fromWif:@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7"]];
    NSLog(@"%@",[tx signedTransaction]);
}

@end
