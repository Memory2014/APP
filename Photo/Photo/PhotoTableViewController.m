//
//  PhotoTableViewController.m
//  Photo
//
//  Created by zhongyi on 16/1/1.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "PhotoGridViewControl.h"
#import "PhotoTableViewCell.h"
#import "TGCameraViewController.h"  //camera
#import "TGCameraColor.h"
#import "UINavigationBar+Awesome.h"
#import "PhotoX-Swift.h"
#import "AppDelegate.h"
#import "CNPGridMenu.h"
#import "ThemesCollectionViewController.h"
#import "WebViewController.h"
//#import <SafariServices/SafariServices.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "MovieViewController.h"
#import "TORootViewController.h"
#import "Utill.h"

@import Photos;
@import MessageUI;

@interface PhotoTableViewController() <PHPhotoLibraryChangeObserver,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate,TGCameraDelegate,CNPGridMenuDelegate>{
    NSString *password;
    UIImageView *navBarHairlineImageView;
}

@property (nonatomic,strong) NSArray *collectionsFetchResults;
@property (nonatomic,strong) NSArray *collectionsLocalizedTitles;
@property (nonatomic,strong) NSMutableArray *collectionNormal;
@property (nonatomic,strong) NSMutableArray *collectionUserCreat;
@property (nonatomic,strong) NSMutableArray *cellImage;      //smart cell
@property (nonatomic,strong) NSMutableArray *cellCount;      //smart cell
@property (nonatomic,strong) NSMutableArray *cellImageNew;   //New cell
@property (nonatomic,strong) NSMutableArray *cellCountNew;   //New cell
@property (nonatomic,strong) UIImage *cellAll;   //New cell

@property PHFetchResult *assetsFetchResults;
@property (strong) PHCachingImageManager  *imageManager;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic,strong) CNPGridMenu *gridMenu;


@end


@implementation PhotoTableViewController

static NSString * const AllPhotosReuseIdentifier = @"AllPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";
static NSString * const NewCellReuseIdentifier = @"NewCell";
static NSString * const AllPhotosSegue = @"showAllPhotos";
static NSString * const CollectionSegue = @"showCollection";
static NSString * const NewSegue = @"showNew";

@dynamic gridMenu;
//@dynamic longPressGestureRecognizer;


static CGSize AssetCellSize;

#pragma mark -- Inits

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    navBarHairlineImageView.hidden = YES;

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([self isFirstInstall]) {
        [self presentAnnotation];
        
        // defaults set
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SWITH_BUTTON];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:TOUCH_BUTTON];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    navBarHairlineImageView.hidden = NO;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [self viewInit];
}

- (void)viewInit{
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self checkAuthorization];
       
    //self.navigationItem.title = NSLocalizedString(@"Albums", nil);
    
    //password
    password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordDidChange) name:@"photo_password_change" object:nil];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newBackButton;
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handLongPressGesture)];
    self.longPressGestureRecognizer.allowableMovement = 100.0f;
    self.longPressGestureRecognizer.minimumPressDuration = 1.0;

    UILabel *titleLabel = [[UILabel alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width - 100, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"Albums", nil);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.userInteractionEnabled = YES;
    [titleLabel addGestureRecognizer:self.longPressGestureRecognizer];
    self.navigationItem.titleView = titleLabel;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self UpdateAsset];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * .5;
    AssetCellSize = CGSizeMake(imageSize * scale, imageSize * scale);
    
    [self updateImageForTableCell];
}

- (void)dealloc{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _cellCount = nil;
    _cellImage = nil;
    _cellImageNew = nil;
    _cellCountNew = nil;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

#pragma mark -- Asset

- (void)checkAuthorization{
    
    // Check library permissions
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized) {
                //[self performLoadAssets];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INFORMATION", nil)  message:@"APP requesting access to the photo, please go to settings  -> Privacy -> Photos  set this" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
        }];
    }
}

