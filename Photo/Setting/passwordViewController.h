//
//  passwordViewController.h
//  PhotoView
//
//  Created by zhongyi on 15/9/27.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PAPasscodeViewController.h"


@interface passwordViewController : UIViewController<UITextFieldDelegate>   //<PAPasscodeViewControllerDelegate>

//@property (weak, nonatomic) IBOutlet UILabel *passcodeLabel;
//@property (weak, nonatomic) IBOutlet UISwitch *simpleSwitch;
//
//- (IBAction)setPasscode:(id)sender;
//- (IBAction)enterPasscode:(id)sender;
//- (IBAction)changePasscode:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *oldPassword;

@property (strong, nonatomic) IBOutlet UITextField *nePassword;

@property (strong, nonatomic) IBOutlet UITextField *rePassword;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *message;
- (IBAction)doDone:(id)sender;

@end
