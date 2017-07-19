
//
//  Created by zhongyi on 15/9/22.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "HideVideoTableViewController.h"
#import "MwPhotoBrowser.h"
#import "VideoViewCell.h"
#import "FileDataOperation.h"
#import "RNFrostedSidebar.h"
#import "passwordViewController.h"
#import "HideVideoListController.h"

#define TINCOLOR_AQUA  [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0]
#define ZY_FRONT  [UIFont fontWithName:@"PingFangHK-Light" size:15]

static NSString *CellIdentifier = @"hideVideo";

@interface HideVideoTableViewController ()< UITableViewDataSource,UITableViewDelegate>{
    UISegmentedControl *_segmentedControl;
    NSMutableArray *_selections;
    NSMutableArray *importAssets;
    MWPhotoBrowser *photoBrowser;
    FileDataOperation *fileDataOperation;
    NSString *currentDirctory;
    NSURL *currentURL;
}

@property (nonatomic, strong) NSMutableIndexSet *optionIndices;  //sidebar

@end


@implementation HideVideoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStyleDone target:self action:@selector(onAdd)];
    
    NSMutableArray *items = [[NSMutableArray alloc]initWithObjects:item2, nil];
    self.navigationItem.rightBarButtonItems = items;
    
    fileDataOperation = [[FileDataOperation alloc] init];
    [fileDataOperation listAllVideoDirectory];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self addObserverToNotificationCenter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willMoveToParentViewController:(UIViewController *)parent{
    //NSLog(@"%@",parent);
}

- (void)doReturn{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //self.navigationController.navigationBar.tintColor = TINCOLOR_AQUA;
    
    self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    
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

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = fileDataOperation.directoryVideoArray.count;
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
    
     VideoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[VideoViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.albumPhoto.image = [UIImage imageNamed:@"video_cell.png"];
    
    NSURL *fileURL = fileDataOperation.directoryVideoArray[indexPath.row];
    NSString *filename;
    [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
    
    [fileDataOperation listAllFileInVideoDirectory:fileURL];
    NSString *counts = [NSString stringWithFormat:@"%lu",(unsigned long)fileDataOperation.videoURLArray.count];
    
    cell.albumName.text = filename;
    cell.photoCount.text = counts;
    
    cell.photoCount.font = [UIFont fontWithName:@"Optima-Italic" size:15];
    cell.albumName.font = [UIFont fontWithName:@"Optima-BoldItalic" size:15];
    
    cell.albumPhoto.contentMode = UIViewContentModeScaleAspectFill;
    cell.albumPhoto.clipsToBounds = YES;
    cell.albumPhoto.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}

#pragma mark -- uitable view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSURL *fileURL = fileDataOperation.directoryVideoArray[indexPath.row];
        [fileDataOperation deleteDirectory:fileURL];
        [fileDataOperation listAllVideoDirectory];
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

- (void)reloadBrowerData{
    
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo,*thumb;
    
    if (fileDataOperation.videoURLArray.count > 0) {
        
        for (NSURL *url in fileDataOperation.videoURLArray) {
            
            photo = [MWPhoto photoWithURL:url];
            photo.videoURL = url;
            [photos addObject:photo];
            thumb = [MWPhoto photoWithImage:[self thumbnailImageFromURL:url]];        //[UIImage imageNamed:@"video_cell.png"]];  // photoWithURL:url];
            thumb.isVideo = YES;
            [thumbs addObject:thumb];
            
        }
    }
    
    self.photos = photos;
    self.thumbs = thumbs;
}

- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL: videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime requestedTime = CMTimeMake(1, 60);     // To create thumbnail image
    CGImageRef imgRef = [generator copyCGImageAtTime:requestedTime actualTime:NULL error:&err];
    //NSLog(@"err = %@, imageRef = %@", err, imgRef);
    
    UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);    // MUST release explicitly to avoid memory leak
    
    if (thumbnailImage  == nil ) {
        thumbnailImage = [UIImage imageNamed:@"video_cell.png"];
    }
    
    return thumbnailImage;
}

- (void)initBlankView{
    UIView *noAssetsView    = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    CGRect rect             = CGRectInset(self.tableView.bounds, 10, 10);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    //title.text              = NSLocalizedStringFromTable(@"No Photos or Videos", @"UzysAssetsPickerController", nil);
    title.text              = NSLocalizedString(@"No Videos", nil);
    //title.font              = [UIFont systemFontOfSize:19.0];
    title.textColor         = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    //title.tag               = kTagNoAssetViewTitleLabel;
    
    message.text            = NSLocalizedString(@"You can sync videos onto your iPhone using iTunes or Wi-Fi.", nil);
    //message.font            = [UIFont systemFontOfSize:15.0];
    message.textColor       = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    //message.tag             = kTagNoAssetViewMsgLabel;
    
    title.font              = [UIFont fontWithName:@"PingFangHK-Medium" size:19];
    message.font            = [UIFont fontWithName:@"PingFangHK-Light" size:15];
    
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_video"]];
    titleImage.contentMode = UIViewContentModeCenter;
    //titleImage.tag = kTagNoAssetViewImageView;
    
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

#pragma mark -- Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //if ([segue.identifier isEqualToString:@"toHideCollectionCell"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSURL *fileURL = fileDataOperation.directoryVideoArray[indexPath.row];
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        currentDirctory = filename;
        currentURL = fileURL;
        
        [fileDataOperation listAllFileInVideoDirectory:fileURL];
        
        HideVideoListController *gridViewController = segue.destinationViewController;
        gridViewController.urlMutalbeArray = fileDataOperation.videoURLArray;
        gridViewController.currentDirctory = filename;
        gridViewController.currentURL = fileURL;
    //}
}

#pragma mark -- UIBarButton Action

- (void)onAdd{
    
    // Prompt user from new album title.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Album", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Album Name", @"");
        textField.font = ZY_FRONT;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSString *title = textField.text;
        
        [fileDataOperation createVideoDirectory:title];
        [fileDataOperation listAllVideoDirectory];
        
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


@end
