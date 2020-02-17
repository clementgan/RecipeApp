//
//  HomeViewController.m
//  RecipeApp
//
//  Created by clement gan on 15/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import "HomeViewController.h"
#import "CustomTableViewCell.h"
#import "FMDB.h"
#import "DetailViewController.h"
#import "CategoryPickerViewController.h"
#import "PublicMethod.h"
#import "DBManager.h"

@interface HomeViewController ()
{
    NSMutableDictionary *nodeDict;
    NSString *categoryID, *dbPath, *selectedCategoryID;
    NSMutableString *categoryName;
    NSMutableArray *arrayRecipe, *arrayCategory;
    NSArray *arrayFilteredRecipe;
    BOOL isFiltered;
}
@property (nonatomic, strong) DBManager *dbManager;
@end


@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    nodeDict = [NSMutableDictionary dictionary];
    arrayCategory = [NSMutableArray array];
    [[PublicMethod sharedInstance]setIsFiltered:NO];
    [[PublicMethod sharedInstance]setSelectedCategoryID:@"0"];
    
    UINib *finalNib = [UINib nibWithNibName:@"CustomTableViewCell" bundle:nil];
    [[self tableViewRecipe] registerNib:finalNib forCellReuseIdentifier:@"CustomTableViewCell"];
    
    /*----- db path-----*/
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"RecipeApp.db"];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    dbPath = [documentsDir stringByAppendingPathComponent:@"RecipeApp.db"];
    NSLog(@"%@",dbPath);
    [[PublicMethod sharedInstance]setDbPath:dbPath];
    
    /*----- navigationbar button -----*/
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor lightGrayColor]];// bar text color
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(btnAddPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    /*----- load table view -----*/
    self.tableViewRecipe.delegate = self;
    self.tableViewRecipe.dataSource = self;
    
    /*----- xml parser -----*/
    NSString *path = [[NSBundle mainBundle] pathForResource:@"receipttype" ofType:@"xml"];
    NSLog(@"xml path: %@", path);
    NSData *xmlData = [[NSFileManager defaultManager] contentsAtPath:path];
    
    NSXMLParser *parser;
    parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = self;
    // we don't care about namespaces
    parser.shouldProcessNamespaces = NO;
    // we just want data, no other stuff.
    parser.shouldResolveExternalEntities = NO;
    [parser parse];
    
    NSLog(@"check arrayCategory : %@",arrayCategory);
}

-(void)viewWillAppear:(BOOL)animated
{
    arrayRecipe = [NSMutableArray array];

    [self getRecipeList];
}


#pragma mark - xml parser

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    if ([elementName isEqualToString:@"recipetype"]) {
        categoryID = [attributeDict objectForKey:@"id"];
    }
    else if ([elementName isEqualToString:@"name"]) {
//        [nodeDict setObject:valueName forKey:valueID];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!categoryName)
        categoryName=[[NSMutableString alloc]init];
    
    if(!nodeDict)
        nodeDict=[NSMutableDictionary dictionary];
    
    [categoryName appendString:string];
    [categoryName setString:[categoryName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [nodeDict setObject:categoryID forKey:@"id"];
    [nodeDict setObject:categoryName forKey:@"name"];
    [arrayCategory addObject:nodeDict];
    
    nodeDict = nil;
    categoryName = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"recipetypes"]) {
//        [arrayRecipe addObject:nodeDict];
//        NSLog(@"didEndElement check arrayRecipe : %@", arrayRecipe);
    }
}


#pragma mark - table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomTableViewCell" forIndexPath:indexPath];
    
    if(![[PublicMethod sharedInstance]getIsFiltered]) {
        cell.tag = [[[arrayRecipe objectAtIndex:indexPath.row] valueForKey:@"RCP_ID"]integerValue];
        cell.labelRecipeName.text = [[arrayRecipe objectAtIndex:indexPath.row] valueForKey:@"RCP_Name"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[[arrayRecipe objectAtIndex:indexPath.row] valueForKey:@"RCP_Image"]];
        cell.imageViewRecipe.image = [UIImage imageWithContentsOfFile:filePath];
    }
    else {
        cell.tag = [[[arrayFilteredRecipe objectAtIndex:indexPath.row] valueForKey:@"RCP_ID"]integerValue];
        cell.labelRecipeName.text = [[arrayFilteredRecipe objectAtIndex:indexPath.row] valueForKey:@"RCP_Name"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[[arrayFilteredRecipe objectAtIndex:indexPath.row] valueForKey:@"RCP_Image"]];
        cell.imageViewRecipe.image = [UIImage imageWithContentsOfFile:filePath];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numOfSection = 0;
    if(arrayRecipe.count > 0)
    {
        self.tableViewRecipe.backgroundView = nil;
        self.tableViewRecipe.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        if(![[PublicMethod sharedInstance]getIsFiltered]) {
            return arrayRecipe.count;
        }
        else {
            return arrayFilteredRecipe.count;
        }
    }
    else
    {
        UILabel *labelNoData = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableViewRecipe.bounds.size.width, self.tableViewRecipe.bounds.size.height)];
        labelNoData.text = @"No Recipe available";
        labelNoData.textColor = [UIColor grayColor];
        labelNoData.textAlignment = NSTextAlignmentCenter;
        self.tableViewRecipe.backgroundView = labelNoData;
        self.tableViewRecipe.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return numOfSection;
