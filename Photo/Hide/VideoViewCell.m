//
//  VideoViewCell.m
//  PhotoView
//
//  Created by zhongyi on 15/9/28.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import "VideoViewCell.h"

@implementation VideoViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.photoCount.text = @"";
        self.albumName.text = @"";
        self.albumPhoto.image = [UIImage imageNamed:@"video_cell.png"];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
