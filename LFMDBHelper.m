//
//  LFMDBHelper.m
//  Example
//
//  Created by zhanglei on 19/01/2016.
//  Copyright © 2016 loftor. All rights reserved.
//

#import "LFMDBHelper.h"

#import "fmdb/FMDB.h"

#import "LClassInfo.h"

@interface LFMDBConfig ()

@end

@implementation LFMDBConfig

+ (instancetype) defaultConfig{
    static LFMDBConfig * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (void)registerTableCalssNames:(NSArray *)classNames{
    _tableNames = classNames;
}

@end



@implementation LFMDBHelper

+ (void)dbCreateOrUpgrade:(LFMDBConfig *)config block:(void (^)(BOOL result))callback{
    
    FMDatabase *db = [FMDatabase databaseWithPath:config.path];
    
    if (![db open]) {
        NSLog(@"%@",@"Could not open db");
        return;
    }
    
    if (config.version <= db.userVersion) {
        return;
    }
    
    NSArray * tables = [self getALLTablesFromDB:db];
    
    [config.tableNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * className = obj;
        if ([tables containsObject:className]) {
            NSArray * columns = [self getAllColumnsFromTable:className inDB:db];
            NSDictionary * propertyDic = [LClassInfo getAllPropertys:NSClassFromString(className)];
            for (NSString * name in propertyDic.allKeys) {
                
                if (![columns containsObject:name]) {
                    
                    NSString * type = [self getSqliteTypeFromTypeEncoding:propertyDic[name]];
                    if (type.length!=0) {
                        [self addColumnFormName:name withType:type forTable:className inDB:db];
                    }
                    
                }
            }
            
        }
        else{
            [self createTableFromName:className inDB:db];
            NSDictionary * propertyDic = [LClassInfo getAllPropertys:NSClassFromString(className)];
            for (NSString * name in propertyDic.allKeys) {
                
                NSString * type = [self getSqliteTypeFromTypeEncoding:propertyDic[name]];
                if (type.length!=0) {
                    [self addColumnFormName:name withType:type forTable:className inDB:db];
                }
                
            }
        }
        
    }];
    
    [db setUserVersion:config.version];
    
    [db close];
    
}

+ (NSArray *)getALLTablesFromDB:(FMDatabase *)db{
    
    NSMutableArray * tables = [[NSMutableArray alloc]init];
    
    FMResultSet * rs = [db executeQuery:@"SELECT name,sql FROM sqlite_master WHERE type='table'"];
    
    while ([rs next]){
        NSString * table = [rs stringForColumn:@"name"];
        
        [tables addObject:table];
        
    }
    [rs close];
    return [tables copy];
}

+ (NSArray *)getAllColumnsFromTable:(NSString *)table inDB:(FMDatabase *)db{
    
    NSMutableArray * Columns = [[NSMutableArray alloc]init];
    
    FMResultSet * rs = [db executeQuery:[[NSString alloc]initWithFormat:@"PRAGMA table_info(%@)",table]];
    
    while ([rs next]){
        NSString * column = [rs stringForColumn:@"name"];
        
        [Columns addObject:column];
        
    }
    [rs close];
    
    return [Columns copy];
}

+ (BOOL)createTableFromName:(NSString *)name inDB:(FMDatabase *)db{

    return [db executeUpdate:[[NSString alloc]initWithFormat:@"CREATE TABLE %@ (id INTEGER PRIMARY KEY NOT NULL)",name]];
    
}

+ (BOOL)addColumnFormName:(NSString *)name withType:(NSString *)type forTable:(NSString *)table inDB:(FMDatabase *)db{
    
    return [db executeUpdate:[[NSString alloc]initWithFormat:@"ALTER TABLE %@ ADD %@ %@",table,name,type]];
    
}

+ (NSString *)getSqliteTypeFromTypeEncoding:(NSString *)propertyType {
    if ([propertyType isEqualToString:@"NSString"]) {
        return @"text";
    }
    else if ([propertyType isEqualToString:@"NSNumber"]) {
        return @"integer";
    }
    else if ([propertyType isEqualToString:@"NSData"]) {
        return @"blob";
    }
    else if ([propertyType isEqualToString:@"NSDate"]) {
        return @"integer";
    }
    else if ([propertyType.lowercaseString isEqualToString:@"c"]) {
        return @"integer";

    }
    else if ([propertyType.lowercaseString isEqualToString:@"i"]) {
        return @"integer";

    }
    else if ([propertyType.lowercaseString isEqualToString:@"s"]) {
        return @"integer";
        
    }
    else if ([propertyType.lowercaseString isEqualToString:@"l"]) {
        return @"integer";
        
    }
    else if ([propertyType.lowercaseString isEqualToString:@"q"]) {
        return @"integer";
    }
    else if ([propertyType.lowercaseString isEqualToString:@"B"]) {
        return @"integer";
    }
    else if ([propertyType.lowercaseString isEqualToString:@"f"]) {
        return @"real";
    }
    else if ([propertyType.lowercaseString isEqualToString:@"d"]) {
        return @"real";
    }
    return @"";
}

@end
