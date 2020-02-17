//
//  PublicMethod.m
//  RecipeApp
//
//  Created by clement gan on 16/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import "PublicMethod.h"

@interface PublicMethod ()
{
    NSString *dbPath, *selectedCategoryID;
    BOOL *isFiltered;
}
@end


@implementation PublicMethod

+(PublicMethod *)sharedInstance
{
    static PublicMethod *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [PublicMethod new];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
//        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDir = [docPaths objectAtIndex:0];
//        NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"RecipeApp.db"];
//        _dBQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

//---------- dbpath  ------------
-(void)setDbPath:(NSString *)path
{
    dbPath = path;
}

-(NSString *)getDbPath
{
    return dbPath;
}

-(NSDateFormatter *)getDateFormaterhh_mm
{
    static NSDateFormatter *formatterhhmmss;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatterhhmmss = [[NSDateFormatter alloc] init];
        formatterhhmmss.dateFormat = @"yyyy-MM-dd hh-mm-ss"; // twitter date format
    });
    return formatterhhmmss;
}

-(NSDateFormatter *)getDateFormaterhhmmss
{
    static NSDateFormatter *formatterhhmmss;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatterhhmmss = [[NSDateFormatter alloc] init];
        formatterhhmmss.dateFormat = @"yyyy-MM-dd HH:mm:ss"; // twitter date format
    });
    return formatterhhmmss;
}

-(void)setIsFiltered:(BOOL)isFilter
{
    isFiltered = isFilter;
}
-(BOOL)getIsFiltered
{
    return isFiltered;
}

-(void)setSelectedCategoryID:(NSString *)categoryID
{
    selectedCategoryID = categoryID;
}
-(NSString *)getSelectedCategoryID
{
    return selectedCategoryID;
}

@end
