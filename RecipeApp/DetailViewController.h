//
//  DetailViewController.h
//  RecipeApp
//
//  Created by clement gan on 16/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryPickerViewController.h"

@protocol DetailDoneButtonDelegate<NSObject>
@required
-(void)doneButtonPressed;
@end

@interface DetailViewController : UIViewController <UITextFieldDelegate, CategoryPickerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (nonatomic,weak) id <DetailDoneButtonDelegate> delegate;

@property NSString *recipeID;
@property NSString *mode;
@property (nonatomic, strong) NSArray *arrayAllCategory;


@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UITextField *textCategory;
@property (weak, nonatomic) IBOutlet UITextView *textIngredient;
@property (weak, nonatomic) IBOutlet UITextView *textInstruction;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewRecipe;
@property (nonatomic, strong) UIImage *imageCropping; 
@property (weak, nonatomic) IBOutlet UIButton *btnRemovePhoto;
- (IBAction)btnRemovePhoto:(id)sender;

@end


