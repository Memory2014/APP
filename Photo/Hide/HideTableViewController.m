//
//  HideTableViewController.m
//  PhotoView
//
//  Created by zhongyi on 15/9/22.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "HideTableViewController.h"
#import "MwPhotoBrowser.h"
#import "HideViewCell.h"
#import "FileDataOperation.h"
//#import "RNFrostedSidebar.h"
#import "passwordViewController.h"
#import "HideVideoTableViewController.h"
#import "TGCameraViewController.h"  //camera
#import "TGCameraColor.h"
#import "Utill.h"
#import "MasterViewController.h"
#import "HidePhotoCollectionViewController.h"

#import "HideVideoTableViewController.h"
#import "passwordViewController.h"
#import "HTTPViewController.h"
#import "MasterViewController.h"
#import "ColorArray.h"
#import "CNPGridMenu.h"

#import "HideSetViewController.h"

#define ALBUMTABLE  @"albumTable"
#define PHOTOTABLE  @"photoTable"
#define THUMBTABLE  @"thumbTable"


static NSString *CellIdentifier = @"hidecell";

@interface HideTableViewController ()<UITableViewDataSource,UITableViewDelegate,TGCameraDelegate, CNPGridMenuDelegate>{
    
    UISegmentedControl *_segmentedControl;
    NSMutableArray *_selections;
    NSMutableArray *importAssets;
    FileDataOperation *fileDataOperation;
    NSString *currentDirctory;
    NSURL *currentURL;
    NSInteger current_selectePhotos;
    NSInteger numberOfFileInPrivate;
    
    BOOL productPurchased;
    //RNFrostedSidebar *callout;
    UIImageView *navBarHairlineImageView;
}

@property (nonatomic, strong) NSMutableIndexSet *optionIndices;  //sidebar
@property (nonatomic, strong) id fileObserveToken;
@property (nonatomic, strong) UIColor *navColor;
@property (nonatomic, strong) UIColor *menuColor;

@property (nonatomic, strong) CNPGridMenu *gridMenu;
//@property (nonatomic, strong) YTKKeyValueStore *sqlTable;

@end


@implementation HideTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    fileDataOperation = [[FileDataOperation alloc] init];
    [fileDataOperation listDirectory];
    [fileDataOperation listAllFileInPhotoDirectory];
    numberOfFileInPrivate = fileDataOperation.numberOfFileInLibrary;
    //add observer
    [self addObserverToNotificationCenter];

    NSNumber *num = [NSNumber numberWithInteger:numberOfFileInPrivate];
    [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"PhotoNumber"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    self.navigationItem.title = NSLocalizedString(@"PrivateAlbums", nil);
    UIBarButtonItem *item2= [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStyleDone target:self action:@selector(onAdd)];
    NSMutableArray *items = [[NSMutableArray alloc]initWithObjects:item2, nil];
    self.navigationItem.rightBarButtonItems = items;
    
    
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Themes"];
    if ( index == 0 ) {
        _navColor = ZY_GRAY_N;
        _menuColor = ZY_GRAY_N;
    }else{
        ColorArray *color = [ColorArray initWithColor];
        _navColor = color[index];
        
        color = [ColorArray initWithHexColor];
        _menuColor = color[index];
    }
    
    self.navigationController.navigationBar.barTintColor = _navColor;
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willMoveToParentViewController:(UIViewController *)parent{
    //NSLog(@"%@",parent);
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self refreshTable];
    navBarHairlineImageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    navBarHairlineImageView.hidden = NO;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification) name:@"GO_HOME_APP" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpload) name:@"photo_upload" object:nil];
}

- (void)handleNotification{

    if ([self.navigationController.visibleViewController isKindOfClass:[MasterViewController class]] ||
        [self.navigationController.visibleViewController isKindOfClass:[HideSetViewController class]] ) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleUpload{
    dispatch_async(dispatch_get_main_queue(), ^{
        //update Directory
        [fileDataOperation listDirectory];
        [fileDataOperation listAllFileInPhotoDirectory];
        [_photos removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.view setNeedsDisplay];
        });
    });
}

- (void)fileDidChange:(NSDictionary *)change;{
}

