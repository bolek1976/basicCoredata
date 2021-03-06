//
//  AppDelegate.m
//  BasicCoreData
//
//  Created by Boris Chirino on 14/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import "AppDelegate.h"
#import "People.h"
#import <CoreData/CoreData.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Initialize new Data
    NSError *error = nil;
    NSArray *peoplesStored = [self.managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"People"] error:&error];
    //create dummydata only once
    if ([peoplesStored count] == 0)
        [self createDummyData];
    
    
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
    [self saveContext:self.managedObjectContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bcf.BasicCoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BasicCoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BasicCoreData.sqlite"];
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

- (BOOL)saveContext:(NSManagedObjectContext*)context
{
    NSError *error = nil;
    BOOL saveParent = NO;
    __block BOOL privateContextHaveChanges = NO;
    __block BOOL saveParentContext         = NO;
    
    //Check for changes
    
    // on this example we're using a private queue for creating objects so we should syncronously ask
    // to the context if there's any changes
    if (context.concurrencyType == NSPrivateQueueConcurrencyType) {
        [context performBlockAndWait:^{
            privateContextHaveChanges =  [context hasChanges];
        }];
    }else
        privateContextHaveChanges = [context hasChanges];
    
    
    //if occur any error during saving spill it out. Set error to nil for later reuse
    error != nil ? NSLog(@"Unresolved error %@, %@", error, [error userInfo]) : NSLog(@"save ok");
    error  = nil;
    
    //this example mainContext is always in main thread
    [context.parentContext performBlockAndWait:^{
        saveParentContext =  [context.parentContext hasChanges];
    }];
    
    //save if model has changes
    if (context != nil) {
        if (privateContextHaveChanges || saveParentContext) {
            [context save:&error];
            if (context.parentContext!=nil) [context.parentContext save:&error];
        }
    }

    
    error != nil ? NSLog(@"Unresolved error on parent context %@, %@", error, [error userInfo]) :
    ( saveParent ? NSLog(@"parent save ok") : NSLog(@"no object in parent context") );
    
    return error == nil ;
}

- (void)createDummyData{
    People *Alfred = [NSEntityDescription insertNewObjectForEntityForName:@"People"
                                                   inManagedObjectContext:self.managedObjectContext];
    Alfred.name = @"Alfred";
    Alfred.age = @80;
    Alfred.lastname = @"Hitchcock";
    Alfred.department = self.departmentNameFeed[0];

    
    People *Keanu = [NSEntityDescription insertNewObjectForEntityForName:@"People"
                                                  inManagedObjectContext:self.managedObjectContext];

    Keanu.name = @"Keanu";
    Keanu.age = @50;
    Keanu.lastname = @"Reeves";
    Keanu.department = self.departmentNameFeed[0];
    
    People *Lionel = [NSEntityDescription insertNewObjectForEntityForName:@"People"
                                                   inManagedObjectContext:self.managedObjectContext];
    
    Lionel.name = @"Lionel";
    Lionel.age = @70;
    Lionel.lastname = @"Richie";
    Lionel.department = self.departmentNameFeed[1];
    
    People *Sandra = [NSEntityDescription insertNewObjectForEntityForName:@"People"
                                                   inManagedObjectContext:self.managedObjectContext];
    Sandra.name = @"Sandra";
    Sandra.age = @50;
    Sandra.lastname = @"Bullock";
    Sandra.department =self.departmentNameFeed[2];;
    
    
    People *Jennifer = [NSEntityDescription insertNewObjectForEntityForName:@"People"
                                                     inManagedObjectContext:self.managedObjectContext];
    Jennifer.name = @"Jennifer";
    Jennifer.age = @46;
    Jennifer.lastname = @"Aniston";
    Jennifer.department = self.departmentNameFeed[2];;
    
    [self saveContext:self.managedObjectContext];
}

#pragma mark - properties
- (NSArray *)peopleLastNameFeed{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _peopleLastNameFeed = @[@"Seed", @"Travolta", @"Einstein", @"Jojovich"];
    });
    return _peopleLastNameFeed;
}

- (NSArray *)departmentNameFeed{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _departmentNameFeed = @[@"Directors", @"Singers", @"Actress"];
    });
    return _departmentNameFeed;
}

- (NSArray *)peopleNameFeed{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _peopleNameFeed  = @[@"Mila", @"Jhon", @"Albert", @"Jhoseph"];
    });
    
    return _peopleNameFeed;
}



@end