- (void)UpdateAsset{
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    self.collectionNormal = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < smartAlbums.count; i++) {
        PHAssetCollection *collection = smartAlbums[i];
        PHFetchResult *result = [PHAsset fetchKeyAssetsInAssetCollection:collection options:options];
        if (result.count > 0) {
            [self.collectionNormal addObject:collection];
        }
    }
    
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    self.collectionsFetchResults = @[smartAlbums, topLevelUserCollections];
    self.collectionsLocalizedTitles = @[NSLocalizedString(@"Smart Albums", @""), NSLocalizedString(@"New Albums", @"")];
    _assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    [self excludeEmptyCollections];
}

- (void)updateImageForTableCell{
    
    //store image/number for cell
    _cellCount = [[NSMutableArray alloc]init];
    _cellImage = [[NSMutableArray alloc]init];
    _cellImageNew = [[NSMutableArray alloc]init];
    _cellCountNew = [[NSMutableArray alloc] init];

    PHFetchResult *assetsFetchResult;
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
    if (assetsFetchResult.count > 0) {
        PHAsset *asset = assetsFetchResult[assetsFetchResult.count - 1];
        //PHImageManager *imageManager = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = true;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        };
        
        [self.imageManager requestImageForAsset:asset targetSize:AssetCellSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            self.cellAll = result;
        }];
    }
    
    for (NSInteger i = 0; i < self.collectionNormal.count; ++i)
    {
        [_cellImage addObject:[NSNull null]];
        [_cellCount addObject:[NSNull null]];
    }
    
    //PHFetchResult *assetsFetchResult;
    NSString *count = @"0";
    __block UIImage *image = [UIImage imageNamed:@"cell.png"];
    
    for (int i = 0; i < self.collectionNormal.count; i ++) {
        
        image = [_cellImage objectAtIndex:i];
        count = [_cellCount objectAtIndex:i];
        
        if ((NSNull *)image == [NSNull null]) {
            
            assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)self.collectionNormal[i] options:nil];
            
            if (assetsFetchResult.count > 0) {
                NSInteger _countNumber = assetsFetchResult.count;
                count = [NSString stringWithFormat:@"%@",@(_countNumber).stringValue];
                
                PHAsset *asset = assetsFetchResult[assetsFetchResult.count - 1];
                PHImageRequestOptions *options = [PHImageRequestOptions new];
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.synchronous = true;
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                };
                
                [self.imageManager requestImageForAsset:asset targetSize:AssetCellSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                    image= result;
                }];
            }
            
            [_cellCount replaceObjectAtIndex:i withObject:count];
            [_cellImage replaceObjectAtIndex:i withObject:image];
        }
    }
    
    //PHFetchResult *fetchResult = self.collectionsFetchResults.lastObject;
    
    for (NSInteger i = 0; i < self.collectionUserCreat.count; ++i)
    {
        [_cellImageNew addObject:[NSNull null]];
        [_cellCountNew addObject:[NSNull null]];
    }
    
    for (int i = 0; i < self.collectionUserCreat.count ; i ++) {

        image = [_cellImageNew objectAtIndex:i];
        count = [_cellCountNew objectAtIndex:i];
        
        if ((NSNull *)image == [NSNull null]) {
            
            assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)self.collectionUserCreat[i] options:nil];
            
            if (assetsFetchResult.count > 0) {
                NSInteger _countNumber = assetsFetchResult.count;
                count = [NSString stringWithFormat:@"%@",@(_countNumber).stringValue];
                
                PHAsset *asset = assetsFetchResult[assetsFetchResult.count - 1];
                //PHImageManager *imageManager = [PHImageManager defaultManager];
                PHImageRequestOptions *options = [PHImageRequestOptions new];
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.synchronous = true;
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                };

                [self.imageManager requestImageForAsset:asset targetSize:AssetCellSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                    image= result;
                }];
                
                [_cellCountNew replaceObjectAtIndex:i withObject:count];
                [_cellImageNew replaceObjectAtIndex:i withObject:image];
            }else{
                image = [UIImage imageNamed:@"cell.png"];
                count = @"0";
            }
        }
    }

}

