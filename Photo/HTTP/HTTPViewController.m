//
//  HTTPViewController.m
//  MyPhotos
//
//  Created by zhongyi on 15/12/11.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import "HTTPViewController.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"
#import "IPHelper.h"
#import "DetailViewController.h"
#import "ZYKeyValueObserver.h"
#import "Utill.h"

#import "FBShimmeringLayer.h"
#import "FBShimmeringView.h"
#import "StrokeCircleLayerConfigure.h"
#import "CircleView.h"


static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@class HTTPServer;

@interface HTTPViewController (){
    HTTPServer *httpServer;
}

@property (nonatomic,strong) id processObserve;     //进度

@property (nonatomic, strong) CircleView  *circleView1;
@property (nonatomic, strong) CircleView  *circleView2;
@property (nonatomic, strong) FBShimmeringView *shimmeringView;

@end

@implementation HTTPViewController{
    UILabel *percent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self startHTTP];
    [self initBlankView];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    //UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)];
    
    NSArray *itemArray = [NSArray arrayWithObjects:modalButton, nil];
    [self.navigationItem setRightBarButtonItems:itemArray animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postStart) name:@"photo_data_post" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEnd) name:@"photo_data_post_end" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDoing:) name:@"photo_data_post_length" object:nil];
    
    
    [[ UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [httpServer stop:YES];
    //DDLogInfo(@"start end",nil);
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

#pragma mark -- handleNotification

- (void)postStart{
}

- (void)postEnd{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self endProcess];
    });
    
}

- (void)postDoing:(NSNotification *)notification{
    NSDictionary *diction = notification.userInfo;
    NSString *percents = diction[@"percent"];
    //[self updateProcessView:percents];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        percent.text = percents;
        [self updateProcessView:percents];
    });
}

#pragma mark -- IBAction

- (IBAction)doCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)onCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)infoButtonAction{
    
    //DetailViewController *detailViewControl = [[DetailViewController alloc] init];
    
    DetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    [self.navigationController  pushViewController:controller animated:YES];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -- observer

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    
}

#pragma mark -- backview

- (void)initBlankView{
    
    NSString *ip;
    if ([IPHelper isIpv6]) {
        ip = [NSString stringWithFormat:@"%@%@%@",@"http://[",[IPHelper getIPAddress:NO],@"]:5000"];
    }else{
        ip = [NSString stringWithFormat:@"%@%@%@",@"http://",[IPHelper getIPAddress:YES],@":5000"];
    }
    
    UIColor *greenColor = [UIColor colorWithRed:21/255.0 green:173/255.0 blue:102/255 alpha:1.0];
    
    _labelIP.text            = NSLocalizedString(@"Enter this URL in your computer’s browser. (Leave the page ,the server will disable automatically)", nil);
    _labelStatic.text        = NSLocalizedString(ip, nil);
    
    _labelIP.textColor         = [UIColor grayColor];   //colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    _labelIP.textAlignment     = NSTextAlignmentCenter;
    _labelIP.numberOfLines     = 5;
    _labelIP.font = [UIFont fontWithName:@"Avenir-Medium" size:15];
    
    _labelStatic.textColor         = greenColor;   //colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    _labelStatic.textAlignment     = NSTextAlignmentCenter;
    _labelStatic.numberOfLines     = 5;
    _labelStatic.font = [UIFont fontWithName:@"Avenir-Medium" size:15];
    
    {
        _shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0, 0, self.viewSub.frame.size.width - 50, self.viewSub.frame.size.height -50)];
        _shimmeringView.shimmering                  = NO;
        _shimmeringView.shimmeringBeginFadeDuration = 0.3;
        _shimmeringView.shimmeringOpacity           = 0.9;
        _shimmeringView.shimmeringPauseDuration     = 0.6f;
        _shimmeringView.shimmeringDirection         = FBShimmerDirectionUp;
        _shimmeringView.center = CGPointMake(self.viewSub.bounds.size.width/2, self.viewSub.bounds.size.height/2);
        _shimmeringView.tintColor = greenColor;
        
        UIImageRenderingMode renderingMode = UIImageRenderingModeAlwaysTemplate;
        UIImage *image = [[UIImage imageNamed:@"wifi"] imageWithRenderingMode:renderingMode];
        //UIImage * __weak image = [[UIImage imageNamed:@"wifi"] imageWithRenderingMode:renderingMode];
        
        UIImageView *titleImage = [[UIImageView alloc] initWithImage:image];
        titleImage.contentMode =  UIViewContentModeScaleAspectFit;//UIViewContentModeCenter;
        titleImage.backgroundColor = [UIColor clearColor];
        titleImage.frame = _shimmeringView.frame;
        titleImage.center = _shimmeringView.center;
        
        _shimmeringView.contentView = titleImage;
        _shimmeringView.shimmering = YES;
        _shimmeringView.shimmeringAnimationOpacity = .2;
        _shimmeringView.shimmeringSpeed = 150;
        _shimmeringView.tintColor = greenColor;
        
        [self.viewSub addSubview:_shimmeringView];
        
