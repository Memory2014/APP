//
//  HideVideoTableViewController.h
//  PhotoView
//
//  Created by zhongyi on 15/9/28.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALAssetsLibrary;

@interface HideVideoTableViewController : UITableViewController

@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;

//- (IBAction)onBurger:(id)sender;
//- (IBAction)onEdit:(id)sender;
//- (IBAction)onAdd:(id)sender;

@end
