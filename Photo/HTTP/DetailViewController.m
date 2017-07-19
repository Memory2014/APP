//
//  DetailViewController.m
//  MyPhotos
//
//  Created by zhongyi on 15/12/14.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _textView.contentSize = self.textView.frame.size;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _textView.font = [UIFont fontWithName:@"PingFangHK-Light" size:16];
    _textView.text = NSLocalizedString(@"1) Your computer and your phone need to be on the same local area (or wlan) network. \n2) No iTunes or cable needed.\n3) Supports the files with the .mov .mp4 .m4v and .jpg .jpeg .png filename extensions. \n4) You can transfer video files and unlimited photos by upgrading to the full version inside the app. \n5) Background transfer not supports. Data stored: Photo/PC or Video/PC. \n6) Browser support best : Safari 6+, Chrome 7+, Firefox 4+,IE 10+,Opera 12+ . For all the other browsers, dropzone provides an old way. \n7) Wireless Transfer does not use or transfer your files to any external server.It provides a completely private website to be accessed by only computers that are directly connected to your local WiFi network.", nil);
    
    //[self initBlankView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)shouldAutorotate{
//    return NO;
//}
//
//-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}


- (BOOL)prefersStatusBarHidden{
    return false;
}

@end
