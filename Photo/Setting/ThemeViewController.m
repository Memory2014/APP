//
//  ThemeViewController.m
//  Photo
//
//  Created by zhongyi on 16/3/27.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "ThemeViewController.h"
#import "ThemesTableViewCell.h"
#import "ColorArray.h"


@interface ThemeViewController()
@property (nonatomic,copy) ColorArray *colorArray;

@end

@implementation ThemeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _colorArray = [ColorArray initWithColor];
    
    //self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:nil];
}


#pragma mark -- delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _colorArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //ThemesTableViewCell *cell = nil;
    ThemesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThemesCell"];
    
    if (!cell) {
        cell = [[ThemesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThemesCell"];
    }
    
    cell.button.backgroundColor = _colorArray[indexPath.item];
    if (cell.isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.layer.transform = CATransform3DTranslate(cell.layer.transform, 300, 0, 0);
    cell.alpha = 0.5;
    [UIView animateWithDuration:1.2 delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.layer.transform = CATransform3DIdentity;
        cell.alpha = 1;
    } completion:nil];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ThemesTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    ThemesTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (IBAction)doSaveColor:(id)sender {
    
    NSInteger index  = [self.tableView indexPathForSelectedRow].item;
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"Themes"];
    
     self.navigationController.navigationBar.barTintColor = _colorArray[index];
    [self setNeedsStatusBarAppearanceUpdate];
}
@end
