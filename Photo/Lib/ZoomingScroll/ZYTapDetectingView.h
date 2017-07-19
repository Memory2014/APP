

#import <Foundation/Foundation.h>
@import UIKit;

@protocol ZYTapDetectingViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end



@protocol ZYTapDetectingViewDelegate;

@interface ZYTapDetectingView:UIView;

@property (nonatomic, weak) id <ZYTapDetectingViewDelegate> tapDelegate;

@end

