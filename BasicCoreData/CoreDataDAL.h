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

+ (void)saveInbackgroundOnPrivateQueue:(void(^)(NSManagedObjectContext *localContext))block
                            completion:(void(^)(BOOL finished))finished;

@end
