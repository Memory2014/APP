//
//  PhotoGridViewControl.m
//  Photo
//
//  Created by zhongyi on 16/1/1.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "PhotoGridViewControl.h"
#import "PhotoGridViewCell.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"
#import "MWPhotoBrowser.h"
#import "Utill.h"
//#include "UINavigationBar+Awesome.h"

//#include "SDImageCache.h"

@import Photos;
@import PhotosUI;

@interface PhotoGridViewControl ()<PHPhotoLibraryChangeObserver,UICollectionViewDelegate,UICollectionViewDataSource>{
    // Store margins for current setup
    CGFloat _margin, _gutter, _marginL, _gutterL, _columns, _columnsL;
    UIImageView *navBarHairlineImageView;
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *moreButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;
@property (nonatomic)BOOL cellSelectionMode;
@end


@implementation PhotoGridViewControl

static NSString * const CellReuseIdentifier = @"GridCell";
static CGSize AssetGridThumbnailSize;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    {
        // Defaults
        _columns = 3, _columnsL = 4;
        _margin = 0, _gutter = 1;
        _marginL = 0, _gutterL = 1;
        
        // For pixel perfection...
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad
            _columns = 5, _columnsL = 6;
            _margin = 7, _gutter = 7;
            _marginL = 8, _gutterL = 8;
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

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //[self.collectionView registerClass:[PhotoGridViewCell class] forCellWithReuseIdentifier:@"GridCell"];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    NSInteger count = self.assetsFetchResults.count;
    if (count <= 0) {
        self.navigationItem.rightBarButtonItems = @[];
    }else
    if (self.cellSelectionMode) {
        self.navigationItem.rightBarButtonItems = @[self.moreButton];
    } else {
        self.navigationItem.rightBarButtonItems = @[self.editButton];
    }
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);

    self.navigationItem.title = self.assetCollection.localizedTitle;
    navBarHairlineImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    navBarHairlineImageView.hidden = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark - Layout

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint off = self.collectionView.contentOffset;
    off.y = self.collectionView.contentSize.height - self.collectionView.bounds.size.height + self.collectionView.contentInset.bottom;
    [self.collectionView setContentOffset:off animated:animated];
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
    
    //Check if current item is visible and if not, make it so!
    //        //if (_browser.numberOfPhotos > 0) {
    //            NSIndexPath *currentPhotoIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
    //            NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    //            BOOL currentVisible = NO;
    //            for (NSIndexPath *indexPath in visibleIndexPaths) {
    //                if ([indexPath isEqual:currentPhotoIndexPath]) {
    //                    currentVisible = YES;
    //                    break;
    //                }
    //            }
    //            if (!currentVisible) {
    //                [self.collectionView scrollToItemAtIndexPath:currentPhotoIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    //            }
    //        //}
    
}

