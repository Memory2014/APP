//
//  HideVideoCollectionViewController.m
//  Photo
//
//  Created by zhongyi on 16/1/10.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "HideVideoCollectionViewController.h"
#import "HidePhotoCollectionViewCell.h"
#import "FileDataOperation.h"
#import "UzysAssetsPickerController.h"
#import "MWPhotoBrowser.h"
#import "Utill.h"

@interface HideVideoCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDelegate,UzysAssetsPickerControllerDelegate>{
    BOOL productPurchased;
    FileDataOperation *fileDataOperation;
    NSInteger numberOfFileInPrivate;
    CGFloat _margin, _gutter, _marginL, _gutterL, _columns, _columnsL;
}

@property (nonatomic)BOOL cellSelectionMode;

@end

@implementation HideVideoCollectionViewController

@synthesize urlMutalbeArray;
static NSCache *photoCache = nil;
static NSString * const CellReuseIdentifier = @"hideVideoGridCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    //self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
    
    // Do any additional setup after loading the view.
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.bounces = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = TRUE;
    
    UIBarButtonItem *import = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didImport)];
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didSelected)];
    self.navigationItem.rightBarButtonItems = @[import,edit];
    self.navigationItem.title = self.currentDirctory;
    
    [self loadImagesForOnscreenRows];
}

- (void)awakeFromNib{
    {
        [super awakeFromNib];
        // Defaults
        _columns = 3, _columnsL = 4;
        _margin = 0, _gutter = 1;
        _marginL = 0, _gutterL = 1;
        
        // For pixel perfection...
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad
            _columns = 6, _columnsL = 8;
            _margin = 1, _gutter = 2;
            _marginL = 1, _gutterL = 2;
        } else if ([UIScreen mainScreen].bounds.size.height == 480) {
            // iPhone 3.5 inch
            _columns = 3, _columnsL = 4;
            _margin = 0, _gutter = 1;
            _marginL = 1, _gutterL = 2;
        } else {
            // iPhone 4 inch
            _columns = 3, _columnsL = 5;
            _margin = 0, _gutter = 1;
            _marginL = 0, _gutterL = 2;
        }
        
        _initialContentOffset = CGPointMake(0, CGFLOAT_MAX);
    }
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

#pragma mark <UICollectionViewDataSource>


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger count  = self.urlMutalbeArray.count;
    if (count == 0) {
        [self initBlankView];
        self.collectionView.backgroundView.hidden = NO;
    }else{
        self.collectionView.backgroundView.hidden = YES;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    HidePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    //NSURL *url = self.urlMutalbeArray[indexPath.item];
    
    cell.thumbnailImage = [self loadImageAtIndex:indexPath.item];
    //preload image for previous and next index
    if (indexPath.item < [self.urlMutalbeArray count] - 1) {
        [self loadImageAtIndex:indexPath.item + 1]; }
    if (indexPath.item > 0) {
        [self loadImageAtIndex:indexPath.item - 1]; }
    return cell;
}

- (UIImage *)loadImageAtIndex:(NSUInteger)index
{
    //set up cache
    
    if (!photoCache) {
        photoCache = [[NSCache alloc] init];
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
        UIImage *image = [self thumbnailImageFromURL:url]; //[UIImage imageWithContentsOfFile:url.path];
        dispatch_async(dispatch_get_main_queue(), ^{ //cache the image
            [photoCache setObject:image forKey:@(index)];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem: index inSection:0];
            HidePhotoCollectionViewCell *cell = (HidePhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.thumbnailImage = image;
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

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"%li didse ",(long)indexPath.item);
    
    if (self.cellSelectionMode) {
        //NSLog(@"%i",self.cellSelectionMode);
        [self updateSelectionForCell:[collectionView cellForItemAtIndexPath:indexPath]];
        
    }else{
        
        NSURL *fileURL = fileDataOperation.directoryVideoArray[indexPath.row];
        [fileDataOperation listAllFileInVideoDirectory:fileURL];
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        MWPhoto *photo;
        
        if (self.urlMutalbeArray.count > 0) {
            for (NSURL *url in self.urlMutalbeArray) {
                // Photos & thumbs
                photo = [MWPhoto photoWithURL:url];
                photo.videoURL = url;
                [photos addObject:photo];
            }
        }

        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photos];

        browser.displayActionButton = YES;
        browser.alwaysShowControls = NO;
        browser.zoomPhotosToFill = YES;
        browser.enableSwipeToDismiss = YES;
        browser.autoPlayOnAppear = NO;
        // Push
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"%li didUn",(long)indexPath.item);
    
    if (self.cellSelectionMode) {
        [self updateSelectionForCell:[collectionView cellForItemAtIndexPath:indexPath]];
    }
    
}

- (void)updateSelectionForCell:(UICollectionViewCell *)cell {
    
    HidePhotoCollectionViewCell *_cell = (HidePhotoCollectionViewCell*)cell;
    UIImage *selectImage;
    if (cell.selected) {
        selectImage = [UIImage imageNamed:@"ImageSelectedSmallOn"];
    }else{
        //selectImage = [UIImage imageNamed:@"ImageSelectedSmallOff"];
    }
    _cell.livePhotoBadgeImage = selectImage;
    
    NSArray *selectedRows = [self.collectionView indexPathsForSelectedItems];
    NSString *titleFormatString = NSLocalizedString(@"Selected (%d)", @"Title for selected button with placeholder for number");
    self.navigationItem.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    
}


/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //[self loadImagesForOnscreenRows];
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


#pragma mark --- Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self performLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)adjustOffsetsAsRequired {
    
    // Move to previous content offset
    if (_initialContentOffset.y != CGFLOAT_MAX) {
        self.collectionView.contentOffset = _initialContentOffset;
        [self.collectionView layoutIfNeeded]; // Layout after content offset change
    }
}

