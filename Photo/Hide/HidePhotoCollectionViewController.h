//
//  HidePhotoCollectionViewController.h
//  Photo
//
//  Created by zhongyi on 16/1/5.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HidePhotoCollectionViewController : UICollectionViewController

@property (strong,nonatomic) NSMutableArray *urlMutalbeArray;
@property (strong,nonatomic) NSString *currentDirctory;
@property (strong,nonatomic) NSURL *currentURL;

@property (nonatomic) CGPoint initialContentOffset;
//@property (strong) PHAssetCollection *assetCollection;


@end
