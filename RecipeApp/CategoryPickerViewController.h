//
//  CategoryViewController.h
//  RecipeApp
//
//  Created by clement gan on 16/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryPickerDelegate<NSObject>
@required
-(void)getCategoryWithID:(NSString *)categoryId Name:(NSString *)categoryName;
@end

@interface CategoryPickerViewController : UIViewController <NSXMLParserDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic,weak) id <CategoryPickerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
- (IBAction)btnDone:(id)sender;


@property (nonatomic, strong) NSArray *arrayAllCategory;


@end


