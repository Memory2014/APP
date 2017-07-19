//
//  FileDataOperation.h
//  PhotoView
//
//  Created by zhongyi on 15/9/20.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDataOperation : NSObject

@property (nonatomic, strong) NSMutableArray *directoryArray;
@property (nonatomic, strong) NSMutableArray *photoURLArray;
@property (nonatomic, strong) NSMutableArray *videoURLArray;
@property (nonatomic, strong) NSMutableArray *directoryVideoArray;
@property (nonatomic, assign) NSInteger numberOfFileInLibrary;


- (NSString *)dirDoc;
- (NSString *)dirVideoDirectory;

//library
-(NSString *)dirLib;

- (void)listDirectory;
- (void)deleteDirectory: (NSURL *)directoryURL;
- (void)deleteFileFromURL: (NSURL *)url;
- (void)listFileInDirectory: (NSURL *)url;
- (BOOL)createDirectory: (NSString *)dirName;


- (void)listAllVideoDirectory;
- (void)listAllFileInVideoDirectory:(NSURL *)url;
- (BOOL)createVideoDirectory: (NSString *)dirName;


- (void)listAllFileInPhotoDirectory;
- (NSInteger)listAllFileInVideoFile;

-(BOOL)createPrivateDirectory;


@end