- (void)excludeEmptyCollections {

    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    [options setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(localizedTitle)) ascending:YES]]];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:options];
    
    //NSMutableArray *collectionsArray = [NSMutableArray array];
    NSMutableArray *filteredCollections = [NSMutableArray array];
    [topLevelUserCollections enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL *stop) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        [options setPredicate:[NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage]];
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            if ([self hasImageTypeAssetInCollection:(PHAssetCollection *)obj]) {
                [filteredCollections addObject:obj];
            }
        } else if ([obj isKindOfClass:[PHCollectionList class]]) {
            NSMutableArray *array = [self doExtractAssetCollectionsFrom:(PHCollectionList *)obj];
            [filteredCollections addObjectsFromArray: array];
        }
    }];
    //[collectionsArray addObject:filteredCollections];
    self.collectionUserCreat = filteredCollections;
}

- (NSMutableArray *)doExtractAssetCollectionsFrom: (PHCollectionList *) collectionList {
    NSMutableArray *filteredCollections = [NSMutableArray array];
    
    PHFetchOptions *collectionOptions = [[PHFetchOptions alloc] init];
    [collectionOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(localizedTitle)) ascending:YES]]];
    PHFetchResult *result = [PHCollection fetchCollectionsInCollectionList:collectionList options:collectionOptions];
    
    [result enumerateObjectsUsingBlock:^(PHCollection *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            if ([self hasImageTypeAssetInCollection:(PHAssetCollection *)obj]) {
                [filteredCollections addObject:obj];
            }
        } else if ([obj isKindOfClass:[PHCollectionList class]]) {
            NSMutableArray *array = [self doExtractAssetCollectionsFrom:(PHCollectionList *)obj];
            [filteredCollections addObjectsFromArray:array];
        }
    }];
    
    return filteredCollections;
}

- (BOOL)hasImageTypeAssetInCollection: (PHAssetCollection *)collection {
    PHFetchOptions *assetOptions = [[PHFetchOptions alloc] init];
    [assetOptions setPredicate:[NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage]];
    PHFetchResult *countResult = [PHAsset fetchAssetsInAssetCollection:collection options:assetOptions];
    
    return countResult.count > 0;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
            [self UpdateAsset];
            [self resetCachedAssets];
            [self.tableView reloadData];
            [self updateImageForTableCell];
        }
        
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
        if (collectionChanges) {
            [self UpdateAsset];
            [self resetCachedAssets];
            [self.tableView reloadData];
            [self updateImageForTableCell];
        }
        
    });
}

#pragma mark - Asset Caching

