//
//  ZYImage.h
//  SamplePhotosApp
//
//  Created by zhongyi on 15/12/28.
//
//

#import <UIKit/UIKit.h>

@interface ZYImage : UIImage

- (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle;
- (UIImage *)clearImageWithSize:(CGSize)size;

@end
