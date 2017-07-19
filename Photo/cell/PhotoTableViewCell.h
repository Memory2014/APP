//
//  PhotoTableViewCell.h
//  Photo
//
//  Created by zhongyi on 16/1/2.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBorderTableViewCell.h"

@interface PhotoTableViewCell : BaseBorderTableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *albumPhoto;
@property (strong, nonatomic) IBOutlet UILabel *albumName;
@property (strong, nonatomic) IBOutlet UILabel *photoCount;

@end
