

#import "ZYTapDetectingImageView.h"
#import "ZYTapDetectingView.h"
//#import "ZYCaptionView.h"

@import UIKit;
@import Photos;

@class PhotoViewController;

@interface ZYZoomingScrollView : UIScrollView <UIScrollViewDelegate, ZYTapDetectingImageViewDelegate, ZYTapDetectingViewDelegate> {

}


@property () NSUInteger index;
@property (nonatomic, weak) UIImage *image;
//@property (nonatomic, weak) ZYCaptionView *captionView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;
//

- (id)initWithPhotoBrowser:(PhotoViewController *)browser;

//- (id)init;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;
//
@end
