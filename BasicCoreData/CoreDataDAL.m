//
//  CoreDataDAL.m
//  BasicCoreData
//
//  Created by Boris Chirino on 23/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import "CoreDataDAL.h"
#import "AppDelegate.h"



@implementation CoreDataDAL

+ (void)saveInbackgroundOnPrivateQueue:(void(^)(NSManagedObjectContext *localContext))block
                            completion:(void(^)(BOOL finished))finished
{
    AppDelegate *_appdelegate = [UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSManagedObjectContext *mainContext = _appdelegate.managedObjectContext;
    localContext.parentContext = mainContext;
    
    //our concurrent queue to save thousands of petabytes without blocking the ui
    dispatch_async([self backGroundQ], ^{
        
        [localContext performBlockAndWait:^{
            if (block)
                block(localContext);
        }];
        
        NSError *error;
        BOOL successSave = [localContext save:&error];
        
        //return the save to the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!successSave)
                finished(NO);
            else
                finished(YES);
        });
        
    });
}


+ (dispatch_queue_t)backGroundQ {
    __block dispatch_queue_t _backgroundQ ;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _backgroundQ = dispatch_queue_create("bcf.concurrentQ.test", DISPATCH_QUEUE_CONCURRENT);;
    });
    return _backgroundQ;
}


@end
