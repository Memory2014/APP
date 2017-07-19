//
//  HideVideoListController.h
//  PhotoPRO
//
//  Created by zhong on 8/11/16.
//  Copyright © 2016 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HideVideoListController : UITableViewController

@property (strong,nonatomic) NSMutableArray *urlMutalbeArray;
@property (strong,nonatomic) NSString *currentDirctory;
@property (strong,nonatomic) NSURL *currentURL;

@end
