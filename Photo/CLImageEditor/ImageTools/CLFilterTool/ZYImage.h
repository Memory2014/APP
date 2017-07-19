//
//  ZYImage.h
//  PhotoPRO
//
//  Created by zhongyi on 16/3/13.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface ZYImage : NSObject

//实现滤镜效果
+ (UIImage *)imageWithImage:(UIImage*)inImage withColorMatrix:(const float*)f;


@end
