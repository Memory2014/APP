//
//  TextViewController.m
//  PhotoPRO
//
//  Created by zhong on 08/06/2017.
//  Copyright © 2017 zhongyi. All rights reserved.
//

#import "TextViewController.h"

@interface TextViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textView.font =  [UIFont systemFontOfSize:15];
    _textView.text = NSLocalizedString(@"Common File-Sharing Use Cases:\n1.We're on the same secure local network \n2.The local network File-Sharing only support IPv4.  \n\nEnabling File Sharing in Windows \n\nTo enable simple file sharing in Windows, head into the Control Panel and go to Network and Internet > Network and Sharing Center. \nHit Change Advanced Sharing Settings and make sure network discovery, file and printer sharing, and public folder sharing (the first three options) are all turned on. \nThen, head down the list and Turn off password protected sharing, and check 'Use user accounts and passwords to connect to other computers'. This is the easiest way to connect computers, and the most similar to the Mac method below.   \n\nEnabling File Sharing in Mac \n\nTo set up file sharing on a Mac, go to System Preferences and navigate to the Sharing preference pane. \nCheck the box marked 'File Sharing' and ensure that your public folder is listed under the shared folders. \nIf you expect you'll need to share with any Windows computers, hit the Options button and mark the 'Share Files and Folders Using SMB' box, as well as the box below it that corresponds to your username.\nYou can place a file in your Public folder for them to view and copy.", nil);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