- (void)performLayout {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    self.collectionView.contentInset = UIEdgeInsetsMake(navBar.frame.origin.y + navBar.frame.size.height + [self getGutter], 0, 0, 0);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView reloadData];
    [self performLayout]; // needed for iOS 5 & 6
}

- (CGFloat)getColumns {
    if ((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))) {
        return _columns;
    } else {
        return _columnsL;
    }
}

- (CGFloat)getMargin {
    if ((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))) {
        return _margin;
    } else {
        return _marginL;
    }
}

- (CGFloat)getGutter {
    if ((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))) {
        return _gutter;
    } else {
        return _gutterL;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat margin = [self getMargin];
    CGFloat gutter = [self getGutter];
    CGFloat columns = [self getColumns];
    CGFloat value = floorf(((self.view.bounds.size.width - (columns - 1) * gutter - 2 * margin) / columns));
    return CGSizeMake(value, value);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [self getGutter];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [self getGutter];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat margin = [self getMargin];
    return UIEdgeInsetsMake(margin, margin, margin, margin);
}

- (void)initBlankView{
    UIView *noAssetsView    = [[UIView alloc] initWithFrame:self.collectionView.bounds];
    
    CGRect rect             = CGRectInset(self.collectionView.bounds, 10, 10);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    //title.text              = NSLocalizedStringFromTable(@"No Photos or Videos", @"UzysAssetsPickerController", nil);
    title.text              = NSLocalizedString(@"No Photos or Videos", nil);
    title.font              = [UIFont systemFontOfSize:19.0];
    title.textColor         = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    //title.tag               = kTagNoAssetViewTitleLabel;
    
    message.text            = NSLocalizedString(@"You can sync photos and videos onto your iPhone using iTunes", nil);
    message.font            = [UIFont systemFontOfSize:15.0];
    message.textColor       = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    //message.tag             = kTagNoAssetViewMsgLabel;
    
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_image"]];
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
    self.collectionView.backgroundView = noAssetsView;
    
    //[self.tableView.backgroundView addSubview:noAssetsView];
}


- (void)loadImagesForOnscreenRows
{
    if (self.urlMutalbeArray.count > 0)
    {
        NSArray *visiblePaths = [self.collectionView indexPathsForVisibleItems];  // indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            HidePhotoCollectionViewCell *cell = (HidePhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            UIImage *img = [self loadImageAtIndex:indexPath.row];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.thumbnailImage = img;
            });
            
        }
    }
    
}

#pragma mark -- MISC
- (void)updateBarButton{
    if (self.cellSelectionMode) {
        //self.navigationItem.rightBarButtonItems = @[self.moreButton];
        self.navigationItem.title = NSLocalizedString(@"select photo", nil);
        //UIBarButtonItem *import = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didImport)];
        UIBarButtonItem *more = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStyleDone target:self action:@selector(handMore)];
        self.navigationItem.rightBarButtonItems = @[more];
    } else {
        //self.navigationItem.rightBarButtonItems = @[self.editButton];
        self.navigationItem.title = self.currentDirctory;
        UIBarButtonItem *import = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didImport)];
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didSelected)];
        self.navigationItem.rightBarButtonItems = @[import,edit];
    }
}

