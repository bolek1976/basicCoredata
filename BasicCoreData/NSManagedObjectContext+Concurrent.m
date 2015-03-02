//
//  NSManagedObjectContext+Concurrent.m
//  BasicCoreData
//
//  Created by Boris Chirino on 26/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import "NSManagedObjectContext+Concurrent.h"
#import <objc/runtime.h>

static void *dgroup = &dgroup;
static dispatch_group_t _staticDispatchGroup ;


@implementation NSManagedObjectContext (Concurrent)

- (void)performGroupedBlock:(dispatch_block_t)block;
{
    [self setupDispatchGroup];
    dispatch_group_enter(_staticDispatchGroup);
    [self performBlock:^{
        block();
        dispatch_group_leave(_staticDispatchGroup);
    }];
}

- (dispatch_group_t)dispatchGroup{
    return objc_getAssociatedObject(self, dgroup);
}


- (dispatch_group_t)setupDispatchGroup {
    if (!_staticDispatchGroup) {
        _staticDispatchGroup = dispatch_group_create();
        objc_setAssociatedObject(self, dgroup, _staticDispatchGroup, OBJC_ASSOCIATION_RETAIN);
    }

    return _staticDispatchGroup;
}

- (void)dealloc{
    //_staticDispatchGroup = nil;
}

@end
