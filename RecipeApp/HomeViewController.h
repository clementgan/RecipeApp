//
//  HomeViewController.h
//  RecipeApp
//
//  Created by clement gan on 15/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewCell.h"



@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnCategory;
@property (weak, nonatomic) IBOutlet UITableView *tableViewRecipe;

- (IBAction)btnCategory:(id)sender;


@end