- (void)resetCachedAssets{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                [self UpdateAsset];
            } else {
                [self.imageManager stopCachingImagesForAllAssets];
                //self.previousPreheatRect = CGRectZero;
            }
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - UIViewController Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:AllPhotosSegue]) {
        PhotoGridViewControl *assetGridViewController = segue.destinationViewController;
        // Fetch all assets, sorted by date created.
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        assetGridViewController.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
        
    } else if ([segue.identifier isEqualToString:CollectionSegue]) {
        PhotoGridViewControl *assetGridViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if (indexPath.section  == 1) {
            
            PHCollection *collection = self.collectionNormal[indexPath.row];
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
                assetGridViewController.assetsFetchResults = assetsFetchResult;
                assetGridViewController.assetCollection = assetCollection;
            }
        }else{
            //PHFetchResult *fetchResult = self.collectionsFetchResults[indexPath.section - 1];
            //PHFetchResult *fetchResult = self.collectionUserCreat[indexPath.row];
            //NSLog(@"%ld%ld", (long)indexPath.row, (long)indexPath.section);
            PHCollection *collection = self.collectionUserCreat[indexPath.row];;
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                assetGridViewController.assetsFetchResults = assetsFetchResult;
                assetGridViewController.assetCollection = assetCollection;
            }
        }
    }
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.collectionNormal.count == 0) {
        [self showNotAllowed];
        self.tableView.backgroundView.hidden = NO;
        return 0;
    }else{
        self.tableView.backgroundView.hidden = YES;
        return 1 + self.collectionsFetchResults.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger numberOfRows = 0;
    
    if (section == 0) {
        numberOfRows = 1;        // "All Photos" section
    }else
        if (section == 1) {      // 指定第2个为智能
        numberOfRows = self.collectionNormal.count;
    }else{
        numberOfRows = self.collectionUserCreat.count;
        if (numberOfRows == 0) {
            [self checkAuthorization];
        }
    }
    
    //NSLog(@"number of row %ld  %ld", (long)numberOfRows,(long)section);
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotoTableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:AllPhotosReuseIdentifier forIndexPath:indexPath];
        
        if (!cell) {
            cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AllPhotosReuseIdentifier];
        }
    //}else if(indexPath.section == 1){
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
        
        if (!cell) {
            cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionCellReuseIdentifier];
        }
    }
    
    NSDictionary *dic = [self getDictionaryForCell:indexPath];
    cell.albumName.text = dic[@"local"];
    cell.albumPhoto.image = dic[@"image"];
    cell.photoCount.text = dic[@"count"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = nil;
    if (section > 0) {
        title = self.collectionsLocalizedTitles[section - 1];
    }
    return title;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(13, 0, 200, 13);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"PingFangHK-Light" size:13];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }else{
        return 20;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section != 2) {
        return NO;
    }else
        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAssetCollection *collection;
            //PHFetchResult *fetchResult = self.collectionsFetchResults.lastObject;
            collection = self.collectionUserCreat[indexPath.row];
            [PHAssetCollectionChangeRequest deleteAssetCollections:@[collection]];
            //[PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                //NSLog(@"Error creating album: %@", error.localizedDescription);
             //[tableView deleteRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
        // Delete the row from the data sourc
        //[self UpdateAsset];
       
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    [self.tableView reloadData];
}

- (NSDictionary *)getDictionaryForCell:(NSIndexPath *)indexPath{
    NSString *count = @"0";
    NSString *localizedTitle;
    PHCollection *collection;
    PHFetchResult *assetsFetchResult;
    
    __block UIImage *image = [UIImage imageNamed:@"cell.png"];
    
    if (indexPath.section == 0) {
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
        if (assetsFetchResult.count > 0) {
            NSInteger _countNumber = assetsFetchResult.count;
            count = [NSString stringWithFormat:@"%@",@(_countNumber).stringValue];
            
            if (self.cellAll == nil) {
                PHAsset *asset = assetsFetchResult[assetsFetchResult.count - 1];
                //PHImageManager *imageManager = [PHImageManager defaultManager];
                PHImageRequestOptions *options = [PHImageRequestOptions new];
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.synchronous = true;
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                };
                
                [self.imageManager requestImageForAsset:asset targetSize:AssetCellSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                    image= result;
                }];
            }else{
                image = self.cellAll;
            }
        }
        localizedTitle = NSLocalizedString(@"All Photos",nil);
        
    } else
    if (indexPath.section  == 1 ) {
        collection = self.collectionNormal[indexPath.row];
        
        image = [_cellImage objectAtIndex:indexPath.row];
        count = [_cellCount objectAtIndex:indexPath.row];
        
        if ((NSNull *)image == [NSNull null]) {
            
            assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
            
            if (assetsFetchResult.count > 0) {
                NSInteger _countNumber = assetsFetchResult.count;
                count = [NSString stringWithFormat:@"%@",@(_countNumber).stringValue];
                
                PHAsset *asset = assetsFetchResult[assetsFetchResult.count - 1];
                //PHImageManager *imageManager = [PHImageManager defaultManager];
                PHImageRequestOptions *options = [PHImageRequestOptions new];
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.synchronous = true;
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                };
                
                [self.imageManager requestImageForAsset:asset targetSize:AssetCellSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                    image= result;
                }];
            }
            
            [_cellCount replaceObjectAtIndex:indexPath.row withObject:count];
            [_cellImage replaceObjectAtIndex:indexPath.row withObject:image];
        }
        localizedTitle = collection.localizedTitle;
        
    }else{
        //PHFetchResult *fetchResult = self.collectionsFetchResults.lastObject;
        //collection = fetchResult[indexPath.row];
        
        collection = self.collectionUserCreat[indexPath.row];
        
        image = [_cellImageNew objectAtIndex:indexPath.row];
        count = [_cellCountNew objectAtIndex:indexPath.row];
        
        if ((NSNull *)image == [NSNull null]) {
            
            assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
            
            if (assetsFetchResult.count > 0) {
                NSInteger _countNumber = assetsFetchResult.count;
                count = [NSString stringWithFormat:@"%@",@(_countNumber).stringValue];
                
                PHAsset *asset = assetsFetchResult[assetsFetchResult.count - 1];
                //PHImageManager *imageManager = [PHImageManager defaultManager];
                PHImageRequestOptions *options = [PHImageRequestOptions new];
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.synchronous = true;
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                };
                
                //PHImageRequestID _assetRequestID =
                [self.imageManager requestImageForAsset:asset targetSize:AssetCellSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                    image= result;
                }];
                
                [_cellCountNew replaceObjectAtIndex:indexPath.row withObject:count];
                [_cellImageNew replaceObjectAtIndex:indexPath.row withObject:image];
            }else{
                image = [UIImage imageNamed:@"cell.png"];
                count = @"0";
            }
        }
        localizedTitle = collection.localizedTitle;
    }
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:count, @"count" ,localizedTitle, @"local", image, @"image",nil];
    return info;
}

