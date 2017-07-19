//
//  PhotoTableViewCell.m
//  Photo
//
//  Created by zhongyi on 16/1/2.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "PhotoTableViewCell.h"

@implementation PhotoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    self.photoCount.text = @"";
    self.albumName.text = @"";
    self.albumPhoto.image = [UIImage imageNamed:@"cell.png"];
    //self.photoCount.font = [UIFont fontWithName:@"PingFangHK-Light" size:12];
    //self.albumName.font = [UIFont fontWithName:@"PingFangHK-Light" size:12];
    //self.photoCount.textColor = [UIColor grayColor];
    
    self.albumPhoto.contentMode = UIViewContentModeScaleAspectFill;
    self.albumPhoto.clipsToBounds = YES;
    self.albumPhoto.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.borderStyle = BaseCellBorderStyleAllRound;
    //self.contentBorderColor = [UIColor lightGrayColor];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.photoCount.text = @"";
        self.albumName.text = @"";
        self.albumPhoto.image = [UIImage imageNamed:@"cell.png"];
        
        //self.photoCount.font = [UIFont fontWithName:@"PingFangHK-Light" size:12];
        //self.albumName.font = [UIFont fontWithName:@"PingFangHK-Light" size:12];
       // self.photoCount.textColor = [UIColor grayColor];
        //cell.albumName.textColor = [UIColor grayColor];
        
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
