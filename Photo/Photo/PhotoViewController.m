//
//  PhotoViewController.m
//  Photo
//
//  Created by zhongyi on 16/1/1.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "PhotoViewController.h"
//#import "ZYZoomingScrollView.h"
//#import "ZoomingScroll/ZYZoomingScrollView.h"

#define PADDING                  10

@implementation CIImage (Convenience)
- (NSData *)aapl_jpegRepresentationWithCompressionQuality:(CGFloat)compressionQuality {
    static CIContext *ciContext = nil;
    if (!ciContext) {
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        ciContext = [CIContext contextWithEAGLContext:eaglContext];
    }
    CGImageRef outputImageRef = [ciContext createCGImage:self fromRect:[self extent]];
    UIImage *uiImage = [[UIImage alloc] initWithCGImage:outputImageRef scale:1.0 orientation:UIImageOrientationUp];
    if (outputImageRef) {
        CGImageRelease(outputImageRef);
    }
    NSData *jpegRepresentation = UIImageJPEGRepresentation(uiImage, compressionQuality);
    return jpegRepresentation;
}
@end

@interface PhotoViewController () <PHPhotoLibraryChangeObserver,UIGestureRecognizerDelegate,UIScrollViewDelegate>{
    
    int _currentIndex;
    int _assetCount;
    
    UIScrollView *_scrollView;
    UIImageView *_leftImageView;
    UIImageView *_centerImageView;
    UIImageView *_rightImageView;
}

//@property () NSInteger
@property (weak) IBOutlet UIImageView *imageView;
@property (strong) IBOutlet UIBarButtonItem *playButton;
@property (strong) IBOutlet UIBarButtonItem *space;
@property (strong) IBOutlet UIBarButtonItem *trashButton;
@property (strong) IBOutlet UIBarButtonItem *editButton;
@property (strong) IBOutlet UIProgressView *progressView;
@property (strong) AVPlayerLayer *playerLayer;
@property (assign) CGSize lastImageViewSize;

@property (strong) PHCachingImageManager *imageManager;
//@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (strong, nonatomic) IBOutlet UIView *contentView;
@end


@implementation PhotoViewController


static NSString * const AdjustmentFormatIdentifier = @"com.example.apple-samplecode.SamplePhotosApp";

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    _imageView.hidden = YES;
    
    _currentIndex = (int)_index;
    _assetCount = (int)_assetsFetchResults.count ;
    
    [self addScrollView];
    [self addImageViews];
    
//    self.view.backgroundColor = [UIColor whiteColor];
//    self.view.clipsToBounds = YES;
//    
//    // Setup paging scrolling view
//    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
//    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
//    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    _pagingScrollView.pagingEnabled = YES;
//    _pagingScrollView.delegate = self;
//    _pagingScrollView.showsHorizontalScrollIndicator = NO;
//    _pagingScrollView.showsVerticalScrollIndicator = NO;
//    _pagingScrollView.backgroundColor = [UIColor whiteColor];
//    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
//    [self.view addSubview:_pagingScrollView];
//    
//    // Update
//    [self reloadData];
//    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (self.asset.mediaType == PHAssetMediaTypeVideo) {
//        self.toolbarItems = @[self.playButton, self.space, self.trashButton];
//    } else {
//        self.toolbarItems = @[self.space, self.trashButton];
//    }
//    
//    BOOL isEditable = ([self.asset canPerformEditOperation:PHAssetEditOperationProperties] || [self.asset canPerformEditOperation:PHAssetEditOperationContent]);
//    self.editButton.enabled = isEditable;
//    
//    BOOL isTrashable = NO;
//    if (self.assetCollection) {
//        isTrashable = [self.assetCollection canPerformEditOperation:PHCollectionEditOperationRemoveContent];
//    } else {
//        isTrashable = [self.asset canPerformEditOperation:PHAssetEditOperationDelete];
//    }
//    self.trashButton.enabled = isTrashable;
    
    //_imageView.contentMode=UIViewContentModeScaleAspectFit;    //设置内容模式为缩放填充
    //_imageView.userInteractionEnabled=YES;                  //这里必须设置位YES，否则无法接收手势操作
    
    [self.view layoutIfNeeded];
    //[self updateImage:];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!CGSizeEqualToSize(self.imageView.bounds.size, self.lastImageViewSize)) {
        [self updateImage];
    }
    
    //[self layoutVisiblePages];
}