#pragma mark - Actions

- (IBAction)HandleAddButton:(id)sender {
    
    // Prompt user from new album title.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Album", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Album Name", @"");
        textField.font = ZY_FRONT;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        //UITextField *textField = alertController.textFields.firstObject;
        //textField.font = ZY_FRONT;
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        textField.tintColor = [UIColor grayColor];
        NSString *title = textField.text;
        
        
        if ([title isEqualToString:password]) {
            
            //[self performSegueWithIdentifier:@"hideTable" sender:self];
            
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
            UIViewController *homeControl = [mainStoryboard instantiateViewControllerWithIdentifier:@"HideNavigation"];
            homeControl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:homeControl animated:YES completion:^{}];

        }else{
            
            // Create new album.
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
            } completionHandler:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"Error creating album: %@", error);
                }
            }];
        }
    }]];
    
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)handLongPressGesture{

    NSString *touchOn = [[NSUserDefaults standardUserDefaults] stringForKey:TOUCH_BUTTON];
    if ([touchOn isEqualToString:@"1"]) {
            [self doTouchAuth];
    }
}


- (void)doTouchAuth
{
    LAContext *myContext = [[LAContext alloc] init];
    myContext.localizedFallbackTitle = @"输入密码";
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"需要验证指纹";
    
    __weak typeof(self) weakSelf = self;
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError])
    {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if(success)
                                {
                                    //处理验证通过
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
                                        UIViewController *homeControl = [mainStoryboard instantiateViewControllerWithIdentifier:@"HideNavigation"];
                                        homeControl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                                        [weakSelf presentViewController:homeControl animated:YES completion:^{}];
                                    });
                                }
                                else
                                {
                                }
                            }];
    }
    else
    {
        //不支持Touch ID验证，提示用户
        //self.TouchIDSwitch.enabled = false;
    }
}


#pragma mark -- Menu

- (IBAction)showMenu:(id)sender {
    [self showMenu];
}