- (void)didSelected{
    self.cellSelectionMode = !self.cellSelectionMode;
    [self.collectionView reloadData];
    
    [self updateBarButton];
}

- (void)handMore{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    // Add an action to dismiss the UIAlertController.
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self doCancel];
    }]];
    
    
    NSString *favoriteActionTitle = NSLocalizedString(@"Delete", @"");
    [alertController addAction:[UIAlertAction actionWithTitle:favoriteActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self doDelete];
    }]];
    
    if ( [alertController respondsToSelector:@selector(popoverPresentationController)] ) {
        // iOS8
        alertController.popoverPresentationController.sourceView = self.collectionView;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//{
//    if(error){
//        NSLog(@"save error");
//    }else{
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SUCC " message:@"Save to ablum" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//        [alertController addAction:okAction];
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
//}

- (void)doCancel{
    self.cellSelectionMode = !self.cellSelectionMode;
    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
    
    [self updateBarButton];
}

- (void)doDelete{
    NSArray *selectedRows = [self.collectionView indexPathsForSelectedItems];
    if (selectedRows.count > 0) {
        
        FileDataOperation *photo = [[FileDataOperation alloc] init];
        
        for (NSIndexPath *index in selectedRows) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[[self navigationController] popViewControllerAnimated:YES];
                //[self.collectionView deselectItemAtIndexPath:index animated:YES];
                
                //NSInteger index = i;
                NSURL *url = self.urlMutalbeArray[index.row];
                [photo deleteFileFromURL:url];
            });
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [photo listDirectory];
                [photo listAllFileInPhotoDirectory];
                [photo listFileInDirectory:self.currentURL];
                self.urlMutalbeArray = photo.photoURLArray;
                
                NSNumber *num = [NSNumber numberWithInteger:photo.numberOfFileInLibrary];
                [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"PhotoNumber"];
                
                [photoCache removeAllObjects];
                photoCache = nil;
                [self.collectionView reloadData];
            });
        });
    }
    self.cellSelectionMode = !self.cellSelectionMode;
    [self updateBarButton];
}

- (void)getPurchased{
    NSString *productIdentifier = PRODUCT_SELL;
    productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
}

- (BOOL)checkVideoNumber{
    
    FileDataOperation *file = [[FileDataOperation alloc]init];
    [file listAllVideoDirectory];
    NSInteger storePhotos = file.directoryVideoArray.count;
    
    if (storePhotos > MAX_VIDEO_IMPORT) {
        return false;
    }
    return true;
}

- (void)didImport{

    //int remain = 0;
    
    [self getPurchased];
    if (!productPurchased) {
        
        if (self.urlMutalbeArray.count >= MAX_VIDEO_IMPORT ) {
       
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INFORMATION", nil)  message:NSLocalizedString(@"Exceed Maximum Number Of Selection.Please upgrade purchase this get unlimited", nil)  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
            [alertController addAction:ok];
            
            //[vc presentViewController:alertController animated:YES completion:nil];
            [self.navigationController presentViewController:alertController animated:NO completion:nil];
            
            return;
        }
        
        if (![self checkVideoNumber]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INFORMATION", nil)  message:NSLocalizedString(@"Exceed Maximum Number Of Selection.Please upgrade purchase this get unlimited", nil)  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
            [alertController addAction:ok];
            
            //[vc presentViewController:alertController animated:YES completion:nil];
            [self.navigationController presentViewController:alertController animated:NO completion:nil];
            
            return;
        }
        
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
- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
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
        
        //UIImage *img = [UIImage imageWithCGImage:alAsset.defaultRepresentation.fullResolutionImage scale:alAsset.defaultRepresentation.scale orientation:(UIImageOrientation)alAsset.defaultRepresentation.orientation];
        //weakSelf.imageView.image = img;
        
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [photoCache removeAllObjects];
                    photoCache = nil;
                    [self.collectionView reloadData];
                });

            }
            
        }];
    }
    
    [self.navigationController popToViewController:self animated:YES];
}

- (void)uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(UzysAssetsPickerController *)picker
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedStringFromTable(@"Exceed Maximum Number Of Selection.Please upgrade purchase this get unlimited", @"UzysAssetsPickerController", nil)
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



@end
