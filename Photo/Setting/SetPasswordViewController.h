//
//  SetPasswordViewController.h
//  Photo
//
//  Created by zhongyi on 16/1/2.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetPasswordViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *Settitle;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UITextField *firstTextField;
@property (strong, nonatomic) IBOutlet UITextField *SencondTextField;

@property (strong, nonatomic) IBOutlet UILabel *noteLabel;
- (IBAction)doneAction:(id)sender;
@end
