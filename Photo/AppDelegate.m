//
//  AppDelegate.m
//  Photo
//
//  Created by zhongyi on 15/12/28.
//  Copyright © 2015年 zhongyi. All rights reserved.
//

#import "AppDelegate.h"
#import "Utill.h"
#import "ColorArray.h"
#import "RageIAPHelper.h"
//#import "IPA/RageIAPHelper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, ZY_FRONT_M , NSFontAttributeName,nil]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ZY_FRONT, NSFontAttributeName, ZY_WHITE, NSForegroundColorAttributeName,nil]  forState:UIControlStateNormal];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    UIImageRenderingMode renderingMode = UIImageRenderingModeAlwaysTemplate;
    UIImage *  image = [[UIImage imageNamed:@"backi"] imageWithRenderingMode:renderingMode];

    //[image resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width, 0, 0) resizingMode:UIImageResizingModeStretch];
    //[image resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width, 0, 0)];
    //[item setBackButtonTitlePositionAdjustment:UIOffsetMake(-400.f, 0) forBarMetrics:UIBarMetricsDefault];

//    [[UINavigationBar appearance] setBackIndicatorImage:image];
//    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:image];
//   
//
//    self.window.tintColor = ZY_RED;
    
    [[UINavigationBar appearance] setBackIndicatorImage:image];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:image];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //[[UINavigationBar appearance] setTranslucent:NO];
    
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Themes"];
    if ( index == 0 ) {
        [UINavigationBar appearance].barTintColor = ZY_GRAY_N;
    }else{
        ColorArray *color = [ColorArray initWithColor];
        [UINavigationBar appearance].barTintColor = color[index];
    }
    
    
    self.window.tintColor = ZY_GRAY;
    
    [RageIAPHelper sharedInstance];
    
    //Your View Controller Identifiers defined in Interface Builder
    NSString *firstViewControllerIdentifier = @"SettingControl";  // @"SettingControl";
    NSString *secondViewControllerIdentifier = @"HomeControl";
    
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
    BOOL _isSetPassword = true;
    if (password == nil) {
        _isSetPassword = false;
    }
    
//    BOOL appHasLaunchedOnce = false;
//    NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
//    NSString *currentAppVersion = infoDictionary[@"CFBundleShortVersionString"];
//    NSString *appVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"appVersion"];
//    
//    if ( ![currentAppVersion isEqualToString:appVersion] || appVersion == nil ) {
//        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:@"appVersion"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        appHasLaunchedOnce = true;
//    }else{
//        appHasLaunchedOnce = false;
//    }
    
    //check if the key exists and its value
    //BOOL appHasLaunchedOnce = [[NSUserDefaults standardUserDefaults] boolForKey:@"appHasLaunchedOnce"];
    
    //check which view controller identifier should be used
    NSString *viewControllerIdentifier = !_isSetPassword ? firstViewControllerIdentifier : secondViewControllerIdentifier;
    
    //IF THE STORYBOARD EXISTS IN YOUR INFO.PLIST FILE AND YOU USE A SINGLE STORYBOARD
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    
    //IF THE STORYBOARD DOESN'T EXIST IN YOUR INFO.PLIST FILE OR IF YOU USE MULTIPLE STORYBOARDS
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YOUR_STORYBOARD_FILE_NAME" bundle:nil];
    
    //instantiate the view controller
    UIViewController *presentedViewController = [storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
    
    //IF YOU DON'T USE A NAVIGATION CONTROLLER:
    //[self.window setRootViewController:presentedViewController];
    

  
    //IF your storyboard's entry point IS an UINavigationController replace:
    
    //IF YOU DON'T USE A NAVIGATION CONTROLLER:
    //[self.window setRootViewController:presentedViewController];

    //with:
    //IF YOU USE A NAVIGATION CONTROLLER AS THE ENTRY POINT IN YOUR STORYBOARD:
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    [navController pushViewController:presentedViewController animated:NO];
    
    //[navController presentViewController:presentedViewController animated:NO completion:nil];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ZH.Photo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Photo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Photo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
