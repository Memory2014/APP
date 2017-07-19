
//#import <Foundation/Foundation.h>

@import UIKit;

@protocol ZYTapDetectingImageViewDelegate;

@interface ZYTapDetectingImageView : UIImageView;

@property (nonatomic, weak) id <ZYTapDetectingImageViewDelegate> tapDelegate;

@end


@protocol ZYTapDetectingImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end