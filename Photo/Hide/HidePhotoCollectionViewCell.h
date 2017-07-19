//
//  HidePhotoCollectionViewCell.h
//  Photo
//
//  Created by zhongyi on 16/1/5.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HidePhotoCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *livePhotoBadgeImage;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end
