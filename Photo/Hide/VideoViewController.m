//
//  VideoViewController.m
//  PhotoPRO
//
//  Created by zhong on 8/18/16.
//  Copyright © 2016 zhongyi. All rights reserved.
//

#import "VideoViewController.h"
//#import "KrVideoPlayerController.h"

@interface VideoViewController ()

//@property (nonatomic, strong) KrVideoPlayerController  *videoController;

@end

@implementation VideoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self playVideo];
}
- (void)playVideo{
    NSURL *url = self.video[@"video"]; //[NSURL URLWithString:@"http://krtv.qiniudn.com/150522nextapp"];
    [self addVideoPlayerWithURL:url];
}

- (void)addVideoPlayerWithURL:(NSURL *)url{
//    if (!self.videoController) {
//        CGFloat width = [UIScreen mainScreen].bounds.size.width;
//        self.videoController = [[KrVideoPlayerController alloc] initWithFrame:CGRectMake(0, 64, width, width*(9.0/16.0))];
//        __weak typeof(self)weakSelf = self;
//        [self.videoController setDimissCompleteBlock:^{
//            weakSelf.videoController = nil;
//        }];
//        [self.videoController setWillBackOrientationPortrait:^{
//            [weakSelf toolbarHidden:NO];
//        }];
//        [self.videoController setWillChangeToFullscreenMode:^{
//            [weakSelf toolbarHidden:YES];
//        }];
//        [self.view addSubview:self.videoController.view];
//    }
//    self.videoController.contentURL = url;
//    
}
//隐藏navigation tabbar 电池栏
- (void)toolbarHidden:(BOOL)Bool{
    self.navigationController.navigationBar.hidden = Bool;
    self.tabBarController.tabBar.hidden = Bool;
    [[UIApplication sharedApplication] setStatusBarHidden:Bool withAnimation:UIStatusBarAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