- (void)performLayout {
    //UINavigationBar *navBar = self.navigationController.navigationBar;
    //self.collectionView.contentInset = UIEdgeInsetsMake(navBar.frame.origin.y + navBar.frame.size.height + [self getGutter], 0, 0, 0);
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.assetsFetchResults.count;
    if (count == 0) {
        [self initBlankView];
        self.collectionView.backgroundView.hidden = NO;
    }else{
        self.collectionView.backgroundView.hidden = YES;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    NSInteger num = [self.collectionView numberOfItemsInSection:0];
    PHAsset *asset = self.assetsFetchResults[num - indexPath.item - 1];
    cell.representedAssetIdentifier = asset.localIdentifier;
    [self.imageManager requestImageForAsset:asset
                                 targetSize:AssetGridThumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  
                                  // Set the cell's thumbnail image if it's still showing the same asset.
                                  if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                      
                                      if (self.cellSelectionMode) {
                                          UIImage *selectImage;
                                          if (cell.selected) {
                                              selectImage = [UIImage imageNamed:@"ImageSelectedSmallOn"];
                                              cell.livePhotoBadgeImage = selectImage;
                                          }else{
                                              //selectImage = [UIImage imageNamed:@"ImageSelectedSmallOff"];
                                          }
                                      }

                                      cell.thumbnailImage = result;
                                  }
                                  
                              }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"%li didse ",(long)indexPath.item);
    
    if (self.cellSelectionMode) {
       //NSLog(@"%i",self.cellSelectionMode);
        [self updateSelectionForCell:[collectionView cellForItemAtIndexPath:indexPath]];
        
    }else{
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        if (NSClassFromString(@"PHAsset")) {
            // Photos library
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat scale = screen.scale;
            // Sizing is very rough... more thought required in a real implementation
            CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            for (PHAsset *asset in self.assetsFetchResults) {
                [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
            }}
        
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photos];
        browser.displayActionButton = YES;
        browser.alwaysShowControls = NO;
        browser.zoomPhotosToFill = YES;
        browser.enableSwipeToDismiss = YES;
        browser.autoPlayOnAppear = NO;
        
        NSInteger num = [self.collectionView numberOfItemsInSection:0];
        
        [browser setCurrentPhotoIndex:num -indexPath.row -1];
        [browser showNextPhotoAnimated:YES];
        [browser showPreviousPhotoAnimated:YES];
        
        // Push
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"%li didUn",(long)indexPath.item);
    
    if (self.cellSelectionMode) {
        [self updateSelectionForCell:[collectionView cellForItemAtIndexPath:indexPath]];
        //[self.collectionView reloadItemsAtIndexPaths:indexPath];
    }
    
}

- (void)updateSelectionForCell:(UICollectionViewCell *)cell {

    PhotoGridViewCell *_cell = (PhotoGridViewCell*)cell;
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
    
    [cell setNeedsDisplay];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    //[cell layoutIfNeeded];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
    
    //[self setNavigationBarTransformProgress:0];
    
//    CGFloat offsetY = scrollView.contentOffset.y;
//    if (offsetY > 0) {
//        if (offsetY >= 44) {
//            [self setNavigationBarTransformProgress:1];
//        } else {
//            [self setNavigationBarTransformProgress:(offsetY / 44)];
//        }
//    } else {
//        [self setNavigationBarTransformProgress:0];
//        self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
//    }
}

//
//- (void)setNavigationBarTransformProgress:(CGFloat)progress
//{
//    [self.navigationController.navigationBar lt_setTranslationY:(-44 * progress)];
//    [self.navigationController.navigationBar lt_setElementsAlpha:(1-progress)];
//}
//


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
        if (collectionChanges) {
            
            // get the new fetch result
            self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
            
            UICollectionView *collectionView = self.collectionView;
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // we need to reload all if the incremental diffs are not available
                [collectionView reloadData];
                
            } else {
                // if we have incremental diffs, tell the collection view to animate insertions and deletions
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}


#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

#pragma mark - Actions

- (IBAction)handleAddButtonItem:(id)sender
{
    // Create a random dummy image.
    CGRect rect = rand() % 2 == 0 ? CGRectMake(0, 0, 400, 300) : CGRectMake(0, 0, 300, 400);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);
    [[UIColor colorWithHue:(float)(rand() % 100) / 100 saturation:1.0 brightness:1.0 alpha:1.0] setFill];
    UIRectFillUsingBlendMode(rect, kCGBlendModeNormal);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Add it to the photo library
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        if (self.assetCollection) {
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error creating asset: %@", error);
        }
    }];
}

- (IBAction)handleEdit:(id)sender {
    self.cellSelectionMode = !self.cellSelectionMode;
    [self.collectionView reloadData];
    
    if (self.cellSelectionMode) {
        self.navigationItem.rightBarButtonItems = @[self.moreButton];
        self.navigationItem.title = NSLocalizedString(@"select photo", nil);
    } else {
        self.navigationItem.rightBarButtonItems = @[self.editButton];
        self.navigationItem.title = self.assetCollection.localizedTitle;
    }
}

