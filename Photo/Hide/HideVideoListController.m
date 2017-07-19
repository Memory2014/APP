//
//  HideVideoListController.m
//  PhotoPRO
//
//  Created by zhong on 8/11/16.
//  Copyright © 2016 zhongyi. All rights reserved.
//

#import "HideVideoListController.h"
#import "FileDataOperation.h"
#import "HideVideoListCell.h"
#import "MWPhotoBrowser.h"
#import "UzysAssetsPickerController.h"
#import "PlayerViewController.h"
#import "Utill.h"
//#import "VideoViewController.h"
//#import "PhotoPRO-Swift.h"

static NSCache *photoCache = nil;
static NSCache *videoCache = nil;

@interface HideVideoListController()<UzysAssetsPickerControllerDelegate> {
    BOOL productPurchased;
    FileDataOperation *fileDataOperation;
    NSInteger numberOfFileInPrivate;
}

@end

@implementation HideVideoListController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *import = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didImport)];
    self.navigationItem.rightBarButtonItems = @[import];
    self.navigationItem.title = self.currentDirctory;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = self.urlMutalbeArray.count;
    if (numbers == 0) {
        [self initBlankView];
        self.tableView.backgroundView.hidden = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else {
        self.tableView.backgroundView.hidden = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    return numbers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create
    NSString *identifier = @"HideVideoListCell";
    HideVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell == nil){
        cell = [[HideVideoListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.videoImage.image = [self loadImageAtIndex:indexPath.item];
    
    NSDictionary *video = [self loadVideoAtIndex:indexPath.item];
    cell.videoName.text = video[@"title"];
    cell.videoTime.text = video[@"duration"];
    
    //preload image for previous and next index
    if (indexPath.item < [self.urlMutalbeArray count] - 1) {
        [self loadImageAtIndex:indexPath.item + 1];
        [self loadVideoAtIndex:indexPath.item + 1];
    }
    if (indexPath.item > 0) {
        [self loadImageAtIndex:indexPath.item - 1];
        [self loadVideoAtIndex:indexPath.item - 1];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}

#pragma mark -- uitable view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        FileDataOperation *photo = [[FileDataOperation alloc] init];
        NSURL *url = self.urlMutalbeArray[indexPath.row];
        [photo deleteFileFromURL:url];
        [self.urlMutalbeArray removeObjectAtIndex:indexPath.row];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [photo listDirectory];
                [photo listAllFileInVideoFile];
                [photo listAllFileInVideoDirectory:self.currentURL];
                self.urlMutalbeArray = photo.videoURLArray;
                
                NSInteger xx = [photo listAllFileInVideoFile];
                NSNumber *num = [NSNumber numberWithInteger:xx];
                [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"VideoNumber"];
            });
        });
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    [self.tableView reloadData];
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    PlayerViewController *player = [[PlayerViewController alloc] init];
    player.hidesBottomBarWhenPushed = YES;
    //player.prefersStatusBarHidden = YES;
    player.video = [self loadVideoAtIndex:indexPath.item];
    
    [self.navigationController pushViewController:player animated:YES];
}

#pragma mark -- Image

- (UIImage *)loadImageAtIndex:(NSUInteger)index{
    //set up cache
    if (!photoCache) {
        photoCache = [[NSCache alloc] init];
    }
    
    if (!videoCache) {
        videoCache = [[NSCache alloc] init];
    }
    
    //if already cached, return immediately
    UIImage *image = [photoCache objectForKey:@(index)];
    if (image) {
        return [image isKindOfClass:[NSNull class]]? nil: image;
    }
    
    //set placeholder to avoid reloading image multiple times
    [photoCache setObject:[NSNull null] forKey:@(index)];
    
    //switch to background thread
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //load image
        NSURL *url = self.urlMutalbeArray[index];
        UIImage *image = [self thumbnailImageFromURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{ //cache the image
            [photoCache setObject:image forKey:@(index)];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem: index inSection:0];
            HideVideoListCell *cell = (HideVideoListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.videoImage.image = image;
        });
    });
    //not loaded yet
    return nil;
}

- (NSDictionary *)loadVideoAtIndex:(NSUInteger)index{
    //set up cache
    if (!videoCache) {
        videoCache = [[NSCache alloc] init];
    }
    
    //if already cached, return immediately
    NSDictionary *dic = [videoCache objectForKey:@(index)];
    if (dic) {
        return [dic isKindOfClass:[NSNull class]]? nil: dic;
    }
    
    //set placeholder to avoid reloading image multiple times
    [videoCache setObject:[NSNull null] forKey:@(index)];
    
    //switch to background thread
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //load image
        NSURL *url = self.urlMutalbeArray[index];
        NSDictionary *video = [self dictionaryFromURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{ //cache the image
            [videoCache setObject:video forKey:@(index)];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem: index inSection:0];
            HideVideoListCell *cell = (HideVideoListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.videoName.text = video[@"title"];
            cell.videoTime.text = video[@"duration"];
        });
    });
    //not loaded yet
    return nil;
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

