//
//  WebViewController.m
//  PhotoPRO
//
//  Created by zhong on 13/03/2017.
//  Copyright © 2017 zhongyi. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "WebViewController.h"


@interface WebViewController ()<WKUIDelegate,WKNavigationDelegate>

//@property (nonatomic, strong) NSArray *menuTitles;
//@property (nonatomic, strong) NSArray *menuIcons;

@property (nonatomic, strong) WKWebView *web;
@property (strong, nonatomic) NSString *articleTitle;

@property (weak, nonatomic) IBOutlet UIView *webWrap;


@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    //[self loadWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    
    [self unLoadWebView];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadWebView];
}


- (void)loadWebView{
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    _web = [[WKWebView alloc]initWithFrame:self.webWrap.bounds configuration:config];
    
    _web.navigationDelegate = self;
    _web.UIDelegate = self;

    [_web loadRequest:[NSURLRequest requestWithURL:self.url]];
    _web.allowsBackForwardNavigationGestures = YES;
    
    [_web evaluateJavaScript:@"var nodes = document.getElementsByClassName('s-footer-logo-wechat');for(var i = 0; i < nodes.length; i++){nodes[i].parentNode.removeChild(nodes[i]);} " completionHandler:^(id item, NSError * _Nullable error){
       //NSLog(@"%@", item);
    }];
    
    
    [self.webWrap addSubview:_web];
}

- (void)unLoadWebView{
    //[_web removeObserver:self forKeyPath:@"loading"];
    //[_web removeObserver:self forKeyPath:@"estimatedProgress"];
}




//- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ __nullable)(__nullable id, NSError * __nullable error))completionHandler;


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    NSLog(@"%@",error);
    //error.userInfo[@"NSErrorFailingURLStringKey"]
}


- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    //NSLog(@"%s%@", __FUNCTION__ , error);
    [self showNotAllowed];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    [_web evaluateJavaScript:@"var nodes = document.getElementsByClassName('s-footer-logo-wechat');for(var i = 0; i < nodes.length; i++){nodes[i].parentNode.removeChild(nodes[i]);} " completionHandler:^(id item, NSError * _Nullable error){
        NSLog(@"%@", item);
    }];
    
}

- (void)showNotAllowed{
    //self.title              = nil;
    
    UIView *lockedView      = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImageView *locked     = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi"]];
    locked.contentMode      = UIViewContentModeCenter;
    locked.tintColor = [UIColor lightGrayColor];
    
    CGRect rect             = CGRectInset(self.view.bounds, 8, 8);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    //UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    title.text              = NSLocalizedString(@"Internet connection appears to be offline", nil);
    //title.font              = [UIFont boldSystemFontOfSize:17.0];
    title.textColor         = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    title.font              = [UIFont fontWithName:@"PingFangHK-Medium" size:19];
    [title sizeToFit];
    
    locked.center           = CGPointMake(lockedView.center.x, lockedView.center.y - locked.bounds.size.height /2 - 20);
    title.center            = locked.center;
    
    rect                    = title.frame;
    rect.origin.y           = locked.frame.origin.y + locked.frame.size.height + 10;
    title.frame             = rect;

    
    [lockedView addSubview:locked];
    [lockedView addSubview:title];
    [self.view addSubview:lockedView];
}

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
//    
//    NSLog(@"%@",navigationResponse.response.URL.host.lowercaseString);
//    
//    decisionHandler(WKNavigationResponsePolicyAllow);
//    return;
//    // 如果响应的地址是百度，则允许跳转
//    //    if ([navigationResponse.response.URL.host.lowercaseString isEqual:@"www.baidu.com"]) {
//    //
//    //        // 允许跳转
//    //        decisionHandler(WKNavigationResponsePolicyAllow);
//    //        return;
//    //    }
//    //    // 不允许跳转
//    //    decisionHandler(WKNavigationResponsePolicyCancel);
//}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    
//    NSLog(@"%@",navigationAction.request.URL.host.lowercaseString);
//    
//    if (!navigationAction.targetFrame.isMainFrame) {
//        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
//    }
//    
//    decisionHandler(WKNavigationActionPolicyAllow);
//    return;
//    
//}


@end