- (void)updateImage

{
    NSLog(@"update");
    
    NSLog(@"%i",(_currentIndex + _assetCount - 1)% _assetCount);
    NSLog(@"%i",_currentIndex);
    NSLog(@"%i",(_currentIndex + 1)% _assetCount);
    self.lastImageViewSize = self.imageView.bounds.size;
    
//    _centerImageView.image = nil;
    _leftImageView.image = nil;
    _rightImageView.image = nil;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.imageView.bounds) * scale, CGRectGetHeight(self.imageView.bounds) * scale);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    

        PHAsset *asset = self.assetsFetchResults[_currentIndex];
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                           _centerImageView.image = result;
                //            dispatch_async(dispatch_get_main_queue(), ^{
                //              // _centerImageView.image = result;
                //            });
            }
        }];


    
    PHAsset *asset2 = self.assetsFetchResults[(_currentIndex + _assetCount - 1)% _assetCount];
        [[PHImageManager defaultManager] requestImageForAsset:asset2 targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                _leftImageView.image = result;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //_leftImageView.image = result;
                });
            }
        }];
    
    PHAsset *asset3 = self.assetsFetchResults[(_currentIndex + 1)% _assetCount];
        [[PHImageManager defaultManager] requestImageForAsset:asset3 targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                _rightImageView.image = result;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //_rightImageView.image = result;
                });
            }
        }];

}

-(void)reloadImage{
    
    CGPoint offset=[_scrollView contentOffset];
    //NSLog(@"%f",_scrollView.contentOffset.x);
    //NSLog(@"%f",self.imageView.bounds.size.width);
    //NSLog(NSStringFromCGPoint(offset));
    if (offset.x > self.imageView.bounds.size.width) {
        _currentIndex = (_currentIndex + 1) % _assetCount;
        
        [self updateImage];
    }else if( offset.x < self.imageView.bounds.size.width){
        _currentIndex = (_currentIndex + _assetCount - 1) % _assetCount;
        [self updateImage];
    }
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self reloadImage];
    //[_scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
    NSLog(@"endscroll");
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    
    NSLog(@"willscroll");
    //[self reloadImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    //NSLog(@"%f",scrollView.contentOffset.x);
}

//- (CGPoint)nearestTargetOffsetForOffset:(CGPoint)offset
//{
//    CGFloat pageSize = self.view.frame.size.width;
//    NSInteger page = roundf(offset.x / pageSize);
//    CGFloat targetX = pageSize * page;
//    return CGPointMake(targetX, offset.y);
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    CGPoint targetOffset = [self nearestTargetOffsetForOffset:*targetContentOffset];
//    targetContentOffset->x = targetOffset.x;
//    targetContentOffset->y = targetOffset.y;
//}


//#pragma mark 显示图片名称
////-(void)showPhotoName{
////    NSString *title=[NSString stringWithFormat:@"%i.jpg",_currentIndex];
////    [self setTitle:title];
////}
//
//#pragma mark 下一张图片
//-(void)nextImage{
//    
//    if (_index >= _assetsFetchResults.count -1) {
//        return;
//    }
//    self.index += 1;
//    self.asset = self.assetsFetchResults[_index];
//    [self updateImage];
//}
//
//#pragma mark 上一张图片
//-(void)lastImage{
//    
//    if (0 == _index) {
//        return;
//    }
//    self.index -= 1;
//    self.asset = self.assetsFetchResults[_index];
//    [self updateImage];
//}


#pragma mark 添加控件
-(void)addScrollView{
    _scrollView=[[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_scrollView];
    //设置代理
    _scrollView.delegate=self;
    //设置contentSize
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height);
    //设置当前显示的位置为中间图片
    [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
    //设置分页
    _scrollView.pagingEnabled=YES;
    //去掉滚动条
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
}


#pragma mark 添加图片三个控件
-(void)addImageViews{
    _leftImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _leftImageView.contentMode=UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_leftImageView];
    _centerImageView=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _centerImageView.contentMode=UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_centerImageView];
    _rightImageView=[[UIImageView alloc]initWithFrame:CGRectMake(2*self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _rightImageView.contentMode=UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_rightImageView];
    
}

