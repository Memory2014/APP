

#import <Foundation/Foundation.h>

@import UIKit;

@protocol MWTapDetectingImageViewDelegate;

@interface MWTapDetectingImageView : UIImageView {}

@property (nonatomic, weak) id <MWTapDetectingImageViewDelegate> tapDelegate;

@end

@protocol MWTapDetectingImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end