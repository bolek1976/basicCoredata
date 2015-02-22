//
//  AppDelegate.h
//  BasicCoreData
//
//  Created by Boris Chirino on 14/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//coreDataStack
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//data
@property (readwrite, strong, nonatomic) NSArray     *peopleNameFeed;
@property (readwrite, strong, nonatomic) NSArray     *peopleLastNameFeed;
@property (readwrite, strong, nonatomic) NSArray     *departmentNameFeed;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

