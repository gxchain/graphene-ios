# Graphene
Implementation of Graphene protocol in Objective-C

## Use case

### Transfer

```Objective-c
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
```

### CallContract

``` Objective-C
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
```

### Contract Parameters Serializer

``` Objective-C
NSDictionary* params = [NSDictionary fromJSON:@"{\"to_account\":\"lzydophin94\",\"amount\":{\"asset_id\":1,\"amount\":1000000}}"];
    NSDictionary* abi = [NSDictionary fromJSON:@"{\"version\":\"gxc::abi/1.0\",\"types\":[],\"structs\":[{\"name\":\"account\",\"base\":\"\",\"fields\":[{\"name\":\"owner\",\"type\":\"uint64\"},{\"name\":\"balances\",\"type\":\"contract_asset[]\"}]},{\"name\":\"deposit\",\"base\":\"\",\"fields\":[]},{\"name\":\"withdraw\",\"base\":\"\",\"fields\":[{\"name\":\"to_account\",\"type\":\"string\"},{\"name\":\"amount\",\"type\":\"contract_asset\"}]}],\"actions\":[{\"name\":\"deposit\",\"type\":\"deposit\",\"payable\":true},{\"name\":\"withdraw\",\"type\":\"withdraw\",\"payable\":false}],\"tables\":[{\"name\":\"account\",\"index_type\":\"i64\",\"key_names\":[\"owner\"],\"key_types\":[\"uint64\"],\"type\":\"account\"}],\"error_messages\":[],\"abi_extensions\":[]}"];
    NSString* result = [GXUtil serialize_action_data:@"withdraw" params:params abi:abi];
```


