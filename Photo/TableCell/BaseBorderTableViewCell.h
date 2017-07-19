//
//  BaseBorderTableViewCell.h
//  LZDConsult
//
//  Created by zhong on 6/22/16.
//  Copyright © 2016 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger,BaseCellBorderStyle) {
     BaseCellBorderStyleAllRound = 0,
    BaseCellBorderStyleTopRound,
    BaseCellBorderStyleBottomRound,
    BaseCellBorderStyleNoRound,
};



@interface BaseBorderTableViewCell : UITableViewCell

@property (nonatomic, assign) BaseCellBorderStyle borderStyle;     //边框类型
@property (nonatomic, strong) UIColor *contentBorderColor;         //边框颜色
@property (nonatomic, strong) UIColor *contentBackgroundColor;     //边框内部内容颜色
@property (nonatomic, assign) CGFloat contentBorderWidth;          //边框的宽度，这个宽度的一半会延伸到外部，如果对宽度比较敏感的要注意下
@property (nonatomic, assign) CGFloat contentMargin;               //左右距离父视图的边距
@property (nonatomic, assign) CGSize contentCornerRadius;          //边框的圆角


+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

- (void)setBorderStyleWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end


