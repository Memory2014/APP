

#import <Foundation/Foundation.h>

@import UIKit;

@protocol MWTapDetectingViewDelegate;

@interface MWTapDetectingView : UIView {}

@property (nonatomic, weak) id <MWTapDetectingViewDelegate> tapDelegate;

@end

@protocol MWTapDetectingViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end