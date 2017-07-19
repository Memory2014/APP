//
//  ThemesCollectionViewCell.m
//  PhotoPRO
//
//  Created by zhong on 7/26/16.
//  Copyright © 2016 zhongyi. All rights reserved.
//

#import "ThemesCollectionViewCell.h"

@implementation ThemesCollectionViewCell


- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self.layer setCornerRadius: 40];
}



- (void)cellUpdate:(BOOL)selected{
    if (selected) {
        [self.layer setBorderWidth:5.0];
        [self.layer setBorderColor:[UIColor greenColor].CGColor];

    }else{
        [self.layer setBorderWidth:.0];
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
    }
}

@end
