//
//  HideVideoListCell.h
//  PhotoPRO
//
//  Created by zhong on 8/11/16.
//  Copyright © 2016 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBorderTableViewCell.h"

@interface HideVideoListCell : BaseBorderTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UILabel *videoName;
@property (weak, nonatomic) IBOutlet UILabel *videoTime;

@end