- (void)showMenu{
    CNPGridMenuItem *theme = [[CNPGridMenuItem alloc] init];
    theme.icon = [UIImage imageNamed:@"Mclover"];
    theme.title = NSLocalizedString( @"Theme", comment: "");
    theme.menuItemTag = 10;
    
    CNPGridMenuItem *camera = [[CNPGridMenuItem alloc] init];
    camera.icon = [UIImage imageNamed:@"Mcamera"];
    camera.title = NSLocalizedString(@"Camera", comment: "");
    camera.menuItemTag = 11;
    
    CNPGridMenuItem *rating = [[CNPGridMenuItem alloc] init];
    rating.icon = [UIImage imageNamed:@"Mstar"];
    rating.title = NSLocalizedString(@"Rate our app", comment: "");
    rating.menuItemTag = 12;
    
    CNPGridMenuItem *support = [[CNPGridMenuItem alloc] init];
    support.icon = [UIImage imageNamed:@"Mcomment"];
    support.title = NSLocalizedString(@"Contact Support", comment: "");
    support.menuItemTag = 13;
    
    
    
    CNPGridMenuItem *video = [[CNPGridMenuItem alloc] init];
    video.icon = [UIImage imageNamed:@"movie"];
    video.title = NSLocalizedString(@"iTunes Movies ", comment: "");
    video.menuItemTag = 15;
    
    CNPGridMenuItem *pc = [[CNPGridMenuItem alloc] init];
    pc.icon = [UIImage imageNamed:@"Mpc"];
    pc.title = NSLocalizedString(@"Share", comment: "");
    pc.menuItemTag = 18;
    
    
    CNPGridMenuItem *upgrade;
    
#ifdef PHOTO_APP_NOMARL
    
    //升级
    upgrade = [[CNPGridMenuItem alloc] init];
    upgrade.icon = [UIImage imageNamed:@"Mupgrade"];
    upgrade.title = [NSString stringWithString:NSLocalizedString(@"Upgrade", nil)];
    upgrade.menuItemTag = 17;
    
#else
    
#endif
    
    CNPGridMenu *gridMenu;
    NSString *appVersion = [[NSUserDefaults standardUserDefaults] stringForKey:SWITH_BUTTON];
    if ([appVersion isEqualToString:@"1"]) {
        
        CNPGridMenuItem *guidance = [[CNPGridMenuItem alloc] init];
        guidance.icon = [UIImage imageNamed:@"click"];
        guidance.title = NSLocalizedString(@"Tutorial", comment: "");
        guidance.menuItemTag = 14;
        
        if (upgrade == nil) {
            gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[theme, camera, rating, support,video,pc, guidance]];
        }else{
            gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[theme, camera, rating, support,video,pc, upgrade, guidance]];
        }
        
    }else{
        
        if (upgrade == nil) {
            gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[theme, camera, rating, support,video,pc]];
        }else{
            gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[theme, camera, rating, support,video,pc,upgrade]];
        }
    }
    
    gridMenu.delegate = self;
    gridMenu.blurEffectStyle = CNPBlurEffectStyleDark;
    [self presentGridMenu:gridMenu animated:NO completion:^{
        //NSLog(@"Grid Menu Presented");
    }];
    
    
}

- (void)gridMenuDidTapOnBackground:(CNPGridMenu *)menu {
    [self dismissGridMenuAnimated:NO completion:^{
        //NSLog(@"Grid Menu Dismissed With Background Tap");
    }];
}

- (void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item {
    [self dismissGridMenuAnimated:NO completion:^{
        //NSLog(@"Grid Menu Did Tap On Item: %ld", (long)item.menuItemTag );

        switch (item.menuItemTag) {
            case 10:
            {
                UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main"bundle:nil];
                ThemesCollectionViewController *control = [board instantiateViewControllerWithIdentifier:@"ThemesCollectionViewController"];
                [self.navigationController pushViewController:control animated:YES];
            }
                break;
            case 11:
                [self openCamera];
                break;
            case 12:
                [self ratingApp];
                break;
            case 13:
                [self emailToApp];
                break;
            case 14:
                [self presentAnnotation];
                break;
            case 15:
                [self presentMovies];
                break;
            case 18:
                [self presentShareNet];
                break;
            case 17:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ITUNESLINK_BUY_APP]];
            }
                break;
            default:
                break;
        }
        
    }];
}

