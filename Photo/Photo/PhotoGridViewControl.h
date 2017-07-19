//
//  PhotoGridViewControl.h
//  Photo
//
//  Created by zhongyi on 16/1/1.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

@import Photos;
@import UIKit;

@interface PhotoGridViewControl : UICollectionViewController

@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;


//@property (nonatomic) BOOL selectionMode;
@property (nonatomic) CGPoint initialContentOffset;
- (IBAction)handleEdit:(id)sender;
- (IBAction)handleMore:(id)sender;
- (void)adjustOffsetsAsRequired;

@end
