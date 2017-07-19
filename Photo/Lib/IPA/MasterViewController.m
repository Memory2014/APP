//
//  MasterViewController.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>


#define TINTCOLOR_NAVIG  [UIColor colorWithRed:0.1765 green:0.7451 blue:0.3765 alpha:0.5]   //green
#define TINCOLOR_BAR [UIColor colorWithRed:1.0 green:0.5961 blue:0.2314 alpha:1.0]

#define TINCOLOR_AQUA  [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0]

@interface MasterViewController () {
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}
@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    
    self.title = NSLocalizedString(@"Purchase", nil);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(doDone)];
    
    UIBarButtonItem *refrashItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    
    UIBarButtonItem *resotre = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Restore", nil) style:UIBarButtonItemStylePlain target:self action:@selector(restoreTapped:)];
    
    NSMutableArray *items = [[NSMutableArray alloc]init];
    [items addObject:refrashItem];
    [items addObject:resotre];
    self.navigationItem.rightBarButtonItems = items;
    
}

- (void)doDone{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)restoreTapped:(id)sender {
    [[RageIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification) name:@"GO_HOME_APP" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

- (void)reload {
    _products = nil;
    [self.tableView reloadData];
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [self.tableView reloadData];
        }else{
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INFORMATION", nil)  message:NSLocalizedString(@"Can't Connect To APP Store, please try again later ", nil)  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)handleNotification{
}

#pragma mark - Table View
    
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 15, 120)];
    textLabel.text = NSLocalizedString(@"Thanks you for upgrading purchase. If you didn't get a response , maybe the network is something wrong. please try again later. If you had upgraded , please restore ", nil);
    textLabel.textColor = [UIColor lightGrayColor];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.numberOfLines = 4;
    textLabel.font = [UIFont systemFontOfSize:14];
    [headView addSubview:textLabel];
    headView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return headView;
}
    

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    SKProduct * product = (SKProduct *) _products[indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    //cell.detailTextLabel.text = product.localizedDescription;
    [_priceFormatter setLocale:product.priceLocale];
    //cell.detailTextLabel.text = [_priceFormatter stringFromNumber:product.price];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@",[_priceFormatter stringFromNumber:product.price],@" ",product.localizedDescription];
    
    if ([[RageIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:NSLocalizedString(@"Buy", nil) forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        buyButton.tintColor = [UIColor orangeColor];
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    
    return cell;
}

- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[RageIAPHelper sharedInstance] buyProduct:product];
}

@end
