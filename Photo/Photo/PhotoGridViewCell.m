//
//  PhotoGridViewCell.m
//  Photo
//
//  Created by zhongyi on 16/1/1.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "PhotoGridViewCell.h"

@interface PhotoGridViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *livePhotoBadgeImageView;


@end

@implementation PhotoGridViewCell

- (id)initWithFrame:(CGRect)frame{
    
    NSLog(@"frame");
    
    if ([super initWithFrame:frame]) {
    self.imageView.frame = self.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.livePhotoBadgeImageView.contentMode = UIViewContentModeScaleAspectFill|UIViewContentModeTopRight;
    //self.livePhotoBadgeImageView.frame = CGRectMake(5, 5, 25, 25);
    self.livePhotoBadgeImageView.frame = CGRectMake(self.bounds.size.width - self.livePhotoBadgeImageView.frame.size.width - 0,0, self.livePhotoBadgeImageView.frame.size.width, self.livePhotoBadgeImageView.frame.size.height);
        
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    return self;
    }
    return nil;
}

//- (void)awakeFromNib{
//    [super awakeFromNib];
//    self.imageView.frame = self.bounds;
//    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    self.imageView.clipsToBounds = YES;
//    self.imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//    
//    self.livePhotoBadgeImageView.contentMode = UIViewContentModeScaleAspectFill|UIViewContentModeTopRight;
//    self.livePhotoBadgeImageView.frame = CGRectMake(self.bounds.size.width - self.livePhotoBadgeImageView.frame.size.width - 0,0, self.livePhotoBadgeImageView.frame.size.width, self.livePhotoBadgeImageView.frame.size.height);
//    
//    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
//}


- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.livePhotoBadgeImageView.image = nil;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.frame = self.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.imageView.image = thumbnailImage;
}

- (void)setLivePhotoBadgeImage:(UIImage *)livePhotoBadgeImage {
    _livePhotoBadgeImage = livePhotoBadgeImage;
    self.livePhotoBadgeImageView.image = livePhotoBadgeImage;
    self.livePhotoBadgeImageView.contentMode = UIViewContentModeScaleAspectFill|UIViewContentModeTopRight;
    self.livePhotoBadgeImageView.frame = CGRectMake(self.bounds.size.width - self.livePhotoBadgeImageView.frame.size.width - 0,0, self.livePhotoBadgeImageView.frame.size.width, self.livePhotoBadgeImageView.frame.size.height);
}

@end
