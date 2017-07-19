//
//  PhotoGridViewCell.h
//  Photo
//
//  Created by zhongyi on 16/1/1.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoGridViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *livePhotoBadgeImage;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end