#pragma mark -- TOUR
- (void)presentAnnotation{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Annotation" bundle:nil];
    AnnotationViewController *annotation = [storyboard instantiateViewControllerWithIdentifier:@"Annotation"];
    annotation.alpha = 0.8;
    [self presentViewController:annotation animated:YES completion:nil];
}

- (void)presentMovies {
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Movie"bundle:nil];
    MovieViewController *control = [board instantiateViewControllerWithIdentifier:@"MovieViewController"];
    control.navigationItem.title = NSLocalizedString(@"iTunes Movies ", comment: "");
    [self.navigationController pushViewController:control animated:YES];
}

- (void)presentShareNet {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"SMB"bundle:nil];
    TORootViewController *control = [board instantiateViewControllerWithIdentifier:@"TORootViewController"];
    control.navigationItem.title = NSLocalizedString(@"Network Share", comment: "");
    [self.navigationController pushViewController:control animated:YES];
}


#pragma mark -- MISC

- (BOOL)isFirstInstall{
    BOOL appHasLaunchedOnce = false;
    NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
    NSString *currentAppVersion = infoDictionary[@"CFBundleShortVersionString"];
    NSString *appVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"appVersion"];
    
    if ( ![currentAppVersion isEqualToString:appVersion] || appVersion == nil ) {
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:@"appVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        appHasLaunchedOnce = true;
    }else{
        appHasLaunchedOnce = false;
    }
    return appHasLaunchedOnce;
}

- (void)showNotAllowed{
    //self.title              = nil;
    
    UIView *lockedView      = [[UIView alloc] initWithFrame:self.tableView.bounds];
    UIImageView *locked     = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_access"]];
    locked.contentMode      = UIViewContentModeCenter;
    
    CGRect rect             = CGRectInset(self.tableView.bounds, 8, 8);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    title.text              = NSLocalizedString(@"This app does not have access to your photos or videos.", nil);
    //title.font              = [UIFont boldSystemFontOfSize:17.0];
    title.textColor         = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedString(@"You can enable access in Privacy Settings.",nil);
    //message.font            = [UIFont systemFontOfSize:14.0];
    message.textColor       = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    
    
    title.font              = [UIFont fontWithName:@"PingFangHK-Medium" size:19];
    message.font            = [UIFont fontWithName:@"PingFangHK-Light" size:15];
    
    [title sizeToFit];
    [message sizeToFit];
    
    locked.center           = CGPointMake(lockedView.center.x, lockedView.center.y - locked.bounds.size.height /2 - 20);
    title.center            = locked.center;
    message.center          = locked.center;
    
    rect                    = title.frame;
    rect.origin.y           = locked.frame.origin.y + locked.frame.size.height + 10;
    title.frame             = rect;
    
    rect                    = message.frame;
    rect.origin.y           = title.frame.origin.y + title.frame.size.height + 5;
    message.frame           = rect;
    
    [lockedView addSubview:locked];
    [lockedView addSubview:title];
    [lockedView addSubview:message];
    self.tableView.backgroundView = lockedView;
}

- (void)passwordDidChange{
    password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
}

- (void)openCamera{
    
    [TGCameraColor setTintColor:ZY_WHITE];
    
    [TGCamera setOption:kTGCameraOptionSaveImageToAlbum value:[NSNumber numberWithBool:YES]];
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)ratingApp{
    NSString *iTunesLink = ITUNESLINK_PHOHO;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

- (void)emailToApp{

    NSURL *url;
    NSString *language = [self getPreferredLanguage];
    if ([language hasPrefix:@"zh"] ) {
        url = [[NSURL alloc] initWithString:@"http://photocn.sxl.cn"];
    }else{
        url = [[NSURL alloc] initWithString:@"http://photoen.sxl.cn"];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController  *webControl = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webControl.url = url;
    [self.navigationController pushViewController:webControl animated:NO];
}


- (NSString*)getPreferredLanguage {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    //NSLog(@"Preferred Language:%@", preferredLang);
    return preferredLang;
}

// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto{}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL{}

- (void)cameraDidSavePhotoWithError:(NSError *)error{}


@end
