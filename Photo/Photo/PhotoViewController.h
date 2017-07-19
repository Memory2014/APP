//
//  PhotoViewController.h
//  Photo
//
//  Created by zhongyi on 16/1/1.
//  Copyright © 2016年 zhongyi. All rights reserved.
//


@import UIKit;
@import Photos;

@interface PhotoViewController : UIViewController

@property (strong) PHAsset *asset;
@property (strong) PHAssetCollection *assetCollection;
@property (strong) PHFetchResult *assetsFetchResults;
//@property (strong) NSIndexPath *indexPath;
@property () NSInteger index;

@end
