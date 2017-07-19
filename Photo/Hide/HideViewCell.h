//
//  PhotoTableViewCell.h
//  PhotoView
//
//  Created by zhongyi on 15/9/21.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBorderTableViewCell.h"

@interface HideViewCell : BaseBorderTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *albumName;
@property (strong, nonatomic) IBOutlet UIImageView *albumPhoto;
@property (strong, nonatomic) IBOutlet UILabel *photoCount;



@end