- (IBAction)handleMore:(id)sender {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    alertController.popoverPresentationController.barButtonItem = sender;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    // Add an action to dismiss the UIAlertController.
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self doCancel];
    }]];
    
    
    // Add button to the navigation bar if the asset collection supports adding content.
    if (!self.assetCollection || [self.assetCollection canPerformEditOperation:PHCollectionEditOperationAddContent]) {

    }
    
    if (!self.assetCollection || [self.assetCollection canPerformEditOperation:PHCollectionEditOperationDeleteContent| PHCollectionEditOperationAddContent]) {
        NSString *favoriteActionTitle = NSLocalizedString(@"Delete", @"");
        
        [alertController addAction:[UIAlertAction actionWithTitle:favoriteActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self doDelete];
        }]];
        
    }
    
    NSString *favoriteActionTitle = NSLocalizedString(@"More", @"") ;
    
    [alertController addAction:[UIAlertAction actionWithTitle:favoriteActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self doMore];
    }]];
    
    // Present the UIAlertController.
    [self presentViewController:alertController animated:YES completion:NULL];
    //[self.collectionView cellForItemAtIndexPath:[self numberOfSectionsInCollectionView:self.collectionView]];
}


- (void)doCancel{
    self.cellSelectionMode = !self.cellSelectionMode;
    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
    
    if (self.cellSelectionMode) {
        self.navigationItem.rightBarButtonItems = @[self.moreButton];
        self.navigationItem.title = NSLocalizedString(@"select photo", nil);
    } else {
        self.navigationItem.rightBarButtonItems = @[self.editButton];
        self.navigationItem.title = self.assetCollection.localizedTitle;
    }
}

- (void)doDelete{
    
    NSArray *selectedRows = [self.collectionView indexPathsForSelectedItems];
    if (selectedRows.count > 0) {
        for (NSIndexPath *index in selectedRows) {
            
            void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[[self navigationController] popViewControllerAnimated:YES];
                        [self.collectionView deselectItemAtIndexPath:index animated:YES];
                    });
                } else {
                    NSLog(@"Error: %@", error);
                }
            };
            
            NSInteger num = [self.collectionView numberOfItemsInSection:0];
            
            PHAsset *asset = self.assetsFetchResults[num - index.item -1];
            // Delete asset from library
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest deleteAssets:@[asset]];
            } completionHandler:completionHandler];
        }
    }
    
    
    self.cellSelectionMode = !self.cellSelectionMode;
    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
    
    if (self.cellSelectionMode) {
        self.navigationItem.rightBarButtonItems = @[self.moreButton];
        self.navigationItem.title = NSLocalizedString(@"select photo", nil);
    } else {
        self.navigationItem.rightBarButtonItems = @[self.editButton];
        self.navigationItem.title = self.assetCollection.localizedTitle;
    }
    //PHAsset *asset = self.assetsFetchResults[indexPath.item];
}

- (void)doMore{
    // Show activity view controller
    NSMutableArray *items = [[NSMutableArray alloc]init];
    
    NSArray *selectedRows = [self.collectionView indexPathsForSelectedItems];
    
    NSInteger num = [self.collectionView numberOfItemsInSection:0];
    for (NSIndexPath *index in selectedRows) {
        PHAsset *asset = self.assetsFetchResults[num - index.item -1];
        [self.imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      [items addObject:result];
                                  }];
        //[items addObject:asset];
    }
    
    __block UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    // Show loading spinner after a couple of seconds
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (activityViewController) {
        }
    });
    
    // Show
    [activityViewController setCompletionWithItemsHandler:
     ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
         activityViewController = nil;
         //[weakSelf hideControlsAfterDelay];
     }];

    

    if ( [activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        // iOS8
        activityViewController.popoverPresentationController.sourceView = self.collectionView;
    }
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}


- (void)doReturn{
}
@end
