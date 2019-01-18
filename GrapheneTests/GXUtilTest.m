//
//  GXUtilTest.m
//  GrapheneTests
//
//  Created by David Lan on 2018/12/19.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXUtil.h"
#import "NSDictionary+Expand.h"

@interface GXUtilTest : XCTestCase

@end

@implementation GXUtilTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testStringToName{
    uint64_t name =[GXUtil string_to_name:@"hi"];
    NSString* str = [GXUtil name_to_string:name];
    NSLog(@"%llu,%@",name,str);
}

-(void) testActionSerializer{
    NSDictionary* params = [NSDictionary fromJSON:@"{\"to_account\":\"lzydophin94\",\"amount\":{\"asset_id\":1,\"amount\":1000000}}"];
    NSDictionary* abi = [NSDictionary fromJSON:@"{\"version\":\"gxc::abi/1.0\",\"types\":[],\"structs\":[{\"name\":\"account\",\"base\":\"\",\"fields\":[{\"name\":\"owner\",\"type\":\"uint64\"},{\"name\":\"balances\",\"type\":\"contract_asset[]\"}]},{\"name\":\"deposit\",\"base\":\"\",\"fields\":[]},{\"name\":\"withdraw\",\"base\":\"\",\"fields\":[{\"name\":\"to_account\",\"type\":\"string\"},{\"name\":\"amount\",\"type\":\"contract_asset\"}]}],\"actions\":[{\"name\":\"deposit\",\"type\":\"deposit\",\"payable\":true},{\"name\":\"withdraw\",\"type\":\"withdraw\",\"payable\":false}],\"tables\":[{\"name\":\"account\",\"index_type\":\"i64\",\"key_names\":[\"owner\"],\"key_types\":[\"uint64\"],\"type\":\"account\"}],\"error_messages\":[],\"abi_extensions\":[]}"];
    NSString* result = [GXUtil serialize_action_data:@"withdraw" params:params abi:abi];
    NSLog(@"%@",result); // 0b6c7a79646f7068696e393440420f00000000000100000000000000
}

-(void) testTransactionSerializer{
    NSDictionary* transaction = [NSDictionary fromJSON:@"{\"expiration\":\"2018-03-20T20:46:38\",\"extensions\":[],\"operations\":[[0,{\"amount\":{\"asset_id\":\"1.3.1\",\"amount\":1000000},\"fee\":{\"asset_id\":\"1.3.1\",\"amount\":2500},\"to\":\"1.2.254\",\"memo\":{\"nonce\":2680142845,\"to\":\"GXC7xSR83xcXECGCtyxboNbuhQwnyjVksgtMLX422nDhSM9d2TPRF\",\"message\":\"70fed4bf910021bd4e01c221dcc93570\",\"from\":\"GXC8H1wXTAUWcTtogBmA5EW8TUWLA6T1kAXwMKYtnNuqAe1VCXFD9\"},\"extensions\":[],\"from\":\"1.2.850\"}]],\"ref_block_prefix\":2568833528,\"ref_block_num\":53519}"];
    NSString* result = [GXUtil serialize_transaction:transaction];
    NSLog(@"%@",result);
    //0fd1f8491d99ae02b15a0100c40900000000000001d206fe0140420f0000000000010103be3d4b21c275a5dd5a8e61959feecce56589e30e8aeaf4c15798aca17872eaea03940e48cb1fe1c5975ee9ea5876ccbbe132d69396eebc68201d0198588e44b887fdbbbf9f000000001070fed4bf910021bd4e01c221dcc935700000
}

@end
