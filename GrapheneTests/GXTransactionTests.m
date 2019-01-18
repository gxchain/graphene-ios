//
//  TransactionTests.m
//  GrapheneTests
//
//  Created by David Lan on 2018/3/16.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXConnectionManager.h"
#import "GXTransactionBuilder.h"
#import "GXTransferOperation.h"
#import "GXAssetAmount.h"
#import "GXPrivateKey.h"
#import "NSDictionary+Expand.h"
#import "GXCallContractOperation.h"
#import "GXUtil.h"

@interface GXTransactionTests : XCTestCase

@end

@implementation GXTransactionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
// Register a free testnet account here: https://testnet.wallet.gxchain.org
- (void)testTransfer {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Connection Exception"];
    [[GXConnectionManager sharedInstance] connectWithFallback:@[@"wss://testnet.gxchain.org"] callback:^(BOOL connected, NSString *url) {
        GXTransferOperation* transferOp=[[GXTransferOperation alloc] init];
        transferOp.from=@"1.2.850";
        transferOp.to=@"1.2.254";
        transferOp.amount=[[GXAssetAmount alloc] initWithAsset:@"1.3.1" amount:1000000];
        transferOp.fee=[[GXAssetAmount alloc] initWithAsset:@"1.3.1" amount:0];
        transferOp.memo=[GXMemoData memoWithPrivate:@"5JNFf2y7JN75HMytcTJVANPVXAzv5iQbxdVDrtJNWfcSsyWUrXU" public:@"GXC7xSR83xcXECGCtyxboNbuhQwnyjVksgtMLX422nDhSM9d2TPRF" message:@"屌不屌，来自GXS Native的转账"];
        GXTransactionBuilder* tx = [[GXTransactionBuilder alloc] initWithOperations:@[transferOp]];
        [tx add_signer:[GXPrivateKey fromWif:@"5JNFf2y7JN75HMytcTJVANPVXAzv5iQbxdVDrtJNWfcSsyWUrXU"]];
        [tx processTransaction:^(NSError* err,NSDictionary *transaction) {
            NSLog(@"%@",transaction.json);
            [expectation fulfill];
        } broadcast:YES];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

- (void)testTransferSign{
    GXTransferOperation* transferOp=[[GXTransferOperation alloc] init];
    transferOp.fee=[[GXAssetAmount alloc] initWithAsset:@"1.3.1" amount:2500];
    transferOp.from=@"1.2.850";
    transferOp.to=@"1.2.254";
    transferOp.amount=[[GXAssetAmount alloc] initWithAsset:@"1.3.1" amount:1000000];
    transferOp.memo=[GXMemoData memoWithPrivate:@"5JNFf2y7JN75HMytcTJVANPVXAzv5iQbxdVDrtJNWfcSsyWUrXU" public:@"GXC7xSR83xcXECGCtyxboNbuhQwnyjVksgtMLX422nDhSM9d2TPRF" message:@"123"];
    GXTransactionBuilder* tx = [[GXTransactionBuilder alloc] initWithOperations:@[transferOp]];
    tx.ref_block_num=53519;
    tx.ref_block_prefix=2568833528;
    tx.expiration=1521578798;
    tx.extensions=@[];
    [tx add_signer:[GXPrivateKey fromWif:@"5JNFf2y7JN75HMytcTJVANPVXAzv5iQbxdVDrtJNWfcSsyWUrXU"]];
    
    NSLog(@"%@,%@,%@",BTCHexFromData([tx serialize]),[[tx dictionaryValue] json],[tx signedTransaction]);
}

-(void) testCallContract{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Connection Exception"];
    [[GXConnectionManager sharedInstance] connectWithFallback:@[@"wss://testnet.gxchain.org"] callback:^(BOOL connected, NSString *url) {
        GXCallContractOperation* callOp = [[GXCallContractOperation alloc] init];
        callOp.fee=[[GXAssetAmount alloc] initWithAsset:@"1.3.1" amount:0];
        callOp.account = @"1.2.850";
        callOp.contract_id=@"1.2.282";
        callOp.method_name=@"hi";
        callOp.data=[NSData data];
        GXTransactionBuilder* tx = [[GXTransactionBuilder alloc] initWithOperations:@[callOp]];
        [tx add_signer:[GXPrivateKey fromWif:@"5JNFf2y7JN75HMytcTJVANPVXAzv5iQbxdVDrtJNWfcSsyWUrXU"]];
        [tx processTransaction:^(NSError* err,NSDictionary *transaction) {
            NSLog(@"%@",transaction.json);
            [expectation fulfill];
        } broadcast:YES];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

@end
