//
//  SetPasswordViewController.m
//  Photo
//
//  Created by zhongyi on 16/1/2.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "SetPasswordViewController.h"
#import "FileDataOperation.h"

@interface SetPasswordViewController ()<UITextFieldDelegate>

@end

@implementation SetPasswordViewController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panRecognizer];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.Settitle.font = [UIFont fontWithName:@"PingFangHK-Medium" size:20];
    self.Settitle.text = NSLocalizedString(@"Set Password", nil);
    self.Settitle.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    self.Settitle.textAlignment = NSTextAlignmentCenter;
    
    
    self.noteLabel.font = [UIFont fontWithName:@"PingFangHK-Light" size:15];
    self.noteLabel.text = NSLocalizedString(@"NOTE: App does not have the ability to store contents online, so we won't be able to help you recover contents if you forget the password you used.", nil);
    self.noteLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    self.noteLabel.textAlignment = NSTextAlignmentCenter;
    self.noteLabel.numberOfLines   = 5;
    
    self.firstTextField.placeholder = NSLocalizedString(@"Password for private album", );
    self.firstTextField.secureTextEntry = YES;
    self.firstTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.firstTextField.returnKeyType = UIReturnKeyNext;
    self.firstTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.firstTextField.clearsOnBeginEditing = YES;
    self.firstTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.SencondTextField.placeholder = NSLocalizedString(@"Password Confirmation", nil);
    self.SencondTextField.secureTextEntry = YES;
    self.SencondTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.SencondTextField.returnKeyType = UIReturnKeyGo;
    self.SencondTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.SencondTextField.clearsOnBeginEditing = YES;
    self.SencondTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.doneButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    self.doneButton.layer.cornerRadius = 5;
    self.doneButton.backgroundColor= [UIColor colorWithRed:0.8471 green:0.8471 blue:0.8471 alpha:1];
    self.doneButton.enabled = false;
    
    
    self.firstTextField.delegate = self;
    self.SencondTextField.delegate = self;
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Pan
- (void)pan:(UIPanGestureRecognizer*)recognizer{
}


#pragma mark -- textfile Delegate


- (void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"textFieldDidEndEditing");
    
    NSString *newPassword = nil;
    NSString *reNewPassword = nil;
   if (textField.tag == 2){
        reNewPassword = self.SencondTextField.text;
        newPassword = self.firstTextField.text;
        
        if (![newPassword isEqual:reNewPassword]) {
            [self enalbeButton:false];
        }else if ([newPassword isEqual:@""]){
            [self enalbeButton:false];
        }else{
            [self enalbeButton:true];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


#pragma mark --button action

- (void)enalbeButton:(BOOL) enable{
    
    if (enable) {
        self.doneButton.enabled = true;
        self.doneButton.backgroundColor= [UIColor colorWithRed:0.2039 green:0.6588 blue:0.3255 alpha:1];
    }else{
        self.doneButton.backgroundColor= [UIColor colorWithRed:0.8471 green:0.8471 blue:0.8471 alpha:1];
        self.doneButton.enabled = false;
    }
}

//ToAppHome

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneAction:(id)sender {
    
    NSString *password = self.SencondTextField.text;
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self SetPrivateDirectory];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -- setDirectory
- (void)SetPrivateDirectory{
    FileDataOperation *operation = [[FileDataOperation alloc] init];
    [operation createPrivateDirectory];
}

@end
