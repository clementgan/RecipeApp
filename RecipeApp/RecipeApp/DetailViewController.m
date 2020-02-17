//
//  DetailViewController.m
//  RecipeApp
//
//  Created by clement gan on 16/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import "DetailViewController.h"
#import "FMDB.h"
#import "CategoryPickerViewController.h"
#import "PublicMethod.h"

@interface DetailViewController ()
{
    NSString *selectedRecipeID,*selectedCategoryID;
    NSData *imageData;
    NSString *selectedImageName;
    NSArray *paths;
    NSString *documentsDirectory;
    NSString *filePath;
    NSString *itemImageName;
    NSString *imagePath;
}

@end

@implementation DetailViewController

@synthesize mode = _mode;
@synthesize arrayAllCategory = _arrayAllCategory;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textName.delegate = self;
    self.textCategory.delegate = self;
    self.textIngredient.delegate = self;
    self.textInstruction.delegate = self;
    selectedRecipeID = [self.mode isEqualToString:@"add"] ? nil : self.recipeID;
    selectedCategoryID = @"";
    selectedImageName = @"";
    self.textCategory.text = [[self.arrayAllCategory firstObject] valueForKey:@"name"];
    NSLog(@"check received array : %@",self.arrayAllCategory);
    
    self.textIngredient.backgroundColor = [UIColor lightGrayColor];
    self.textInstruction.backgroundColor = [UIColor lightGrayColor];
    
    /*----- image view -----*/
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    self.imageViewRecipe.userInteractionEnabled = true;
    self.imageViewRecipe.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnCamera)];
    [self.imageViewRecipe addGestureRecognizer:tapImage];
    
    
    
    [self switchAction:self.mode];
    
    if([self.mode isEqualToString:@"view"]) {
        [self executeQuery];
    }
}

-(void)switchAction:(NSString *)mode
{
    [self.navigationItem setRightBarButtonItems:nil];
    if([mode isEqualToString:@"view"]) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(btnEditPressed:)];
        self.navigationItem.rightBarButtonItem = editButton;
    }
    else {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnDonePressed:)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    self.textName.enabled = ([mode isEqualToString:@"view"]) ? NO : YES;
    self.textIngredient.editable = ([mode isEqualToString:@"view"]) ? NO : YES;
    self.textInstruction.editable = ([mode isEqualToString:@"view"]) ? NO : YES;
    self.imageViewRecipe.alpha = ([mode isEqualToString:@"view"]) ? 0.6 : 1.0;
}

-(void)btnEditPressed:(id)sender
{
    [self switchAction:@"edit"];
    self.mode = @"edit";
    self.btnRemovePhoto.hidden = [selectedImageName containsString:@"AddPhoto"] ? YES : selectedImageName.length > 0 ? NO : YES;
}

-(void)btnDonePressed:(id)sender
{
    [self executeQuery];
    
//    if(!_delegate) {
//        [_delegate doneButtonPressed];
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - sqlite

-(void)executeQuery
{
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"RecipeApp.db"];
    FMDatabaseQueue *dBQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    NSString *rcpName, *rcpIngredient, *rcpInstruction, *rcpImageName;
    
    rcpName = self.textName.text;
    rcpIngredient = self.textIngredient.text;
    rcpInstruction = self.textInstruction.text;
    rcpImageName = selectedImageName;
    NSLog(@"check recipeID value : %@",self.recipeID);
    if([self.mode isEqualToString:@"add"])
    {
        imagePath = [documentsDirectory stringByAppendingPathComponent:selectedImageName];
        NSLog(@"[add] imgPath : %@", imagePath);
        [imageData writeToFile:imagePath atomically:YES];
        
        [dBQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            [db executeUpdate:@"INSERT INTO Recipe (RCP_Name, RCP_Ingredient, RCP_Instruction, RCP_Image, RCP_CategoryID) VALUES (?,?,?,?,?)",
             rcpName,rcpIngredient,rcpInstruction,rcpImageName,selectedCategoryID];
        }];
        [dBQueue close];
    }
    else if([self.mode isEqualToString:@"edit"])
    {
        imagePath = [documentsDirectory stringByAppendingPathComponent:selectedImageName];
        NSLog(@"[update] imgPath : %@", imagePath);
        [imageData writeToFile:imagePath atomically:YES];
        
        [dBQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            [db executeUpdate:@"UPDATE Recipe SET RCP_Name=?, RCP_Ingredient=?, RCP_Instruction=?, RCP_Image=?, RCP_CategoryID=? WHERE RCP_ID=?",
             rcpName,rcpIngredient,rcpInstruction,rcpImageName,selectedCategoryID,selectedRecipeID];
        }];
        [dBQueue close];
    }
    else {
        [dBQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            FMResultSet *rsRecipe = [db executeQuery:@"SELECT * FROM Recipe WHERE RCP_ID=?",selectedRecipeID];
            if ([rsRecipe next]) {
                self.textName.text = [rsRecipe stringForColumn:@"RCP_Name"];
                self.textIngredient.text = [rsRecipe stringForColumn:@"RCP_Ingredient"];
                self.textInstruction.text = [rsRecipe stringForColumn:@"RCP_Instruction"];
                selectedImageName = [rsRecipe stringForColumn:@"RCP_Image"];
                
                if(![selectedImageName containsString:@"AddPhoto"]) {
                    filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[rsRecipe stringForColumn:@"RCP_Image"]]];
                    self.imageViewRecipe.image = [UIImage imageWithContentsOfFile:filePath];
                    self.btnRemovePhoto.hidden =  NO;
                }
                else {
                    self.btnRemovePhoto.hidden = YES;
                }
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id.intValue = %d", [rsRecipe intForColumn:@"RCP_CategoryID"]];
                NSArray *arrayFilteredCategory = [self.arrayAllCategory filteredArrayUsingPredicate:predicate];
                self.textCategory.text = [[arrayFilteredCategory firstObject]valueForKey:@"name"];
                selectedCategoryID = [[arrayFilteredCategory firstObject]valueForKey:@"id"];
            }
            [rsRecipe close];
        }];
        [dBQueue close];
    }
}


