//
//  MovieViewController.m
//  PhotoPRO
//
//  Created by zhong on 25/05/2017.
//  Copyright © 2017 zhongyi. All rights reserved.
//

#import "MovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MovieListCell.h"
#import "PlayerViewController.h"
#import "JRSoundView.h"
#import "WebViewController.h"

//#include <NetFS/NetFS.h>

@interface MovieViewController (){
    MPMediaQuery * _movieQuery;
    NSArray * _movieArray;
}

@property (nonatomic,strong) MPMediaQuery *movieQuery;
@property (nonatomic,strong) NSArray *movieArray;

@end

@implementation MovieViewController

@synthesize movieQuery = _movieQuery,movieArray = _movieArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationButton];
    
	[JRSoundView sharedSoundView];
    [self checkMediaLibraryPermissions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NavigationButton

- (void)addNavigationButton {
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.rightBarButtonItem = modalButton;
}

- (void)openLink{
    
    NSURL *url;
    NSString *language = [self getPreferredLanguage];
    if ([language hasPrefix:@"zh"] ) {
        url = [[NSURL alloc] initWithString:@"https://support.apple.com/zh-cn/HT201253"];
    }else{
        url = [[NSURL alloc] initWithString:@"https://support.apple.com/en-us/HT201253"];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController  *webControl = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webControl.url = url;
    [self.navigationController pushViewController:webControl animated:NO];
}

- (NSString*)getPreferredLanguage {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    //NSLog(@"Preferred Language:%@", preferredLang);
    return preferredLang;
}

- (void)infoButtonAction {
    [self openLink];
}

#pragma mark Media Check

- (void) checkMediaLibraryPermissions {
    
    __weak typeof(self) weakSelf = self;
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
        
        if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
            [weakSelf checkMovie];
        }else{
            [weakSelf showNotAllowed];
        }
    }];
}

- (void)checkMovie {
    
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeAnyVideo] forProperty:MPMediaItemPropertyMediaType];
    
    self.movieQuery = [[MPMediaQuery alloc] init];
    [_movieQuery addFilterPredicate:predicate];
    
    //NSLog(@"movieQuery got back %lu results",[[self.movieQuery items]count]);
    [self showBackView];
    
    self.movieArray = [self.movieQuery items];
    [self.tableView reloadData];
}

- (void)showNotAllowed{
    //self.title              = nil;
    
    UIView *lockedView      = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImageView *locked     = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_video"]];
    locked.contentMode      = UIViewContentModeCenter;
    locked.tintColor = [UIColor lightGrayColor];
    
    CGRect rect             = CGRectInset(self.view.bounds, 8, 8);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    //UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    title.text              = NSLocalizedString(@"The app may not access the video in the phone media library.", nil);
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
    self.tableView.backgroundView = lockedView;
}

- (void)showBackView{
    //self.title              = nil;
    
    UIView *lockedView      = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImageView *locked     = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_video"]];
    locked.contentMode      = UIViewContentModeCenter;
    locked.tintColor = [UIColor lightGrayColor];
    
    CGRect rect             = CGRectInset(self.view.bounds, 8, 8);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    //UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    title.text              = NSLocalizedString(@"No video in the phone media library.", nil);
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
    self.tableView.backgroundView = lockedView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.movieArray.count > 0) {
        self.tableView.backgroundView.hidden = YES;
    } else {
        self.tableView.backgroundView.hidden = NO;
    }
    return self.movieArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieListCell" forIndexPath:indexPath];
    
    MPMediaItem *item = [self.movieArray objectAtIndex:[indexPath row]];
    cell.textLabel.text =  item.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PlayerViewController *player = [[PlayerViewController alloc] init];
    player.hidesBottomBarWhenPushed = YES;
    
    MPMediaItem *item = [self.movieArray objectAtIndex:[indexPath row]];
    NSString *name =  item.title;
    NSURL *url = item.assetURL;
    NSTimeInterval time = item.playbackDuration;
    NSString *videoTime = [NSString stringWithFormat:@"%f", time];
    
    player.video = @{@"title":name,
                     @"video":url,
                     @"duration" : videoTime
                     };
    
    [self.navigationController pushViewController:player animated:YES];
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