//        NSLog(@"%@",NSStringFromCGRect(_viewSub.frame));
//        NSLog(@"%@",NSStringFromCGRect(_viewSub.bounds));
//        NSLog(@"%@",NSStringFromCGRect(shimmeringView.frame));
//        NSLog(@"%@",NSStringFromCGRect(shimmeringView.bounds));
//        NSLog(@"%@",NSStringFromCGRect(titleImage.frame));
//        NSLog(@"%@",NSStringFromCGRect(titleImage.bounds));
//        NSLog(@"%@",NSStringFromCGPoint(_viewSub.center));
//        NSLog(@"%@",NSStringFromCGPoint(shimmeringView.center));
//        NSLog(@"%@",NSStringFromCGPoint(titleImage.center));
    }
    
    {
//        FBShimmeringLayer *shimmeringLayer          = [FBShimmeringLayer layer];
//        shimmeringLayer.frame                       = self.viewSub.bounds;
//        shimmeringLayer.position                    = CGPointMake(self.viewSub.bounds.size.width/2, self.viewSub.bounds.size.height/2);
//        shimmeringLayer.shimmering                  = YES;
//        shimmeringLayer.shimmeringBeginFadeDuration = 0.3;
//        shimmeringLayer.shimmeringOpacity           = 0.9;
//        shimmeringLayer.shimmeringDirection         = FBShimmerDirectionUp;
//        shimmeringLayer.shimmeringPauseDuration     = 0.6f;
//        
//        [self.viewSub.layer addSublayer:shimmeringLayer];
//        
//        CAShapeLayer *circleShape          = [CAShapeLayer layer];
//        StrokeCircleLayerConfigure *config = [StrokeCircleLayerConfigure new];
//        config.lineWidth                   = 3.f;
//        config.startAngle                  = 0;
//        config.endAngle                    = M_PI * 2;
//        config.radius                      = 65.f;
//        config.strokeColor                 = [UIColor redColor];
//        [config configCAShapeLayer:circleShape];
//        shimmeringLayer.contentLayer = circleShape;
        
//        NSLog(@"%@",NSStringFromCGPoint(shimmeringLayer.position));
//        NSLog(@"%@",NSStringFromCGPoint(shimmeringLayer.anchorPoint));
//        NSLog(@"%@",NSStringFromCGRect(_viewSub.bounds));
//        NSLog(@"%@",NSStringFromCGRect(shimmeringLayer.frame));
//        NSLog(@"%@",NSStringFromCGRect(shimmeringLayer.bounds));
        
    }
    
    // 圆圈1
    self.circleView1 = [CircleView circleViewWithFrame:CGRectMake(0, 0, self.viewSub.frame.size.width, self.viewSub.frame.size.height)
                                             lineWidth:5
                                             lineColor:greenColor
                                             clockWise:YES
                                            startAngle:0];
    [self.circleView1 buildView];
    self.circleView1.center = CGPointMake(self.viewSub.bounds.size.width/2, self.viewSub.bounds.size.height/2);
    [self.viewSub addSubview:self.circleView1];
    
//    NSLog(@"%@",NSStringFromCGRect(_circleView1.frame));
//    NSLog(@"%@",NSStringFromCGRect(_circleView1.bounds));
//    NSLog(@"%@",NSStringFromCGPoint(_circleView1.center));
    
