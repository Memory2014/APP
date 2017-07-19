//
//  ZYMenuTableViewController.m
//  Photo
//
//  Created by zhongyi on 16/4/2.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "ZYMenuTableViewController.h"
#import "ZYMenuTableViewCell.h"
#import "ColorArray.h"
#import "Utill.h"
#import "TGCameraViewController.h"
#import "TGCameraColor.h"

@import MessageUI;

@interface ZYMenuTableViewController()<MFMailComposeViewControllerDelegate,TGCameraDelegate>
@end

@implementation ZYMenuTableViewController{
    UIImageView *navBarHairlineImageView;
    NSArray *imageArray;
}


//- (CGSize)sizeThatFits:(CGSize)size{
//    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 50);
//}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = [self addHeaderView];
    
    [self initMenuImageArray];
}

- (UIView *)addHeaderView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.image = [UIImage imageNamed:@"Mphoto"];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 50.0;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 3.0f;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    imageView.layer.shouldRasterize = YES;
    imageView.clipsToBounds = YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
    label.text = @"PHOTO";
    label.font = [UIFont fontWithName:@"PingFangSC-Light" size:21];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    //label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    [label sizeToFit];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [view addSubview:imageView];
    [view addSubview:label];
    
    return view;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tableView.opaque = YES;
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    self.tableView.scrollsToTop = NO;
    
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Themes"];
    if ( index == 0 ) {
        self.tableView.backgroundColor = ZY_GRAY_N;
    }else{
        ColorArray *color = [ColorArray initWithColor];
        self.tableView.backgroundColor = color[index];
    }
    
    
    self.navigationController.navigationBar.translucent = NO;
    navBarHairlineImageView.hidden = YES;
    
    //[self.navigationController.navigationBar sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, 100)];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
    navBarHairlineImageView.hidden = NO;
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


- (void)initMenuImageArray{
    
    if (imageArray == nil) {
        imageArray = @[[UIImage imageNamed:@"Mhome"],
                       [UIImage imageNamed:@"Mclover"],
                       [UIImage imageNamed:@"Mcamera"],
                       [UIImage imageNamed:@"Mstar"],
                       [UIImage imageNamed:@"Mcomment"],
                       [UIImage imageNamed:@"Mhome"],
                       ];
    }
}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.imageView.bounds = CGRectMake(10, 5, 30, 30);
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //if (![self.showIndexes containsObject:indexPath]) {
    //    [self.showIndexes addObject:indexPath];
        cell.layer.transform = CATransform3DTranslate(cell.layer.transform, 300, 0, 0);
        cell.alpha = 0.5;
        [UIView animateWithDuration:1.5 delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.layer.transform = CATransform3DIdentity;
            cell.alpha = 1;
            } completion:nil];
    //  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = @"Friends Online";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 1:
                [self performSegueWithIdentifier:@"showTheme" sender:self];
                break;
            case 2:
                [self openCamera];
                break;
            case 3:
                [self ratingApp];
                break;
            case 4:
                [self emailToApp];
                break;
            case 5:
                [self performSegueWithIdentifier:@"showHelp" sender:self];
                break;
            default:
                break;
        }
        
    } else {

    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ZYMenuCell";
    
    ZYMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ZYMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        NSArray *titles = @[NSLocalizedString(@"Home", comment: ""),NSLocalizedString( @"Theme", comment: ""),NSLocalizedString(@"Camera", comment: ""),NSLocalizedString(@"Rate our app", comment: ""),NSLocalizedString(@"Contact Support", comment: ""),@"Tour"];
        cell.labelMenu.text = titles[indexPath.row];
        cell.imageMenu.image = imageArray[indexPath.row];
        
        //cell.textLabel.text = titles[indexPath.row];
        //cell.imageView.image = imageArray[indexPath.row];
    } else {
        NSArray *titles = @[@"John Appleseed", @"John Doe", @"Test User",@""];
        cell.textLabel.text = titles[indexPath.row];
    }
    
    return cell;
}


#pragma mark --MISC

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
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc]init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:@"Support"];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"zhyi@foxmail.com"]];
        [mailCont setMessageBody:@"" isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil  message:NSLocalizedString(@"Ｐlease go to Settings -> Mail add Account",nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL
{
    //NSLog(@"%s album path: %@", __PRETTY_FUNCTION__, assetURL);
}

- (void)cameraDidSavePhotoWithError:(NSError *)error
{
    //NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
}

@end
