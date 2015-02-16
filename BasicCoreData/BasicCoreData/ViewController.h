//
//  ViewController.h
//  BasicCoreData
//
//  Created by Boris Chirino on 14/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

+ (void)saveInbackgroundOnPrivateQueue:(void(^)(NSManagedObjectContext *localContext))block
                            completion:(void(^)(BOOL finished))finished;
@end

