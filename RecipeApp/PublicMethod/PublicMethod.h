//
//  PublicMethod.h
//  RecipeApp
//
//  Created by clement gan on 16/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"


@interface PublicMethod : NSObject

@property (strong, nonatomic) FMDatabaseQueue *dBQueue;

+(PublicMethod *)sharedInstance;

-(void)setDbPath:(NSString *)path;
-(NSString *)getDbPath;

-(NSDateFormatter *)getDateFormaterhh_mm;
-(NSDateFormatter *)getDateFormaterhhmmss;

-(void)setIsFiltered:(BOOL)isFiltered;
-(BOOL)getIsFiltered;

-(void)setSelectedCategoryID:(NSString *)selectedCategoryID;
-(NSString *)getSelectedCategoryID;

@end


