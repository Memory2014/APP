//
//  ThemesTableViewCell.m
//  Photo
//
//  Created by zhongyi on 16/3/27.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "ThemesTableViewCell.h"

@implementation ThemesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _button.layer.cornerRadius = 5;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    _button.layer.cornerRadius = 5;
}

@end
