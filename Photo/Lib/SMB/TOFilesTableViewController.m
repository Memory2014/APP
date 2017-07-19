//
//  TOFilesViewControllerTableViewController.m
//  TOSMBClientExample
//
//  Created by Tim Oliver on 8/5/15.
//  Copyright (c) 2015 TimOliver. All rights reserved.
//

#import "TOFilesTableViewController.h"
#import "TOSMBClient.h"
#import "TORootViewController.h"
#import "Utill.h"
#import "PlayerViewController.h"
#import "MWPhotoBrowser.h"

@interface TOFilesTableViewController ()

@property (nonatomic, copy) NSString *directoryTitle;
@property (nonatomic, strong) TOSMBSession *session;
@property (nonatomic, strong) TOSMBSessionUploadTask *uploadTask;

@end

@implementation TOFilesTableViewController

- (instancetype)initWithSession:(TOSMBSession *)session title:(NSString *)title
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _directoryTitle = title;
        _session = session;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Loading...";
    
    if (self.path.length) {
        UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(upload:)];
        self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItems.firstObject, uploadButton];
    }
}

- (void)upload:(id)sender {
    self.navigationItem.rightBarButtonItems.lastObject.enabled = NO;
    NSString *path = [[self.path stringByAppendingPathComponent:[NSUUID UUID].UUIDString] stringByAppendingPathExtension:@"txt"];
    NSData *data = [path dataUsingEncoding:NSUTF8StringEncoding];
    
    __weak typeof(self) weakSelf = self;
    self.uploadTask = [self.session uploadTaskForFileAtPath:path data:data progressHandler:nil completionHandler:^{
        [weakSelf reloadData];
        weakSelf.navigationItem.rightBarButtonItems.lastObject.enabled = YES;
    } failHandler:^(NSError *error) {
        weakSelf.navigationItem.rightBarButtonItems.lastObject.enabled = YES;
    }];
    
    [self.uploadTask resume];
}

- (void)reloadData {
    __weak typeof(self) weakSelf = self;
    [self.session requestContentsOfDirectoryAtFilePath:self.path success:^(NSArray *files) {
        weakSelf.files = files;
        [weakSelf.tableView reloadData];
    } error:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SMB Client Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    TOSMBSessionFile *file = self.files[indexPath.row];
    cell.textLabel.text = file.name;
    cell.detailTextLabel.text = file.directory ? @"Directory" : [NSString stringWithFormat:@"File | Size: %ld MB", (long)file.fileSize/(1024*1024)];
    cell.accessoryType = file.directory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TOSMBSessionFile *file = self.files[indexPath.row];
    if (file.directory == NO) {
        
        [self handleMore];
        NSString* fileExtension = [file.filePath.pathExtension uppercaseString];
        if ( [fileExtension isEqualToString:@"MP4"]  || [fileExtension isEqualToString:@"MOV"])
        {
            NSDictionary *dic = [self dictionaryFromURL:[NSURL URLWithString:file.filePath]];
            PlayerViewController *player = [[PlayerViewController alloc] init];
            player.hidesBottomBarWhenPushed = YES;
            player.video = dic;
        }
        
        //[self.rootController downloadFileFromSession:self.session atFilePath:file.filePath];
        return;
    }
    
    TOFilesTableViewController *controller = [[TOFilesTableViewController alloc] initWithSession:self.session title:file.name];
    controller.rootController = self.rootController;
    controller.path = file.filePath;
    controller.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems;
    [self.navigationController pushViewController:controller animated:YES];
    
    [self.session requestContentsOfDirectoryAtFilePath:file.filePath success:^(NSArray *files) {
        controller.files = files;
    } error:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SMB Client Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }];
}

- (void)setFiles:(NSArray <TOSMBSessionFile *> *)files
{
    _files = files;
    self.navigationItem.title = self.directoryTitle;
    
    [self.tableView reloadData];
}

- (NSDictionary *)dictionaryFromURL:(NSURL *)videoURL {
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    CGFloat seconds = 0;
    seconds = urlAsset.duration.value/urlAsset.duration.timescale;
    NSInteger hour = seconds / 3600;
    NSInteger time = (NSInteger)seconds % 3600;
    NSInteger min  = (NSInteger)time / 60;
    NSInteger sec  = time % 60;
    NSString *videoTime =  [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
    
    NSString *str = [urlAsset.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *name = [str lastPathComponent];
    name = [name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *video = @{
                            @"title":name,
                            @"video":videoURL,
                            @"duration" : videoTime
                            };
    return video;
}

- (IBAction)handleMore {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    //alertController.popoverPresentationController.barButtonItem = self.tableView;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    // Add an action to dismiss the UIAlertController.
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //[self doCancel];
    }]];
    

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //[self doDelete];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"More", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //[self doMore];
    }]];
    
    // Present the UIAlertController.
    [self presentViewController:alertController animated:YES completion:NULL];
    //[self.collectionView cellForItemAtIndexPath:[self numberOfSectionsInCollectionView:self.collectionView]];
}
         
@end
