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
    NSLog(@"%@",result);
}

@end
