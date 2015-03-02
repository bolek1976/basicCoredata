//
//  CoreDataDAL.m
//  BasicCoreData
//
//  Created by Boris Chirino on 23/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import "CoreDataDAL.h"
#import "AppDelegate.h"
#import "NSManagedObjectContext+Concurrent.h"

static dispatch_queue_t _backgroundQ ;


@implementation CoreDataDAL

+ (void)saveInbackgroundOnPrivateQueue:(void(^)(NSManagedObjectContext *localContext))block
                            completion:(void(^)(BOOL contextDidSave))completion
{
    AppDelegate *_appdelegate = [UIApplication sharedApplication].delegate;

    __block NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [localContext setupDispatchGroup];
    NSManagedObjectContext *mainContext = _appdelegate.managedObjectContext;
    
    // if we do not specify a parent context, inserting new entity will raise an exception because will be unable to find the entity in the localContext because is not asociated with any persitent store
    localContext.parentContext = mainContext;
    
    id commitBlock = ^{
        if (block)
            block(localContext);

        __block BOOL successSave  = [_appdelegate saveContext:localContext];
        localContext = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!successSave)
                completion(NO);
            else
                completion(YES);
        });
    };
    
    
    // this method is an extension to managedObjectContext to create groups with GDC
    [localContext performBlock:commitBlock];
}



+ (dispatch_queue_t)backGroundQ {
    if (!_backgroundQ) {
        _backgroundQ = dispatch_queue_create("bcf.concurrentQ.test", DISPATCH_QUEUE_CONCURRENT);;

    }
    return _backgroundQ;
}


@end
