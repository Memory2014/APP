//
//  UIColor+HexColor.h
//  Photo
//
//  Created by zhongyi on 16/3/27.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)

+ (UIColor *)colorWithHex:(int)hex;
+ (UIColor *)colorWithHex:(int)hex withAlpha:(CGFloat)alpha;


@end
