//
//  LFMDBHelper.h
//  Example
//
//  Created by zhanglei on 19/01/2016.
//  Copyright © 2016 loftor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LFMDBConfig : NSObject

@property (strong ,nonatomic, readonly) NSArray * tableNames;

@property (strong, nonatomic) NSString * path;

@property (assign, nonatomic) uint32_t version;

+ (instancetype) defaultConfig;

- (void)registerTableCalssNames:(NSArray *)classNames;

@end

@interface LFMDBHelper : NSObject

+ (void) dbCreateOrUpgrade:(LFMDBConfig *)config block:(void(^)(BOOL result))callback;

@end
