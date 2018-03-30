# Graphene
Implementation of Graphene protocol in Objective-C

## Use case

```Objective-c
[[ConnectionManager sharedInstance] connectWithFallback:@[@"ws://192.168.1.119:28090"] callback:^(BOOL connected, NSString *url) {
        TransferOperation* transferOp=[[TransferOperation alloc] init];
        transferOp.from=@"1.2.19";
        transferOp.to=@"1.2.21";
        transferOp.amount=[[AssetAmount alloc] initWithAsset:@"1.3.1" amount:1000000];
        transferOp.fee=[[AssetAmount alloc] initWithAsset:@"1.3.1" amount:0];
        transferOp.memo=[MemoData memoWithPrivate:@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7" public:@"GXC67KQNpkkLUzBgDUkWqEBtojwqPgL78QCmTRRZSLugzKEzW4rSm" message:@"屌不屌，来自GXS Native的转账"];
        TransactionBuilder* tx = [[TransactionBuilder alloc] initWithOperations:@[transferOp]];
        [tx add_signer:[PrivateKey fromWif:@"5Ka9YjFQtfUUX2DdnqkaPWH1rVeSeby7Cj2VdjRt79S9kKLvXR7"]];
        [tx processTransaction:^(NSError* err,NSDictionary *transaction) {
            NSLog(@"%@",transaction.json);
        } broadcast:YES];
}];
```
