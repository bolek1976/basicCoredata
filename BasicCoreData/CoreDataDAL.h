//
//  CoreDataDAL.h
//  BasicCoreData
//
//  Created by Boris Chirino on 23/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataDAL : NSObject
/**
 @description you can use a local NSManagedObjectContext to perform coredata operations the local context will be on a thread distint than mainthread, the context is distroyed once block is executed.
 @param block code to be executed
 @param completion once the block is executed completion is called returning YES for contextDidSave if data was persisted without problem
 
 
 **/
+ (void)saveInbackgroundOnPrivateQueue:(void(^)(NSManagedObjectContext *localContext))block
                            completion:(void(^)(BOOL contextDidSave))completion;



@end
