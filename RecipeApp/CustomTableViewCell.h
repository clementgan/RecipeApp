//
//  SwipeableTableViewCell.h
//  RecipeApp
//
//  Created by clement gan on 15/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface CustomTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIButton *btnDelete;
@property (nonatomic, strong) IBOutlet UIButton *btnEdit;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UILabel *labelRecipeName;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewRecipe;
@property (nonatomic, strong) NSString *itemText;

- (IBAction)buttonClicked:(id)sender;


@end


