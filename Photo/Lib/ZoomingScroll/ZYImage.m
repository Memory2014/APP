//
//  ZYImage.m
//  SamplePhotosApp
//
//  Created by zhongyi on 15/12/28.
//
//

#import "ZYImage.h"

@implementation ZYImage


- (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle {
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:path ofType:type]];
}

- (UIImage *)clearImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

@end