- (NSDictionary *)dictionaryFromURL:(NSURL *)videoURL {

    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    CGFloat seconds = 0;
    seconds = urlAsset.duration.value/urlAsset.duration.timescale;
    NSInteger hour = seconds / 3600;
    NSInteger time = (NSInteger)seconds % 3600;
    NSInteger min  = (NSInteger)time / 60;
    NSInteger sec  = time % 60;
    NSString *videoTime =  [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];

    NSString *str = [urlAsset.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *name = [str lastPathComponent];
    name = [name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *video = @{
                            @"title":name,
                            @"video":videoURL,
                            @"duration" : videoTime
                            };
    return video;
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

#pragma mark -- MISC

- (void)getPurchased{
    NSString *productIdentifier = PRODUCT_SELL;
    productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
}

- (BOOL)checkVideoNumber{
    
    FileDataOperation *file = [[FileDataOperation alloc]init];
    [file listAllVideoDirectory];
    NSInteger storePhotos = file.directoryVideoArray.count;
    
    
//    NSNumber *num = [NSNumber numberWithInteger:photo.directoryVideoArray.count];
//    [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"VideoNumber"];
    
    if (storePhotos > MAX_VIDEO_IMPORT) {
        return false;
    }
    return true;
}

- (void)didImport{
    
    //int remain = 0;
    
    NSNumber *storePhotos = [[NSUserDefaults standardUserDefaults] objectForKey:@"VideoNumber"];
    NSInteger videoCount = [storePhotos integerValue];
    
    NSLog(@"current video %ld",(long)videoCount);
    
    [self getPurchased];
    if (!productPurchased) {
        
        if (videoCount >= MAX_VIDEO_IMPORT) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"", nil)  message:NSLocalizedString(@"Exceed Maximum Number Of Selection.Please upgrade purchase this get unlimited", nil)  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
            [alertController addAction:ok];

            [self.navigationController presentViewController:alertController animated:NO completion:nil];
            
            return;
        }
        
//        if (![self checkVideoNumber]) {
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INFORMATION", nil)  message:NSLocalizedString(@"Exceed Maximum Number Of Selection.Please upgrade purchase this get unlimited", nil)  preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
//            [alertController addAction:ok];
//            
//            [self.navigationController presentViewController:alertController animated:NO completion:nil];
//            
//            return;
//        }
        
    }else{
        //remain = 10000;
    }
    
    //if you want to checkout how to config appearance, just uncomment the following 4 lines code.
#if 0
    UzysAppearanceConfig *appearanceConfig = [[UzysAppearanceConfig alloc] init];
    appearanceConfig.finishSelectionButtonColor = [UIColor blueColor];
    appearanceConfig.assetsGroupSelectedImageName = @"checker.png";
    appearanceConfig.cellSpacing = 1.0f;
    appearanceConfig.assetsCountInALine = 5;
    [UzysAssetsPickerController setUpAppearanceConfig:appearanceConfig];
#endif
    
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 1;
    picker.maximumNumberOfSelectionPhoto = 0;
    
    [self presentViewController:picker animated:YES completion:^{
    }];
}

#pragma mark - UzysAssetsPickerControllerDelegate methods
- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    if(assets.count ==1)
    {
        //self.labelDescription.text = [NSString stringWithFormat:@"%ld asset selected",(unsigned long)assets.count];
    }
    else
    {
        //self.labelDescription.text = [NSString stringWithFormat:@"%ld assets selected",(unsigned long)assets.count];
    }
    //__weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
    }
    else //Video
    {
        ALAsset *alAsset = assets[0];

        FileDataOperation *file = [[FileDataOperation alloc]init];
        NSString *path = [file dirVideoDirectory];
        
        char temp[10];
        for (int x=0;x<10;temp[x++] = (char)('A' + (arc4random_uniform(26))));
        NSString *rand = [[NSString alloc] initWithBytes:temp length:10 encoding:NSUTF8StringEncoding];
        NSString *name = [NSString stringWithFormat:@"%@%@%@",@"/",rand,@".mp4"];
        
        ALAssetRepresentation *representation = alAsset.defaultRepresentation;
        NSURL *movieURL = representation.url;
        NSURL *uploadURL = [NSURL fileURLWithPath:[[path stringByAppendingPathComponent:self.currentDirctory] stringByAppendingString:name]];
        AVAsset *asset      = [AVURLAsset URLAssetWithURL:movieURL options:nil];
        AVAssetExportSession *session =
        [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        
        session.outputFileType  = AVFileTypeQuickTimeMovie;
        session.outputURL       = uploadURL;
        
        [session exportAsynchronouslyWithCompletionHandler:^{
            
            if (session.status == AVAssetExportSessionStatusCompleted)
            {
                //DLog(@"output Video URL %@",uploadURL);
                FileDataOperation *photo = [[FileDataOperation alloc] init];
                [photo listAllVideoDirectory];
                [photo listAllFileInVideoDirectory:self.currentURL];
                self.urlMutalbeArray = photo.videoURLArray;
                NSInteger xx = [photo listAllFileInVideoFile];
                
                NSNumber *num = [NSNumber numberWithInteger:xx];
                [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"VideoNumber"];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [photoCache removeAllObjects];
                    photoCache = nil;
                    
                    [videoCache removeAllObjects];
                    videoCache = nil;
                    [self.tableView reloadData];
                });
            }
        }];
    }
    [self.navigationController popToViewController:self animated:YES];
}

- (void)uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(UzysAssetsPickerController *)picker{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedStringFromTable(@"Exceed Maximum Number Of Selection.Please upgrade purchase this get unlimited", @"UzysAssetsPickerController", nil)
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



@end
