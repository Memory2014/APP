//
//  HideSetViewController.m
//  PhotoPRO
//
//  Created by zhong on 28/02/2017.
//  Copyright © 2017 zhongyi. All rights reserved.
//

#import "HideSetViewController.h"
#import "Utill.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface HideSetViewController ()
    
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *guideLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UILabel *downLabel;
@property (weak, nonatomic) IBOutlet UILabel *TouchIDLabel;
@property (weak, nonatomic) IBOutlet UISwitch *TouchIDSwitch;

@end

@implementation HideSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Setting", nil);
    self.passwordLabel.text = NSLocalizedString(@"Set Password", nil);
    self.guideLabel.text = NSLocalizedString(@"Home Tutorial", nil);
    self.downLabel.text = NSLocalizedString(@"Get PrivatePhoto", nil);
    self.TouchIDLabel.text = NSLocalizedString(@"Touch ID", nil);
    
    NSString *appVersion = [[NSUserDefaults standardUserDefaults] stringForKey:SWITH_BUTTON];
    if ([appVersion isEqualToString:@"0"]) {
        [self.switchButton setOn:NO];
    }else{
        [self.switchButton setOn:YES];
    }
    
    NSString *touchOn = [[NSUserDefaults standardUserDefaults] stringForKey:TOUCH_BUTTON];
    if ([touchOn isEqualToString:@"1"]) {
        [self.TouchIDSwitch setOn:YES];
    }else{
        [self.TouchIDSwitch setOn:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchGuide:(id)sender {
    
    NSString *key = @"0";
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        [self.switchButton setOn:NO];
        key = @"0";
    }else {
        [self.switchButton setOn:YES];
        key = @"1";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:SWITH_BUTTON];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchTouchID:(id)sender {
    
    //UISwitch *touchButton = (UISwitch*)sender;
    BOOL isButtonOn = [self.TouchIDSwitch isOn];
    if (isButtonOn) {
        [self doTouchAuth];
    }else {
        [self.TouchIDSwitch setOn:NO];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:TOUCH_BUTTON];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)doTouchAuth
{
    LAContext *myContext = [[LAContext alloc] init];
    myContext.localizedFallbackTitle = NSLocalizedString(@"input password", nil); //@"输入密码";
    NSError *authError = nil;
    NSString *myLocalizedReasonString = NSLocalizedString(@"Use Touch ID to unlock your private photo", nil); //@"验证指纹 开启指纹解锁进入私密相册!";
    
    __weak typeof(self) weakSelf = self;
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError])
    {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if(success)
                                {
                                    //处理验证通过
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        //NSLog(@"%@", [NSThread currentThread]);
                                        [weakSelf.TouchIDSwitch setOn:YES];
                                    });
                                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:TOUCH_BUTTON];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSelf.TouchIDSwitch setOn:NO];
                                    });
                                    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:TOUCH_BUTTON];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }
                            }];
    }
    else
    {
        //不支持Touch ID验证，提示用户
        self.TouchIDSwitch.enabled = false;
    }
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
#ifdef PHOTO_APP_NOMARL
    return 4;
#else
    return 3;
#endif
    
}



- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
#ifdef PHOTO_APP_NOMARL
    if (section == 3) {
        
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 80)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 20, 50)];
        titleLabel.text =  NSLocalizedString(@"Get PrivatePhoto APP, you can import more photos and videos by Wi-Fi network, also you can get more Tools to Perfect Photos, and aslo No Ads.", nil);
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 4;
        titleLabel.font = [UIFont systemFontOfSize:12];
        [titleView addSubview:titleLabel];
        return titleView;
    }else
#endif
        if (section == 2){
            UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 40)];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 20, 30)];
            titleLabel.text =  NSLocalizedString(@"Use Touch ID to unlock your private photo", nil);
            titleLabel.textColor = [UIColor lightGrayColor];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.numberOfLines = 4;
            titleLabel.font = [UIFont systemFontOfSize:12];
            [titleView addSubview:titleLabel];
            return titleView;
        }else{
            return nil;
        }

}


#ifdef PHOTO_APP_NOMARL

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 3) {
        NSString *iTunesLink = ITUNESLINK_BUY_APP;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        
    }else{
        return;
    }
}

#endif

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
