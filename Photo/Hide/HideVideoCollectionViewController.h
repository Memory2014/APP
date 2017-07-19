//
//  HideVideoCollectionViewController.h
//  Photo
//
//  Created by zhongyi on 16/1/10.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HideVideoCollectionViewController : UICollectionViewController

@property (strong,nonatomic) NSMutableArray *urlMutalbeArray;
@property (strong,nonatomic) NSString *currentDirctory;
@property (strong,nonatomic) NSURL *currentURL;

@property (nonatomic) CGPoint initialContentOffset;

@end
