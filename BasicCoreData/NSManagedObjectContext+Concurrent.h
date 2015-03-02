//
//  NSManagedObjectContext+Concurrent.h
//  BasicCoreData
//
//  Created by Boris Chirino on 26/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Concurrent)

- (void)performGroupedBlock:(dispatch_block_t)block;
- (dispatch_group_t)dispatchGroup;
- (dispatch_group_t)setupDispatchGroup;

@end
