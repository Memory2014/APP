//
//  MWGridViewController.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import "MWGridViewController.h"
#import "MWGridCell.h"
#import "MWPhotoBrowserPrivate.h"
#import "MWCommon.h"



@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end


@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end

@interface MWGridViewController () <UIScrollViewDelegate>{
    
    // Store margins for current setup
    CGFloat _margin, _gutter, _marginL, _gutterL, _columns, _columnsL;
    
}



@property (strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;
@property (strong, nonatomic) NSValue *targetRect;

@end

@implementation MWGridViewController

//static CGSize AssetGridThumbnailSize;


- (id)init {
    if ((self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]])) {
        
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
    return self;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[MWGridCell class] forCellWithReuseIdentifier:@"GridCell"];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor =[UIColor colorWithRed:0.9255 green:0.9255 blue:0.9255 alpha:1];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Cancel outstanding loading
    NSArray *visibleCells = [self.collectionView visibleCells];
    if (visibleCells) {
        for (MWGridCell *cell in visibleCells) {
            [cell.photo cancelAnyLoading];
        }
    }
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    CGFloat scale = [UIScreen mainScreen].scale;
//    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
//    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadImagesForOnscreenRows];
    //[self updateCachedAssets];
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
    
    // Check if current item is visible and if not, make it so!
    if (_browser.numberOfPhotos > 0) {
        NSIndexPath *currentPhotoIndexPath = [NSIndexPath indexPathForItem:_browser.currentIndex inSection:0];
        NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
        BOOL currentVisible = NO;
        for (NSIndexPath *indexPath in visibleIndexPaths) {
            if ([indexPath isEqual:currentPhotoIndexPath]) {
                currentVisible = YES;
                break;
            }
        }
        if (!currentVisible) {
            [self.collectionView scrollToItemAtIndexPath:currentPhotoIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
    
}

- (void)performLayout {
    
    self.view.backgroundColor = [UIColor colorWithRed:0.9255 green:0.9255 blue:0.9255 alpha:1];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    //self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    //self.navigationController.navigationBar.translucent = NO;
    //[temp.navigationController.navigationBar.backgroundColor :[UIColor blueColor]];
    self.collectionView.contentInset = UIEdgeInsetsMake(navBar.frame.origin.y + navBar.frame.size.height + [self getGutter], 0, 0, 0);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView reloadData];
    [self performLayout]; // needed for iOS 5 & 6
}

#pragma mark - Layout

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

#pragma mark - Collection View

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

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    NSInteger numbers = [_browser numberOfPhotos];
    if (numbers == 0) {
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]];
        //imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self initBlankView];
        self.collectionView.backgroundView.hidden = NO;
    }else {
        self.collectionView.backgroundView.hidden = YES;
    }
    
   return [_browser numberOfPhotos];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MWGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[MWGridCell alloc] init];
    }
    id <MWPhoto> photo = [_browser thumbPhotoAtIndex:indexPath.row];
    cell.photo = photo;
    cell.gridController = self;
    cell.selectionMode = _selectionMode;
    //cell.isSelected = [_browser photoIsSelectedAtIndex:indexPath.row];
    cell.index = indexPath.row;
//    UIImage *img = [_browser imageForPhoto:photo];
//    
//    if (img) {
//        [cell displayImage];
//    } else {
//        
//        //[photo loadUnderlyingImageAndNotify];
//    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_browser setCurrentPhotoIndex:indexPath.row];
    //[_browser hideGrid];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [((MWGridCell *)cell).photo cancelAnyLoading];
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
        
        
        
        if (addedIndexPaths.count == 0) { return; }
        
        //NSMutableArray *assets = [NSMutableArray arrayWithCapacity:addedIndexPaths.count];
        for (NSIndexPath *indexPath in addedIndexPaths) {
            
            id <MWPhoto> photo = [_browser thumbPhotoAtIndex:indexPath.row];
            MWGridCell *cell = (MWGridCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            UIImage *img = [_browser imageForPhoto:photo];
            if (img) {
                [cell displayImage];
            } else {
                
                [photo loadUnderlyingImageAndNotify];
            }
        }
        
        
        //[self updateImageAtIndexPaths:addedIndexPaths];
        
        //NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        //NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
//        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
//                                            targetSize:AssetGridThumbnailSize
//                                           contentMode:PHImageContentModeAspectFill
//                                               options:nil];
//        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
//                                           targetSize:AssetGridThumbnailSize
//                                          contentMode:PHImageContentModeAspectFill
//                                              options:nil];
        
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

- (void)updateImageAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return; }
    
    for (NSIndexPath *indexPath in indexPaths) {
        
        id <MWPhoto> photo = [_browser thumbPhotoAtIndex:indexPath.row];
        MWGridCell *cell = (MWGridCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        //CGRect cellFrame = self.collectionView.bounds;  // [self.collectionView rectForRowAtIndexPath:indexPath];
        
        UIImage *img = [_browser imageForPhoto:photo];
        if (img) {
            [cell displayImage];
        } else {
            
            [photo loadUnderlyingImageAndNotify];
        }
    }
    return ;
}

// -------------------------------------------------------------------------------
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
//// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([_browser numberOfPhotos] > 0)
    {
        NSArray *visiblePaths = [self.collectionView indexPathsForVisibleItems];  // indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            
            id <MWPhoto> photo = [_browser thumbPhotoAtIndex:indexPath.row];
            
            MWGridCell *cell = (MWGridCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
//            CGRect cellFrame = self.collectionView.bounds;  // [self.collectionView rectForRowAtIndexPath:indexPath];
//            
//            if (CGRectIntersectsRect([self.targetRect CGRectValue], cellFrame)) {
//
//                }
            UIImage *img = [_browser imageForPhoto:photo];
            
            if (img) {
                [cell displayImage];
            } else {
                
                [photo loadUnderlyingImageAndNotify];
            }

        }
    }

}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self updateCachedAssets];
//}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    CGRect targetRect = CGRectMake(targetContentOffset->x, targetContentOffset->y, scrollView.frame.size.width, scrollView.frame.size.height);
    
    self.targetRect = [NSValue valueWithCGRect:targetRect];
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

@end
