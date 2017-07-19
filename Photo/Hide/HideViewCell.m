//
//  PhotoTableViewCell.m
//  PhotoView
//
//  Created by zhongyi on 15/9/21.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import "HideViewCell.h"

@implementation HideViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    //self.photoCount.text = @"";
    //self.albumName.text = @"";
    //self.albumPhoto.image = [UIImage imageNamed:@"0.png"];
    
    self.photoCount.text = @"";
    self.albumName.text = @"";
    self.albumPhoto.image = [UIImage imageNamed:@"cell.png"];
    
    //self.photoCount.font = [UIFont fontWithName:@"PingFangHK-Light" size:12];
    //self.albumName.font = [UIFont fontWithName:@"PingFangHK-Light" size:12];
    //self.photoCount.textColor = [UIColor grayColor];
    //cell.albumName.textColor = [UIColor grayColor];
    
    self.albumPhoto.frame = self.bounds;
    self.albumPhoto.contentMode = UIViewContentModeScaleAspectFill;
    self.albumPhoto.clipsToBounds = YES;
    self.albumPhoto.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.photoCount.text = @"";
        self.albumName.text = @"";
        self.albumPhoto.image = [UIImage imageNamed:@"cell.png"];
        
        //self.photoCount.font = [UIFont fontWithName:@"PingFangHK-Light" size:12];
        //self.albumName.font = [UIFont fontWithName:@"PingFangHK-Light" size:12];
        //self.photoCount.textColor = [UIColor grayColor];
        //cell.albumName.textColor = [UIColor grayColor];
        
        self.albumPhoto.frame = self.bounds;
        self.albumPhoto.contentMode = UIViewContentModeScaleAspectFill;
        self.albumPhoto.clipsToBounds = YES;
        self.albumPhoto.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