//#pragma mark 添加手势
//-(void)addGesture{
//    /*添加点按手势*/
//    //创建手势对象
//    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
//    //设置手势属性
//    tapGesture.numberOfTapsRequired=1;//设置点按次数，默认为1，注意在iOS中很少用双击操作
//    tapGesture.numberOfTouchesRequired=1;//点按的手指数
//    //添加手势到对象(注意，这里添加到了控制器视图中，而不是图片上，否则点击空白无法隐藏导航栏)
//    [self.view addGestureRecognizer:tapGesture];
//    
//    
//    /*添加长按手势*/
//    UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
//    longPressGesture.minimumPressDuration=0.5;//设置长按时间，默认0.5秒，一般这个值不要修改
//    //注意由于我们要做长按提示删除操作，因此这个手势不再添加到控制器视图上而是添加到了图片上
//    [_imageView addGestureRecognizer:longPressGesture];
//    
//    /*添加捏合手势*/
//    UIPinchGestureRecognizer *pinchGesture=[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchImage:)];
//    [self.view addGestureRecognizer:pinchGesture];
//    
//    /*添加旋转手势*/
//    UIRotationGestureRecognizer *rotationGesture=[[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotateImage:)];
//    [self.view addGestureRecognizer:rotationGesture];
//    
//    /*添加拖动手势*/
//    UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panImage:)];
//    [_imageView addGestureRecognizer:panGesture];
//    
//    /*添加轻扫手势*/
//    //注意一个轻扫手势只能控制一个方向，默认向右，通过direction进行方向控制
//    UISwipeGestureRecognizer *swipeGestureToRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeImage:)];
//    //swipeGestureToRight.direction=UISwipeGestureRecognizerDirectionRight;//默认位向右轻扫
//    [self.view addGestureRecognizer:swipeGestureToRight];
//    
//    UISwipeGestureRecognizer *swipeGestureToLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeImage:)];
//    swipeGestureToLeft.direction=UISwipeGestureRecognizerDirectionLeft;
//    [self.view addGestureRecognizer:swipeGestureToLeft];
//    
//    //解决在图片上滑动时拖动手势和轻扫手势的冲突
//    [panGesture requireGestureRecognizerToFail:swipeGestureToRight];
//    [panGesture requireGestureRecognizerToFail:swipeGestureToLeft];
//    //解决拖动和长按手势之间的冲突
//    [longPressGesture requireGestureRecognizerToFail:panGesture];
//    
//    
//    /*演示不同视图的手势同时执行
//     *在上面_imageView已经添加了长按手势，这里给视图控制器的视图也加上长按手势让两者都执行
//     *
//     */
//    self.view.tag=100;
//    _imageView.tag=200;
//    UILongPressGestureRecognizer *viewLongPressGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressView:)];
//    viewLongPressGesture.delegate=self;
//    [self.view addGestureRecognizer:viewLongPressGesture];
//    
//}
//
//#pragma mark - 手势操作
//#pragma mark 点按隐藏或显示导航栏
//-(void)tapImage:(UITapGestureRecognizer *)gesture{
//    //NSLog(@"tap:%i",gesture.state);
//    BOOL hidden=!self.navigationController.navigationBarHidden;
//    [self.navigationController setNavigationBarHidden:hidden animated:YES];
//}
//
//#pragma mark 长按提示是否删除
//-(void)longPressImage:(UILongPressGestureRecognizer *)gesture{
//    //NSLog(@"longpress:%i",gesture.state);
//    //注意其实在手势里面有一个view属性可以获取点按的视图
//    //UIImageView *imageView=(UIImageView *)gesture.view;
//    
//    //由于连续手势此方法会调用多次，所以需求判断其手势状态
//    if (gesture.state==UIGestureRecognizerStateBegan) {
//        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"System Info" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete the photo" otherButtonTitles:nil];
//        [actionSheet showInView:self.view];
//        
//    }
//}
//
//#pragma mark 捏合时缩放图片
//-(void)pinchImage:(UIPinchGestureRecognizer *)gesture{
//    //NSLog(@"pinch:%i",gesture.state);
//    
//    if (gesture.state==UIGestureRecognizerStateChanged) {
//        //捏合手势中scale属性记录的缩放比例
//        //_imageView.transform=CGAffineTransformMakeScale(gesture.scale, gesture.scale);
//        _imageView.transform = CGAffineTransformScale( _imageView.transform, gesture.scale, gesture.scale);
//    }else if(gesture.state==UIGestureRecognizerStateEnded){//结束后恢复
////        [UIView animateWithDuration:.5 animations:^{
////            _imageView.transform=CGAffineTransformIdentity;//取消一切形变
////        }];
//    }
//}
//
//#pragma mark 旋转图片
//-(void)rotateImage:(UIRotationGestureRecognizer *)gesture{
//    //NSLog(@"rotate:%i",gesture.state);
//    if (gesture.state==UIGestureRecognizerStateChanged) {
//        //旋转手势中rotation属性记录了旋转弧度
//        _imageView.transform=CGAffineTransformMakeRotation(gesture.rotation);
//    }else if(gesture.state==UIGestureRecognizerStateEnded){
//        [UIView animateWithDuration:0.8 animations:^{
//            _imageView.transform=CGAffineTransformIdentity;//取消形变
//        }];
//    }
//}
//
//#pragma mark 拖动图片
//-(void)panImage:(UIPanGestureRecognizer *)gesture{
//    if (gesture.state==UIGestureRecognizerStateChanged) {
//        
//        
//        //[gesture locationOfTouch:(NSUInteger) inView:<#(nullable UIView *)#>]
//        //CGPoint current = [gesture locationInView:self.imageView];
//        //        self.imageView.center = translation;
//        
//        CGPoint translation=[gesture translationInView:self.view];//利用拖动手势的translationInView:方法取得在相对指定视图（控制器根视图）的移动
//        _imageView.transform=CGAffineTransformMakeTranslation(translation.x, translation.y);
//    }else if(gesture.state==UIGestureRecognizerStateEnded){
////        [UIView animateWithDuration:0.5 animations:^{
////            _imageView.transform=CGAffineTransformIdentity;
////        }];
//    }
//    
//}
//
//#pragma mark 轻扫则查看下一张或上一张
////注意虽然轻扫手势是连续手势，但是只有在识别结束才会触发，不用判断状态
//-(void)swipeImage:(UISwipeGestureRecognizer *)gesture{
//    //    NSLog(@"swip:%i",gesture.state);
//    //    if (gesture.state==UIGestureRecognizerStateEnded) {
//    
//    //direction记录的轻扫的方向
//    if (gesture.direction==UISwipeGestureRecognizerDirectionRight) {//向右
//        [self nextImage];
//        NSLog(@"right");
//    }else if(gesture.direction==UISwipeGestureRecognizerDirectionLeft){//向左
//        NSLog(@"left");
//        [self lastImage];
//    }
//    //    }
//}
//
//
//
//#pragma mark 控制器视图的长按手势
//-(void)longPressView:(UILongPressGestureRecognizer *)gesture{
//    NSLog(@"view long press!");
//}
//
//
//#pragma mark 手势代理方法
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    //NSLog(@"%i,%i",gestureRecognizer.view.tag,otherGestureRecognizer.view.tag);
//    
//    //注意，这里控制只有在UIImageView中才能向下传播，其他情况不允许
//    if ([otherGestureRecognizer.view isKindOfClass:[UIImageView class]]) {
//        return YES;
//    }
//    return NO;
//}
//
//#pragma mark - 触摸事件
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    //NSLog(@"touch begin...");
//}
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    //NSLog(@"touch end.");
//}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the album we're interested on (to its metadata, not to its collection of assets)
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.asset];
        if (changeDetails) {
            // it changed, we need to fetch a new one
            self.asset = [changeDetails objectAfterChanges];
            
            if ([changeDetails assetContentChanged]) {
                [self updateImage];
                
                if (self.playerLayer) {
                    [self.playerLayer removeFromSuperlayer];
                    self.playerLayer = nil;
                }
            }
        }
        
    });
}


