//
//  HideTableViewController.h
//  PhotoView
//
//  Created by zhongyi on 15/9/22.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ALAssetsLibrary;
//@class MWPhotoBrowser;

@interface HideTableViewController : UITableViewController;

@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) NSMutableArray *old_photos;
@property (nonatomic, strong) NSMutableArray *old_thumbs;

- (IBAction)onBurger:(id)sender;

//- (IBAction)onEdit:(id)sender;
//- (IBAction)onAdd:(id)sender;

@end
