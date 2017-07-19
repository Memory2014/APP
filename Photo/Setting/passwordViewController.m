//
//  passwordViewController.m
//  PhotoView
//
//  Created by zhongyi on 15/9/27.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import "passwordViewController.h"

#define TINCOLOR_AQUA  [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0]

@interface passwordViewController(){
    NSString *prePassword ;
    NSString *newPassword ;
    NSString *reNewPassword;
    NSString *password;
}


@end

@implementation passwordViewController


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.oldPassword.delegate = self;
    self.nePassword.delegate = self;
    self.rePassword.delegate = self;
    
    
    password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];  
    [self addObserverToNotificationCenter];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.oldPassword.placeholder = NSLocalizedString(@"Enter your old passcode", nil);
    self.nePassword.placeholder  = NSLocalizedString(@"Re-enter your new passcode", nil);
    self.rePassword.placeholder  = NSLocalizedString(@"Enter your new passcode", nil);
    
    self.oldPassword.returnKeyType = UIReturnKeyDone;
    self.nePassword.returnKeyType = UIReturnKeyDone;
    self.rePassword.returnKeyType = UIReturnKeyDone;
    
    //self.navigationController.navigationBar.tintColor = TINCOLOR_AQUA;
    self.navigationItem.title = NSLocalizedString(@"Set New Password", nil);
}

- (void)viewDidUnload {
    //[self setSimpleSwitch:nil];
    [super viewDidUnload];
    
    
    self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    //[self.]
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -- addObserver
-(void)addObserverToNotificationCenter{
    /*添加应用程序进入后台监听
     * observer:监听者
     * selector:监听方法（监听者监听到通知后执行的方法）
     * name:监听的通知名称(下面的UIApplicationDidEnterBackgroundNotification是一个常量)
     * object:通知的发送者（如果指定nil则监听任何对象发送的通知）
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification) name:
     UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}


- (void)handleNotification{
    
    [self postNotification];
}


-(void)postNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GO_HOME_APP" object:self userInfo:nil];
}


#pragma mark -- textfile Delegate


- (void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"textFieldDidEndEditing");
    
    if (textField.tag == 1) {
        prePassword = self.oldPassword.text;
        
        if (![prePassword isEqual:password]) {
            self.message.text = NSLocalizedString(@"Wrong passcode. Try again", nil);
        }else{
            self.message.text = NSLocalizedString(@"", nil);
        }
        
    }else if (textField.tag == 2){
        newPassword = self.nePassword.text;
        
    }else if (textField.tag == 3){
        reNewPassword = self.rePassword.text;
        newPassword = self.nePassword.text;
        
        if (![newPassword isEqual:reNewPassword]) {
            self.messageLabel.text = NSLocalizedString(@"Passcodes did not match. Try again", nil);
        }else if ([newPassword isEqual:@""]){
           self.messageLabel.text = NSLocalizedString(@"passcode is empty", nil);
        }else{
            self.messageLabel.text = NSLocalizedString(@"", nil);
        }
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([newPassword isEqualToString:reNewPassword]) {
        self.messageLabel.text = NSLocalizedString(@"Passcodes did not match. Try again", nil);
    }else{
        self.messageLabel.text = NSLocalizedString(@"", nil);
    }
    return YES;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


- (IBAction)doDone:(id)sender {
    
    if ( ![prePassword isEqual:password]) {
        return;
    }
    
    
    if (![newPassword isEqual:reNewPassword]) {
        return;
    }else if ([newPassword isEqual:@""]){
        return;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:newPassword forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"photo_password_change" object:self];
        
        self.messageLabel.text = NSLocalizedString(@"save success", nil);
    }
    
    
    //[self dismissViewControllerAnimated:YES completion:nil];
 
    
    //[self performSegueWithIdentifier:@"toHide" sender:self];
    //[self.navigationController  popToRootViewControllerAnimated:YES];
}
@end