- (void)initBlankView{
    UIView *noAssetsView    = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    CGRect rect             = CGRectInset(self.tableView.bounds, 10, 10);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    //title.text              = NSLocalizedStringFromTable(@"No Photos or Videos", @"UzysAssetsPickerController", nil);
    title.text              = NSLocalizedString(@"No Photos", nil);
    //title.font              = [UIFont systemFontOfSize:19.0];
    title.textColor         = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    //title.tag               = kTagNoAssetViewTitleLabel;
    
    message.text            = NSLocalizedString(@"You can sync Photos onto your iPhone using iTunes or Wi-Fi.", nil);
    //message.font            = [UIFont systemFontOfSize:15.0];
    message.textColor       = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    //message.tag             = kTagNoAssetViewMsgLabel;
    
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_image"]];
    titleImage.contentMode = UIViewContentModeCenter;
    //titleImage.tag = kTagNoAssetViewImageView;
    
    title.font              = [UIFont fontWithName:@"PingFangHK-Medium" size:19];
    message.font            = [UIFont fontWithName:@"PingFangHK-Light" size:15];
    
    [title sizeToFit];
    [message sizeToFit];
    
    title.center            = CGPointMake(noAssetsView.center.x, noAssetsView.center.y + 50 - title.frame.size.height / 2 + 40);
    message.center          = CGPointMake(noAssetsView.center.x, noAssetsView.center.y + 70 + message.frame.size.height / 2 + 20);
    titleImage.center       = CGPointMake(noAssetsView.center.x, noAssetsView.center.y + 60 - titleImage.frame.size.height /2);
    [noAssetsView addSubview:title];
    [noAssetsView addSubview:message];
    [noAssetsView addSubview:titleImage];
    self.tableView.backgroundView = noAssetsView;
}

#pragma mark - Table view data source /delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    NSInteger numbers = fileDataOperation.directoryArray.count;
    if (numbers == 0) {
        [self initBlankView];
        self.tableView.backgroundView.hidden = NO;
    }else {
        self.tableView.backgroundView.hidden = YES;
    }
    
    return numbers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create
    HideViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[HideViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

     NSURL *fileURL = fileDataOperation.directoryArray[indexPath.row];
    [fileDataOperation listFileInDirectory:fileURL];
    NSString *counts = [NSString stringWithFormat:@"%lu",(unsigned long)fileDataOperation.photoURLArray.count];
    
    NSString *filename;
    [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
    
    NSURL *imageURL = fileDataOperation.photoURLArray.lastObject;     
    if (imageURL==nil) {
        cell.albumPhoto.image = [UIImage imageNamed:@"cell.png"];
    }else{
        cell.albumPhoto.image = [UIImage imageWithContentsOfFile:imageURL.path];
    }
    cell.albumName.text = filename;
    cell.photoCount.text = counts;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSURL *fileURL = fileDataOperation.directoryArray[indexPath.row];
        [fileDataOperation deleteDirectory:fileURL];
        [fileDataOperation listDirectory];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
   return NO;
}


#pragma mark -- Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toHideCollectionCell"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSURL *fileURL = fileDataOperation.directoryArray[indexPath.row];
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        currentDirctory = filename;
        currentURL = fileURL;
        
        [fileDataOperation listFileInDirectory:fileURL];
        
        HidePhotoCollectionViewController *gridViewController = segue.destinationViewController;
        gridViewController.urlMutalbeArray = fileDataOperation.photoURLArray;
        gridViewController.currentDirctory = filename;
        gridViewController.currentURL = fileURL;
    }
}

#pragma mark -- UIBarButton Action

- (void)onAdd{
    
    // Prompt user from new album title.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Album", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Album Name", @"");
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSString *title = textField.text;
        
        [fileDataOperation createDirectory:title];
        [fileDataOperation listDirectory];
        
        [self.tableView reloadData];
        [self.view setNeedsDisplay];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[fileDataOperation listDirectory];
            [self.tableView reloadData];
        });
    }];
}

- (IBAction)onBurger:(id)sender{
    [self showMenu];
}

#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image{
    //_photoView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image{
    //_photoView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)refreshTable{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //update Directory
        [fileDataOperation listDirectory];
        [fileDataOperation listAllFileInPhotoDirectory];
        [_photos removeAllObjects];
        
        NSNumber *num = [NSNumber numberWithInteger:fileDataOperation.numberOfFileInLibrary];
        [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"PhotoNumber"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.view setNeedsDisplay];
        });
    });
}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL{
    [self refreshTable];
}

- (void)cameraDidSavePhotoWithError:(NSError *)error{
    //NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
}

