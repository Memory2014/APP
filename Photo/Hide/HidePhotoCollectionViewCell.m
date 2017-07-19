//
//  HidePhotoCollectionViewCell.m
//  Photo
//
//  Created by zhongyi on 16/1/5.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "HidePhotoCollectionViewCell.h"

@interface HidePhotoCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *livePhotoBadgeImageView;

@end

@implementation HidePhotoCollectionViewCell

- (id)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        self.imageView.frame = self.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        self.livePhotoBadgeImageView.contentMode = UIViewContentModeScaleAspectFill|UIViewContentModeTopRight;
        self.livePhotoBadgeImageView.frame = CGRectMake(self.bounds.size.width - self.livePhotoBadgeImageView.frame.size.width - 0,0, self.livePhotoBadgeImageView.frame.size.width, self.livePhotoBadgeImageView.frame.size.height);
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
        return self;
    }
    return nil;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.livePhotoBadgeImageView.image = nil;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.frame = self.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.image = thumbnailImage;
    //self.imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)setLivePhotoBadgeImage:(UIImage *)livePhotoBadgeImage {
    _livePhotoBadgeImage = livePhotoBadgeImage;
    self.livePhotoBadgeImageView.image = livePhotoBadgeImage;
    self.livePhotoBadgeImageView.contentMode = UIViewContentModeScaleAspectFill|UIViewContentModeTopRight;
    self.livePhotoBadgeImageView.frame = CGRectMake(self.bounds.size.width - self.livePhotoBadgeImageView.frame.size.width - 0,0, self.livePhotoBadgeImageView.frame.size.width, self.livePhotoBadgeImageView.frame.size.height);
    
}

@end
