//
//  BaseBorderTableViewCell.m
//  LZDConsult
//
//  Created by zhong on 6/22/16.
//  Copyright © 2016 zhongyi. All rights reserved.
//

#import "BaseBorderTableViewCell.h"

//#define WIDTH_VIEW self.contentView.frame.size.width
#define WIDTH_VIEW self.frame.size.width
#define HEIGHT_VIEW self.contentView.frame.size.height

@implementation BaseBorderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentBorderColor = [UIColor groupTableViewBackgroundColor];
    self.contentBackgroundColor = [UIColor whiteColor];
    self.contentMargin = 5.0;
    self.contentCornerRadius = CGSizeMake(5, 5);
    self.contentBorderWidth = 3.0;
    
    //self.frame
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    BaseBorderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[BaseBorderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    //一定要这里设置style，而不能在上面的判断里面，因为cell重用的时候，只要有不同的地方都应该重新设置，否则拿到cell的style就是上一个的样式而自己却没有进行修改
    if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.borderStyle = BaseCellBorderStyleAllRound;
    }else if (indexPath.row == 0) {
        cell.borderStyle = BaseCellBorderStyleTopRound;
    }else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.borderStyle = BaseCellBorderStyleBottomRound;
    }else {
        cell.borderStyle = BaseCellBorderStyleNoRound;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //配置默认值
        self.contentBorderColor = [UIColor orangeColor];
        self.contentBackgroundColor = [UIColor whiteColor];
        self.contentBorderWidth = 2.0;
        self.contentMargin = 10.0;
        self.contentCornerRadius = CGSizeMake(5, 5);
    }
    return self;
}

- (void)setBorderStyleWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        self.borderStyle = BaseCellBorderStyleAllRound;
    }else if (indexPath.row == 0) {
        self.borderStyle = BaseCellBorderStyleTopRound;
    }else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        self.borderStyle = BaseCellBorderStyleBottomRound;
    }else {
        self.borderStyle = BaseCellBorderStyleNoRound;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //在这里设置才能获取到真正显示时候的宽度，而不是原始的
    [self setupBorder];
}

- (void)setupBorder
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineWidth = self.contentBorderWidth;
    layer.strokeColor = self.contentBorderColor.CGColor;
    layer.fillColor =  self.contentBackgroundColor.CGColor;
    
//    layer.shadowColor = [UIColor orangeColor].CGColor;
//    layer.shadowOffset = CGSizeMake(1, 2);
//    layer.shadowOpacity = 1;
    
    //contentView.
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    [view.layer insertSublayer:layer atIndex:0];
    view.backgroundColor = [UIColor clearColor];
    //用自定义的view代替cell的backgroundView
    self.backgroundView = view;
    
    CGRect rect = CGRectMake(self.contentMargin, 0, WIDTH_VIEW - 2*self.contentMargin, HEIGHT_VIEW );
    switch (self.borderStyle) {
        case BaseCellBorderStyleNoRound:
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
            layer.path = path.CGPath;
        }
            break;
        case BaseCellBorderStyleTopRound:
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:self.contentCornerRadius];
            layer.path = path.CGPath;
        }
            break;
        case BaseCellBorderStyleBottomRound:
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:self.contentCornerRadius];
            layer.path = path.CGPath;
        }
            break;
        case BaseCellBorderStyleAllRound:
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:self.contentCornerRadius];
            layer.path = path.CGPath;
        }
            break;
        default:
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:self.contentCornerRadius];
            layer.path = path.CGPath;
        }
            break;
    }
}

@end
