//
//  CategoryViewController.m
//  RecipeApp
//
//  Created by clement gan on 16/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import "CategoryPickerViewController.h"

@interface CategoryPickerViewController ()
{
    NSMutableDictionary *nodeDict;
    NSMutableArray *arrayCategory;
    NSMutableString *categoryName;
    NSString *categoryID, *selectedID, *selectedName;
}
@end

@implementation CategoryPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 250);
    
    self.pickerViewCategory.delegate = self;
    self.pickerViewCategory.dataSource = self;
    
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
    
    selectedID = [[self.arrayAllCategory firstObject]valueForKey:@"id"];
    selectedName = [[self.arrayAllCategory firstObject]valueForKey:@"name"];
}




#pragma mark - button event

- (IBAction)btnDone:(id)sender
{
    if(_delegate != nil) {
        [_delegate getCategoryWithID:selectedID Name:selectedName];
    }
    
}

#pragma mark - picker event
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrayAllCategory.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.arrayAllCategory[row] valueForKey:@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedID = [[self.arrayAllCategory objectAtIndex:row]valueForKey:@"id"];
    selectedName = [[self.arrayAllCategory objectAtIndex:row]valueForKey:@"name"];
//    NSLog(@"check selected category id : %@", [[arrayCategory objectAtIndex:row]valueForKey:@"id"]);
//    NSLog(@"check selected category name : %@", [[arrayCategory objectAtIndex:row]valueForKey:@"name"]);
}

@end
