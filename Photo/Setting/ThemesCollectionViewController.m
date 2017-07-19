//
//  ThemesCollectionViewController.m
//  PhotoPRO
//
//  Created by zhong on 7/26/16.
//  Copyright © 2016 zhongyi. All rights reserved.
//

#import "ThemesCollectionViewController.h"
#import "ThemesCollectionViewCell.h"
#import "ColorArray.h"

@interface ThemesCollectionViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,copy) ColorArray *colorArray;
@property (nonatomic, strong)NSMutableArray *selectedSkillList;

@end

@implementation ThemesCollectionViewController

static NSString * const reuseIdentifier = @"ThemesCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    
    self.collectionView.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    self.collectionView.allowsMultipleSelection = NO;
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SkillCollectionheaderIdentifier"];//注册header的view
    
    
    _colorArray = [ColorArray initWithColor];
    
    
    if (self.selectedSkillList == nil) {
        self.selectedSkillList = [[NSMutableArray alloc] init];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doSaveColor)];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ThemesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = _colorArray[indexPath.item];

    // Configure the cell
    return cell;
}


#pragma mark <UICollectionViewDelegate>

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 80);
}

//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(25, 25, 20, 25);//分别为上、左、下、右
}

//返回头headerView的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={ 0,0};
    return size;
}
//返回头footerView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize size={0,0};
    return size;
}
//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}
//每个item之间的间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 100;
//}

//选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ThemesCollectionViewCell *cell = (ThemesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [cell cellUpdate:YES];
    [self.selectedSkillList addObject:indexPath];
}
//取消选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ThemesCollectionViewCell *cell = (ThemesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [cell cellUpdate:NO];
    [self.selectedSkillList removeObject:indexPath];
}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.selectedSkillList.count >= 1) {
//        //[self.collectionView ]
//        return NO;
//    }else{
//        return YES;
//    }
//}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


- (void)doSaveColor{
    
    if (self.collectionView.indexPathsForSelectedItems.count <= 0 ) {
        return;
    }
    
    NSInteger index  = self.collectionView.indexPathsForSelectedItems[0].row;
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"Themes"];
    
    self.navigationController.navigationBar.barTintColor = _colorArray[index];
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
