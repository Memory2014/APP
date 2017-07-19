//
//  HideVideoCollectionViewCell.m
//  Photo
//
//  Created by zhongyi on 16/1/10.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "HideVideoCollectionViewCell.h"

@interface HideVideoCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *livePhotoBadgeImageView;

@end

@implementation HideVideoCollectionViewCell

- (id)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        self.imageView.frame = self.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        self.livePhotoBadgeImageView.contentMode = UIViewContentModeScaleAspectFill|UIViewContentModeTopRight;
        self.livePhotoBadgeImageView.frame = CGRectMake(self.bounds.size.width - self.livePhotoBadgeImageView.frame.size.width - 0,0, self.livePhotoBadgeImageView.frame.size.width, self.livePhotoBadgeImageView.frame.size.height);
        
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
    self.imageView.image = thumbnailImage;
    self.imageView.frame = self.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)setLivePhotoBadgeImage:(UIImage *)livePhotoBadgeImage {
    _livePhotoBadgeImage = livePhotoBadgeImage;
    self.livePhotoBadgeImageView.image = livePhotoBadgeImage;
    self.livePhotoBadgeImageView.contentMode = UIViewContentModeScaleAspectFill|UIViewContentModeTopRight;
    self.livePhotoBadgeImageView.frame = CGRectMake(self.bounds.size.width - self.livePhotoBadgeImageView.frame.size.width - 0,0, self.livePhotoBadgeImageView.frame.size.width, self.livePhotoBadgeImageView.frame.size.height);
    
}


@end
