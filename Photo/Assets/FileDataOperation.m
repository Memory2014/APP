//
//  FileDataOperation.m
//  PhotoView
//
//  Created by zhongyi on 15/9/20.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import "FileDataOperation.h"

@implementation FileDataOperation

@synthesize directoryArray;
@synthesize photoURLArray;
@synthesize videoURLArray;
@synthesize directoryVideoArray;
@synthesize numberOfFileInLibrary;


//应用程序沙盒根路径
- (void)dirHome{
    //NSString *dirHome = NSHomeDirectory();
}


//获取Documents目录  会同步
-(NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *imageDirectory = [documentsDirectory stringByAppendingPathComponent:@"/PHOTO"];
    //NSLog(@"app_home_lib: %@",imageDirectory);
    return imageDirectory;
}


//VIDEO  会同步
-(NSString *)dirVideoDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *imageDirectory = [documentsDirectory stringByAppendingPathComponent:@"/VIDEO"];
    //NSLog(@"app_home_lib: %@",imageDirectory);
    return imageDirectory;
}

//获取Library目录  不同步 不需要备份的数据
-(NSString *)dirLib{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *imageDirectory = [documentsDirectory stringByAppendingPathComponent:@"/PHOTO"];
    //NSLog(@"app_home_lib: %@",imageDirectory);
    return imageDirectory;
}


//获取Cache目录  不同步
-(void)dirCache{
    //NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //NSString *cachePath = [cacPath objectAtIndex:0];
    //NSLog(@"app_home_lib_cache: %@",cachePath);
}


//获取Tmp目录 不同步
-(void)dirTmp{
    //NSString *tmpDirectory = NSTemporaryDirectory();
    //NSLog(@"app_home_tmp: %@",tmpDirectory);
}


//Library/Preferences: iTunes同步该应用时会同步此文件夹中的内容，通常保存应用的设置信息
//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];


//创建文件夹
-(BOOL)createDirectory: (NSString *)dirName{
    NSString *documentsPath =[self dirLib];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imageDirectory = [documentsPath stringByAppendingPathComponent:dirName];
    
    // 创建目录
    BOOL res = false;
    if (![fileManager fileExistsAtPath:imageDirectory]) {
        res = [fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    };
    
    return res;
}



//创建文件夹
-(BOOL)createPrivateDirectory{
    NSString *documentsPath =[self dirLib];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 创建目录
    BOOL res = false;
    if (![fileManager fileExistsAtPath:documentsPath]) {
        res = [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    };
    
    
    documentsPath =[self dirVideoDirectory];
    if (![fileManager fileExistsAtPath:documentsPath]) {
        res = [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    };
    
    return res;
}


- (void)deleteDirectory: (NSURL *)directoryURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (! [fileManager removeItemAtURL:directoryURL error:&error]) {
        NSLog(@"[Error] %@ (%@)", error, directoryURL);
    }
}



//
//- (NSArray *)getPhotoFileList{
//    
//    //获取应用程序Documents文件夹里的文件及文件夹列表
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDir = [documentPaths objectAtIndex:0];
//    
//    documentDir = [NSString stringWithFormat:@"%@/%@",documentDir,@"1234"];
//    NSError *error = nil;
//    NSArray *fileList = [[NSArray alloc] init];
//    
//    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
//    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
//    
//    
//    NSMutableArray *dirArray = [[NSMutableArray alloc] init];
//    BOOL isDir = NO;
//    //在上面那段程序中获得的fileList中列出文件夹名
//    //NSFileManager *fileManager = [NSFileManager defaultManager];
//    for (NSString *file in fileList) {
//        NSString *path = [documentDir stringByAppendingPathComponent:file];
//        [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
//        if (isDir) {
//            [dirArray addObject:file];
//        }
//        isDir = NO;
//    }
//    NSLog(@"Every Thing in the dir:%@",fileList);
//    NSLog(@"All folders:%@",dirArray);
// 
//    return fileList;
//}

    //以下这段代码则可以列出给定一个文件夹里的所有子文件夹名

//- (NSMutableArray *)getPhotoInDir: (NSArray *)dir{
//
//    NSMutableArray *dirArray = [[NSMutableArray alloc] init];
//    BOOL isDir = NO;
//    //在上面那段程序中获得的fileList中列出文件夹名
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    for (NSString *file in dir) {
//        NSString *path = [documentDir stringByAppendingPathComponent:file];
//        [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
//        if (isDir) {
//            [dirArray addObject:file];
//        }
//        isDir = NO;
//    }
//    NSLog(@"Every Thing in the dir:%@",fileList);
//    NSLog(@"All folders:%@",dirArray);
//    
//    
//}




//
////创建文件
//-(void)createFile: (NSString *)fileName toDir:(NSString *)dirName{
//    NSString *documentsPath =[self dirDoc];
//    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:dirName];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *testPath = [testDirectory stringByAppendingPathComponent:fileName];
//    BOOL res=[fileManager createFileAtPath:testPath contents:nil attributes:nil];
//    if (res) {
//        NSLog(@"文件创建成功: %@" ,testPath);
//    }else
//        NSLog(@"文件创建失败");
//}
//
//
////写文件
//-(void)writeFile: (NSString *)fileName toDir:(NSString *)dirName{
//    NSString *documentsPath =[self dirDoc];
//    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:dirName];
//    NSString *testPath = [testDirectory stringByAppendingPathComponent:fileName];
//    NSString *content=@"测试写入内容！";
//    BOOL res=[content writeToFile:testPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    if (res) {
//        NSLog(@"文件写入成功");
//    }else
//        NSLog(@"文件写入失败");
//}


//文件属性
-(void)fileAttriutes{
    NSString *documentsPath =[self dirDoc];
    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testPath = [testDirectory stringByAppendingPathComponent:@"test.txt"];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:testPath error:nil];
    NSArray *keys;
    id key, value;
    keys = [fileAttributes allKeys];
    NSInteger count = [keys count];
    for (int i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        value = [fileAttributes objectForKey: key];
        NSLog (@"Key: %@ for value: %@", key, value);
    }
}


////删除文件
//-(void)deleteFile: (NSString *)fileName {
//    NSString *documentsPath =[self dirDoc];
//    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *testPath = [testDirectory stringByAppendingPathComponent:fileName];
//    BOOL res=[fileManager removeItemAtPath:testPath error:nil];
//    
//    //[fileManager removeItemAtURL:<#(nonnull NSURL *)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>]
//    if (res) {
//        NSLog(@"文件删除成功");
//    }else
//        NSLog(@"文件删除失败");
//    NSLog(@"文件是否存在: %@",[fileManager isExecutableFileAtPath:testPath]?@"YES":@"NO");
//}


- (void)deleteFileFromURL: (NSURL *)url{
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:url error:&error];
    if (error != NULL) {
        NSLog(@"%@",error);
    }
}

//列出文件里面的所有目录
- (void)listFileInDirectory: (NSURL *)url{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [self.photoURLArray removeAllObjects];
    
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             if (error) {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             return YES;
                                         }];
    
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        if (![isDirectory boolValue]) {
            [self.photoURLArray addObject:fileURL];
        }
    }
}