/*

#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return CGRectIntegral(frame);
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

#pragma mark - Data

- (NSUInteger)currentIndex {
    return _currentPageIndex;
}

- (void)reloadData {
    
    // Reset
    _photoCount = NSNotFound;
    
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    [self releaseAllUnderlyingPhotos:YES];
    [_photos removeAllObjects];
    for (int i = 0; i < numberOfPhotos; i++) {
        [_photos addObject:[NSNull null]];
    }
    
    // Update current page index
    if (numberOfPhotos > 0) {
        _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    } else {
        _currentPageIndex = 0;
    }
    
    // Update layout
    if ([self isViewLoaded]) {
        while (_pagingScrollView.subviews.count) {
            [[_pagingScrollView.subviews lastObject] removeFromSuperview];
        }
        [self performLayout];
        [self.view setNeedsLayout];
    }
}

- (NSUInteger)numberOfPhotos {
    if (_photoCount == NSNotFound) {
        _photoCount = _assetsFetchResults.count;
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}


- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent {
    // Create a copy in case this array is modified while we are looping through
    // Release photos
    NSArray *copy = [_photos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            if (preserveCurrent && p == [self photoAtIndex:self.currentIndex]) {
                continue; // skip current
            }
            //[p unloadUnderlyingImage];
        }
    }
}


- (UIImage *)photoAtIndex:(NSUInteger)index {
    __block UIImage *image = nil;
    if (index < _photos.count) {
        if ([_photos objectAtIndex:index] == [NSNull null]) {
            if (_fixedPhotosArray && index < _fixedPhotosArray.count)
            {
                image = [_fixedPhotosArray objectAtIndex:index];
            }
            if (image) [_photos replaceObjectAtIndex:index withObject:image];
        } else {
            image = [_photos objectAtIndex:index];
        }
    }
    return image;
}


- (void)performLayout {
    
    // Setup
    _performingLayout = YES;
    //NSUInteger numberOfPhotos = [self numberOfPhotos];
    
    // Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    // Update nav
    [self updateNavigation];
    
    // Content offset
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    _performingLayout = NO;
    
}


#pragma mark - Paging

- (void)tilePages {
    
    // Calculate which pages should be visible
    // Ignore padding as paging bounces encroach on that
    // and lead to false page loads
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
    
    // Recycle no longer needed pages
    NSInteger pageIndex;
    for (ZYZoomingScrollView *page in _visiblePages) {
        pageIndex = page.index;
        if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
            [_recycledPages addObject:page];
            //[page.captionView removeFromSuperview];
            //[page.selectedButton removeFromSuperview];
            [page.playButton removeFromSuperview];
            [page prepareForReuse];
            [page removeFromSuperview];
            //MWLog(@"Removed page at index %lu", (unsigned long)pageIndex);
        }
    }
    [_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
    
    // Add missing pages
    for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            
            // Add new page
            ZYZoomingScrollView *page = [self dequeueRecycledPage];
            if (!page) {
                page = [[ZYZoomingScrollView alloc] init];
            }
            [_visiblePages addObject:page];
            [self configurePage:page forIndex:index];
            
            [_pagingScrollView addSubview:page];
        }
    }
    
}


- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (ZYZoomingScrollView *page in _visiblePages)
        if (page.index == index) return YES;
    return NO;
}

- (ZYZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
    ZYZoomingScrollView *thePage = nil;
    for (ZYZoomingScrollView *page in _visiblePages) {
        if (page.index == index) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (ZYZoomingScrollView *)pageDisplayingPhoto:(UIImage *)image {
    ZYZoomingScrollView *thePage = nil;
    for (ZYZoomingScrollView *page in _visiblePages) {
        if (page.image == image) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (void)configurePage:(ZYZoomingScrollView *)page forIndex:(NSUInteger)index {
    page.frame = [self frameForPageAtIndex:index];
    page.index = index;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(page.bounds) * scale, CGRectGetHeight(page.bounds) * scale);
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    PHAsset *asset = self.assetsFetchResults[_currentIndex];
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result) {
            page.image = result;
        }
    }];
}

- (ZYZoomingScrollView *)dequeueRecycledPage {
    ZYZoomingScrollView *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}


#pragma mark - Navigation

- (void)updateNavigation {
    
    // Title
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    
    NSString *photosText;
    if (numberOfPhotos == 1) {
        photosText = NSLocalizedString(@"photo", @"Used in the context: '1 photo'");
    } else {
        photosText = NSLocalizedString(@"photos", @"Used in the context: '3 photos'");
    }
    self.title = [NSString stringWithFormat:@"%lu %@", (unsigned long)numberOfPhotos, photosText];
    
    if (numberOfPhotos > 1) {
        self.title = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(_currentPageIndex+1), NSLocalizedString(@"of", @"Used in the context: 'Showing 1 of 3 items'"), (unsigned long)numberOfPhotos];
    }
    
}

#pragma mark - Layout

//- (void)viewWillLayoutSubviews{
//    
//}
//
//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    [self layoutVisiblePages];
//}

- (void)layoutVisiblePages {
    
    // Flag
    _performingLayout = YES;
    
    // Toolbar
    //_toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
    
    // Remember index
    NSUInteger indexPriorToLayout = _currentPageIndex;
    
    // Get paging scroll view frame to determine if anything needs changing
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
    // Frame needs changing
    if (!_skipNextPagingScrollViewPositioning) {
        _pagingScrollView.frame = pagingScrollViewFrame;
    }
    _skipNextPagingScrollViewPositioning = NO;
    
    // Recalculate contentSize based on current orientation
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // Adjust frames and configuration of each visible page
    for (ZYZoomingScrollView *page in _visiblePages) {
        NSUInteger index = page.index;
//        page.frame = [self frameForPageAtIndex:index];
//        if (page.captionView) {
//            page.captionView.frame = [self frameForCaptionView:page.captionView atIndex:index];
//        }
//        if (page.selectedButton) {
//            page.selectedButton.frame = [self frameForSelectedButton:page.selectedButton atIndex:index];
//        }
//        if (page.playButton) {
//            page.playButton.frame = [self frameForPlayButton:page.playButton atIndex:index];
//        }
        
        // Adjust scales if bounds has changed since last time
        if (!CGRectEqualToRect(_previousLayoutBounds, self.view.bounds)) {
            // Update zooms for new bounds
            [page setMaxMinZoomScalesForCurrentBounds];
            _previousLayoutBounds = self.view.bounds;
        }
        
    }
    
    // Adjust video loading indicator if it's visible
    //[self positionVideoLoadingIndicator];
    
    // Adjust contentOffset to preserve page location based on values collected prior to location
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
    [self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    
    // Reset
    _currentPageIndex = indexPriorToLayout;
    _performingLayout = NO;
    
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    
    // Handle 0 photos
    if (![self numberOfPhotos]) {
        // Show controls
        //[self setControlsHidden:NO animated:YES permanent:YES];
        return;
    }
    
    // Handle video on page change
    if (!_rotating || index != _currentVideoIndex) {
        //[self clearCurrentVideo];
    }
    
    // Release images further away than +/-1
    NSUInteger i;
    if (index > 0) {
        // Release anything < index - 1
        for (i = 0; i < index-1; i++) {
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                //[photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                //MWLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    if (index < [self numberOfPhotos] - 1) {
        // Release anything > index + 1
        for (i = index + 2; i < _photos.count; i++) {
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                //[photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                //MWLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    //id <MWPhoto> currentPhoto = [self photoAtIndex:index];
    //if ([currentPhoto underlyingImage]) {
        // photo loaded so load ajacent now
    //[self loadAdjacentPhotosIfNecessary:index];
    //}
    
    // Notify delegate
    if (index != _previousPageIndex) {
//        if ([_delegate respondsToSelector:@selector(photoBrowser:didDisplayPhotoAtIndex:)])
//            [_delegate photoBrowser:self didDisplayPhotoAtIndex:index];
        _previousPageIndex = index;
    }
    
    // Update nav
    [self updateNavigation];
    
}


//- (void)loadAdjacentPhotosIfNecessary:(NSUInteger)index {
//    ZYZoomingScrollView *page = [self pageDisplayingPhoto:photo];
//    if (page) {
//        // If page is current page then initiate loading of previous and next pages
//        NSUInteger pageIndex = page.index;
//        if (_currentPageIndex == pageIndex) {
//            if (pageIndex > 0) {
//                // Preload index - 1
//                //id <MWPhoto> photo = [self photoAtIndex:pageIndex-1];
////                if (![photo underlyingImage]) {
////                    [photo loadUnderlyingImageAndNotify];
////                    MWLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex-1);
////                }
//            }
//            if (pageIndex < [self numberOfPhotos] - 1) {
//                // Preload index + 1
////                id <MWPhoto> photo = [self photoAtIndex:pageIndex+1];
////                if (![photo underlyingImage]) {
////                    [photo loadUnderlyingImageAndNotify];
////                    MWLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex+1);
////                }
//            }
//        }
//    }
//    
//    
//    MWZoomingScrollView *page = [self pageDisplayingPhoto:photo];
//    if (page) {
//        if ([photo underlyingImage]) {
//            // Successful load
//            [page displayImage];
//            [self loadAdjacentPhotosIfNecessary:photo];
//        } else {
//            
//            // Failed to load
//            [page displayImageFailure];
//        }
//        // Update nav
//        [self updateNavigation];
//    }
//}
*/

@end
