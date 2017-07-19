//
//  ColorArray.h
//  Photo
//
//  Created by zhongyi on 16/3/27.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ColorArray : NSArray
@property (nonatomic,copy) ColorArray *colorArray;

+ (ColorArray *)initWithColor;
+ (ColorArray *)initWithHexColor;
+ (NSArray *)initWithColorHex;
@end