#pragma mark - delegate

-(void)getCategoryWithID:(NSString *)categoryId Name:(NSString *)categoryName
{
    [self dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"[DetailVC] you selected category id : %@, name : %@", categoryId, categoryName);
    
    selectedCategoryID = categoryId;
    [self.textCategory setText:categoryName];
    //[self.btnCategory setTitle:categoryName forState:UIControlStateNormal];
}


#pragma mark - textfield event

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.textCategory) {
        [self.view endEditing:YES];
        
        CategoryPickerViewController *categoryPicker = [CategoryPickerViewController new];
        categoryPicker.delegate = self;
        categoryPicker.arrayAllCategory = self.arrayAllCategory;
        categoryPicker.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:categoryPicker animated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.textName)
    {
        if ([string length] == 0) {
            return YES;
        }
        
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"'\"‘’“”"] invertedSet];
        NSString *escapedString = [[string componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
        return ![string isEqualToString:escapedString];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    //NSLog(@"textViewShouldBeginEditing:");
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text length] == 0) {
        return YES;
    }
    
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"'\"‘’“”"] invertedSet];

    NSString *escapedString = [[text componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    return ![text isEqualToString:escapedString];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    //NSLog(@"textViewShouldEndEditing:");
    return YES;
}

#pragma mark - image picker

- (void)btnCamera
{
    if(![self.mode isEqualToString:@"view"])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = NO;
        picker.delegate = self;
        
        picker.modalPresentationStyle = UIModalPresentationPopover;
        picker.popoverPresentationController.sourceView = self.imageViewRecipe;
        picker.popoverPresentationController.sourceRect = CGRectMake(0, 0, 170, 250);
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[PublicMethod sharedInstance]getDateFormaterhh_mm];

//    selectedImageName = @"TestImageName";
    selectedImageName = [NSString stringWithFormat:@"%@_%@.jpg",self.textName.text,[dateFormat stringFromDate:today]];
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    self.imageCropping = chosenImage;
    self.imageViewRecipe.image = self.imageCropping;
    self.imageViewRecipe.clipsToBounds = YES;
    
    imageData = UIImageJPEGRepresentation(chosenImage,0.5);
    
    self.btnRemovePhoto.hidden = NO;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
//    self.buttonRemovePhoto.enabled = YES;
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnRemovePhoto:(id)sender
{
    if(![self.mode isEqualToString:@"view"])
    {
        UIAlertController *alert = [UIAlertController
                                     alertControllerWithTitle:@"Warning"
                                     message:@"Sure To remove ?"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self removePhoto];
                                    }];
        
        UIAlertAction *noButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //do nothing
                                   }];
        
        [alert addAction:noButton];
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)removePhoto
{
    [self removeExistingFileFromDirectoryWithFileName:selectedImageName];
    
    self.btnRemovePhoto.hidden = YES;
    self.imageViewRecipe.image = [UIImage imageNamed:@"AddPhoto.jpg"];
    
    imageData = nil;
    selectedImageName = nil;

}

-(void)removeExistingFileFromDirectoryWithFileName:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsPath,fileName];
    NSError *error;
    
    if([fileManager fileExistsAtPath:filePath])
    {
        [fileManager removeItemAtPath:filePath error:&error];
    }
}


@end