//    CGFloat percentCircle        = arc4random() % 100 / 100.f;
//    CGFloat anotherPercent = arc4random() % 100 / 100.f;
    
    
        //QuadraticEaseIn  CubicEaseIn QuarticEaseIn QuinticEaseIn SineEaseIn CircularEaseIn  ExponentialEaseIn BackEaseIn BounceEaseIn
        // 圆圈1动画
        [self.circleView1 strokeEnd:1.0 animationType:BounceEaseOut animated:YES duration:6.f];
        
//        // 圆圈3动画
//        [self.circleView2 strokeStart:(percentCircle < anotherPercent ? percentCircle : anotherPercent)
//                        animationType:ExponentialEaseInOut
//                             animated:YES duration:1.f];
//        [self.circleView2 strokeEnd:(percentCircle < anotherPercent ? anotherPercent : percentCircle)
//                      animationType:ExponentialEaseInOut
//                           animated:YES duration:1.f];
//        
//        percentCircle        = arc4random() % 100 / 100.f;
//        anotherPercent = arc4random() % 100 / 100.f;
}

- (void)updateProcessView:(NSString*)process {

    //[self.viewSub removeFromSuperview];
    
    {
        _shimmeringView.shimmering                  = YES;
    }
    
    {
        // 圆圈1动画
        [self.circleView1 strokeEnd:[process floatValue] animationType:BounceEaseOut animated:YES duration:3.f];
    }
}

- (void)endProcess{
    _shimmeringView.shimmering = NO;
    [self.circleView1 strokeEnd:1 animationType:ElasticEaseInOut animated:YES duration:1.f];
}


- (UIColor *)randomColor {
    
    return [UIColor colorWithRed:arc4random() % 101 / 100.f
                           green:arc4random() % 101 / 100.f
                            blue:arc4random() % 101 / 100.f
                           alpha:1];
}


#pragma mark -- HTTP

- (void)startServer
{
    // Start the server (and check for problems)
    NSError *error;
    if([httpServer start:&error])
    {
        //DDLogInfo(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
    }
    else
    {
        //DDLogError(@"Error starting HTTP Server: %@", error);
    }
}


- (void)createAndCheckDatabase: (NSString *)fileName
{
    //NSString *filename = @"file.ext";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *filePath = [documentDir stringByAppendingPathComponent:fileName];
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:filePath];
    
    NSError *err;
    if (success){
        [fileManager removeItemAtPath:filePath error:&err];  //removeItemAtURL:url error:&error];
    };
    
    NSString *filePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    [fileManager copyItemAtPath:filePathFromApp toPath:filePath error:&err];
    
    //NSLog(@"%@",err);
    //[fileManager copyItemAtURL:filePathFromApp toURL:filePath error:&err];
}

- (void)deleteDatabase: (NSString *)fileName
{
    //NSString *filename = @"file.ext";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *filePath = [documentDir stringByAppendingPathComponent:fileName];
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:filePath];
    
    NSError *err;
    if (success){
        [fileManager removeItemAtPath:filePath error:&err];  //removeItemAtURL:url error:&error];
    };
}


- (void)startHTTP{
    
    //http server
    // Configure our logging framework.
    // To keep things simple and fast, we're just going to log to the Xcode console.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Create server using our custom MyHTTPServer class
    httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:5000];
    
    // Serve files from our embedded Web folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *imageDirectory = [documentsDirectory stringByAppendingPathComponent:@""];
    //DDLogInfo(@"Setting document root: %@", imageDirectory);
    
    NSError *error = nil;
//    if (![[NSFileManager defaultManager] copyItemAtPath:webPath toPath:imageDirectory error:&error]) {
//        NSLog(@"Error: %@", error);;
//    }
    
    //copy the file to App directory
    
    NSString *language = [self getPreferredLanguage];
    
    if ([language hasPrefix:@"zh"] ) {
        [self deleteDatabase:@"index.html"];
        [self createAndCheckDatabase:@"indexch.html"];
    }else{
        [self createAndCheckDatabase:@"index.html"];
    }

    [self createAndCheckDatabase:@"upload.html"];
    [self createAndCheckDatabase:@"d.m.js"];
    [self createAndCheckDatabase:@"dm.css"];

    [httpServer setDocumentRoot:imageDirectory];
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    
    if(![httpServer start:&error])
    {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
    
    //DDLogInfo(@"start http",nil);
    
}


- (NSString*)getPreferredLanguage {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    //NSLog(@"Preferred Language:%@", preferredLang);
    return preferredLang;
}

@end
