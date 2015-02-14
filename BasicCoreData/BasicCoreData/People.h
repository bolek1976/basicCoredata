//
//  People.h
//  BasicCoreData
//
//  Created by Boris Chirino on 14/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface People : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * department;
@property (nonatomic, retain) NSString * lastname;

@end
