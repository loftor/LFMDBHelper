# LFMDBHelper
基于FMDB实现功能数据库的创建和升级

# 引用方式
pod 'fmdb', :git => 'https://github.com/ccgus/fmdb.git'

pod 'LFMDBHelper', :git => 'https://github.com/loftor/LFMDBHelper.git', :tag => 'v1.0'

# 使用方式

```objc
  	NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    LFMDBConfig * config = [LFMDBConfig defaultConfig];
    config.path = [docPath stringByAppendingPathComponent:@"test.db"];
    config.version = 1;
    [config registerTableCalssNames:@[@"TestObject"]];
    
    [LFMDBHelper dbCreateOrUpgrade:config block:^(BOOL result) {
        
    }];
```