- (void)takePhotoToLocal{
    
    [TGCamera setOption:kTGCameraOptionSaveImageToAlbum value:[NSNumber numberWithBool:NO]];
    
    TGCameraNavigationController *navigationController =
    [TGCameraNavigationController newWithCameraDelegate:self];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark Menu

- (void)showMenu{

    //Upgrade
    CNPGridMenuItem *upgrade = [[CNPGridMenuItem alloc] init];
    upgrade.icon = [UIImage imageNamed:@"buy"];
    upgrade.title = [NSString stringWithString:NSLocalizedString(@"Upgrade", nil)];
    upgrade.menuItemTag = 20;
    
    //Rating
    CNPGridMenuItem *rating = [[CNPGridMenuItem alloc] init];
    rating.icon = [UIImage imageNamed:@"star"];
    rating.title = [NSString stringWithString:NSLocalizedString(@"Rating", nil)];
    rating.menuItemTag = 21;
    
    //Transfer
    CNPGridMenuItem *wifi = [[CNPGridMenuItem alloc] init];
    wifi.icon = [UIImage imageNamed:@"wifi"];
    wifi.title = [NSString stringWithString:NSLocalizedString(@"Transfer", nil)];
    wifi.menuItemTag = 22;
    
    //Video
    CNPGridMenuItem *video = [[CNPGridMenuItem alloc] init];
    video.icon = [UIImage imageNamed:@"video"];
    video.title = [NSString stringWithString:NSLocalizedString(@"Video", nil)];
    video.menuItemTag = 23;
    
    //Camera
    CNPGridMenuItem *camera = [[CNPGridMenuItem alloc] init];
    camera.icon = [UIImage imageNamed:@"camera"];
    camera.title = [NSString stringWithString:NSLocalizedString(@"Camera", nil)];
    camera.menuItemTag = 24;
    
    //Setting
    CNPGridMenuItem *setting = [[CNPGridMenuItem alloc] init];
    setting.icon = [UIImage imageNamed:@"set"];
    setting.title = [NSString stringWithString:NSLocalizedString(@"Setting", nil)];
    setting.menuItemTag = 25;
    
    //Home
    CNPGridMenuItem *home = [[CNPGridMenuItem alloc] init];
    home.icon = [UIImage imageNamed:@"home"];
    home.title = [NSString stringWithString:NSLocalizedString(@"Home", nil)];
    home.menuItemTag = 26;
    
#ifdef PHOTO_APP_NOMARL
    
    //Home
    CNPGridMenuItem *buy = [[CNPGridMenuItem alloc] init];
    buy.icon = [UIImage imageNamed:@"home"];
    buy.title = [NSString stringWithString:NSLocalizedString(@"Get PrivatePhoto", nil)];
    buy.menuItemTag = 27;
    
    CNPGridMenu *gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[upgrade, rating, wifi, video, camera, setting,home, buy]];
    gridMenu.delegate = self;
    gridMenu.blurEffectStyle = CNPBlurEffectStyleDark;
    [self presentGridMenu:gridMenu animated:NO completion:^{
    }];
    
#else
    
    CNPGridMenu *gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[upgrade, rating, wifi, video, camera, setting,home]];
    gridMenu.delegate = self;
    gridMenu.blurEffectStyle = CNPBlurEffectStyleDark;
    [self presentGridMenu:gridMenu animated:NO completion:^{
    }];
    
#endif
    

}

- (void)gridMenuDidTapOnBackground:(CNPGridMenu *)menu {
    [self dismissGridMenuAnimated:YES completion:^{
        //NSLog(@"Grid Menu Dismissed With Background Tap");
    }];
}

- (void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item {
    [self dismissGridMenuAnimated:YES completion:^{
        
        //upgrade rating transfer video camera setting  home
        switch (item.menuItemTag) {
            case 20:
            {
                MasterViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"IPAView"];
                [self.navigationController pushViewController:controller animated:YES];
            }
                break;
            case 21:
            {
                NSString *iTunesLink = ITUNESLINK_PHOHO;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            }
                break;
            case 22:
            {
                HTTPViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HttpView"];
                [self.navigationController pushViewController:controller animated:YES];
            }
                break;
            case 23:
            {
                HideVideoTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HideView"];
                [self.navigationController pushViewController:controller animated:YES];
            }
                break;
            case 24:
                [self takePhotoToLocal];
                break;
            case 25:
            {
                HideSetViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HideSetViewController"];
                [self.navigationController pushViewController:controller animated:YES];
            }
                break;
            case 26:
            {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
                break;
            case 27:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ITUNESLINK_BUY_APP]];
            }
                
            default:
                break;
        }
    }];
}


@end