//在目录中递归地遍历文件
- (void)listDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *urlString = [self dirLib];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             if (error) {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             
                                             return YES;
                                         }];
    
    NSMutableArray *mutableFileURLs = [NSMutableArray array];
    NSMutableArray *directoryFile = [NSMutableArray array];
    
    self.directoryArray = directoryFile;
    self.photoURLArray = mutableFileURLs;
    
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        if ([isDirectory boolValue]) {
            [self.directoryArray addObject:fileURL];
        }
    }
    


    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

- (void)listAllFileInPhotoDirectory{
    
    //后台执行
    //dispatch_async(dispatch_get_main_queue() ,^{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *urlString = [self dirLib];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                              includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            errorHandler:^BOOL(NSURL *url, NSError *error)
                                             {
                                                 if (error) {
                                                     NSLog(@"[Error] %@ (%@)", error, url);
                                                     return NO;
                                                 }
                                                 return YES;
                                             }];
        
        NSInteger number = 0;
        
        for (NSURL *fileURL in enumerator) {
            NSString *filename;
            [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
            
            NSNumber *isDirectory;
            [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
            
            // Skip directories with '_' prefix, for example
            if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
                [enumerator skipDescendants];
                continue;
            }
            
            if (![isDirectory boolValue]) {
                number ++ ;
            }
        }
        self.numberOfFileInLibrary = number;
    //});
}


- (NSInteger)listAllFileInVideoFile{
    
    NSInteger num = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *urlString = [self dirVideoDirectory];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             if (error) {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             return YES;
                                         }];

    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        if (![isDirectory boolValue]) {
            num ++ ;
        }
        
//        if ([filename hasSuffix:@"mp4"]) {
//            num ++ ;
//        }
    }
    return num;
}

#pragma mark --- VIDEO

- (void)listAllVideoDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *urlString = [self dirVideoDirectory];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             if (error) {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             
                                             return YES;
                                         }];
    
    NSMutableArray *mutableFileURLs = [NSMutableArray array];
    NSMutableArray *directoryFile = [NSMutableArray array];
    
    self.directoryVideoArray = directoryFile;
    self.videoURLArray = mutableFileURLs;
    
    
    
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        if ([isDirectory boolValue]) {
            [self.directoryVideoArray addObject:fileURL];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

- (void)listAllFileInVideoDirectory: (NSURL *)url{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [self.videoURLArray removeAllObjects];
    
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             if (error) {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             return YES;
                                         }];
    
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        if (![isDirectory boolValue]) {
            [self.videoURLArray addObject:fileURL];
        }
    }
}

//创建文件夹
-(BOOL)createVideoDirectory: (NSString *)dirName{
    NSString *documentsPath =[self dirVideoDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imageDirectory = [documentsPath stringByAppendingPathComponent:dirName];
    
    // 创建目录
    BOOL res = false;
    if (![fileManager fileExistsAtPath:imageDirectory]) {
        res = [fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    };
    
    return res;
}



//Delegate


@end