//    return arrayRecipe.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailVC = [DetailViewController new];
    detailVC.recipeID = (!isFiltered) ? [[arrayRecipe objectAtIndex:indexPath.row] valueForKey:@"RCP_ID"] : [[arrayFilteredRecipe objectAtIndex:indexPath.row] valueForKey:@"RCP_ID"];
    detailVC.mode = @"view";
    detailVC.arrayAllCategory = arrayCategory;
    [self.navigationController pushViewController:detailVC animated:NO];
    detailVC = nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if(![[PublicMethod sharedInstance]getIsFiltered]) {
            [self deleteTableRowWithID:[[arrayRecipe objectAtIndex:indexPath.row]valueForKey:@"RCP_ID"]];
            [arrayRecipe removeObjectAtIndex:indexPath.row];
        }
        else {
            [self deleteTableRowWithID:[[arrayFilteredRecipe objectAtIndex:indexPath.row]valueForKey:@"RCP_ID"]];
            
            NSMutableArray *discardedItem = [NSMutableArray array];
            for (int i = 0; i < arrayRecipe.count; i++) {
                if ([[arrayRecipe objectAtIndex:i] valueForKey:@"RCP_ID"] == [[arrayFilteredRecipe objectAtIndex:indexPath.row]valueForKey:@"RCP_ID"])
                {
                    [discardedItem addObject:[arrayRecipe objectAtIndex:i]];
                }
            }
            [arrayRecipe removeObjectsInArray:discardedItem];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RCP_CategoryID = %d",[[[PublicMethod sharedInstance]getSelectedCategoryID]integerValue]];
            arrayFilteredRecipe = [NSMutableArray array];
            arrayFilteredRecipe = [arrayRecipe filteredArrayUsingPredicate:predicate];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableViewRecipe reloadData];
        });
    }
}

#pragma mark - sqlite

-(void)getRecipeList
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    arrayRecipe = [NSMutableArray array];
    
    if(![[PublicMethod sharedInstance]getIsFiltered])
    {
        [queue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM Recipe"];
            
            while ([rs next]) {
                [arrayRecipe addObject:[rs resultDictionary]];
            }
            [rs close];
        }];
        [queue close];
        
    }
    else
    {
        [queue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM Recipe WHERE RCP_CategoryID = ?",[[PublicMethod sharedInstance]getSelectedCategoryID]];
            
            while ([rs next]) {
                [arrayRecipe addObject:[rs resultDictionary]];
            }
            [rs close];
        }];
        [queue close];
        arrayFilteredRecipe = arrayRecipe;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableViewRecipe reloadData];
    });
}

-(void)deleteTableRowWithID:(NSString *)recipeID
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        [db executeUpdate:@"DELETE FROM Recipe WHERE RCP_ID=?", recipeID];
    }];
    [dbQueue close];
}


#pragma mark - button

-(void)btnAddPressed:(id)sender
{
    DetailViewController *detailVC = [DetailViewController new];
    detailVC.recipeID = @"";
    detailVC.mode = @"add";
    detailVC.arrayAllCategory = arrayCategory;
    [self.navigationController pushViewController:detailVC animated:NO];
    detailVC = nil;
}

- (IBAction)btnCategory:(id)sender {
    CategoryPickerViewController *categoryPicker = [CategoryPickerViewController new];
    categoryPicker.delegate = self;
    categoryPicker.arrayAllCategory = arrayCategory;
    categoryPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:categoryPicker animated:NO completion:nil];
}


#pragma mark - delegate

-(void)getCategoryWithID:(NSString *)categoryId Name:(NSString *)categoryName
{
    [self dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"you selected category id : %@, name : %@", categoryId, categoryName);
    
    [[PublicMethod sharedInstance]setSelectedCategoryID:categoryId];
    [self.btnCategory setTitle:categoryName forState:UIControlStateNormal];
    
    if([categoryId isEqualToString:@"0"])
    {
        [[PublicMethod sharedInstance]setIsFiltered:NO];
        
        [self getRecipeList];
    }
    else {
        [[PublicMethod sharedInstance]setIsFiltered:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RCP_CategoryID = %d",[categoryId integerValue]];
        arrayFilteredRecipe = [arrayRecipe filteredArrayUsingPredicate:predicate];
//        arrayRecipe = [arrayRecipe filteredArrayUsingPredicate:predicate];
        
        [self.tableViewRecipe reloadData];
    }
    
}

-(void)doneButtonPressed
{
    [self.navigationController popViewControllerAnimated:NO];
    
    [self getRecipeList];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableViewRecipe reloadData];
//    });
}

@end
