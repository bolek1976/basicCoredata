//
//  BasicCoreDataTests.m
//  BasicCoreDataTests
//
//  Created by Boris Chirino on 14/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "ViewController.h"
#import "People.h"
#import "CoreDataDAL.h"

@interface BasicCoreDataTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectModel   *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation BasicCoreDataTests
{
    AppDelegate *_appdelegate;
    ViewController *_mainViewController;
}

- (void)setUp {
    [super setUp];
    _appdelegate = [UIApplication sharedApplication].delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainVC"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testMainViewControllerInstance{
    XCTAssertNotNil(_mainViewController);
}

- (void)testManagedContextCreation {
    self.managedObjectContext = _appdelegate.managedObjectContext;
    XCTAssertNotNil(self.managedObjectContext);
}

- (void)testManagedModelCreation {
    self.managedObjectModel = _appdelegate.managedObjectModel;
    XCTAssertNotNil(self.managedObjectModel);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testMeasureThis{
for (int i = 0; i<10000; i++) {

    [CoreDataDAL saveInbackgroundOnPrivateQueue:^(NSManagedObjectContext *localContext) {
        
        
            People *randomPeople = [NSEntityDescription insertNewObjectForEntityForName:@"People"                                                                       inManagedObjectContext:localContext];
            
            int index = arc4random_uniform(3);
            randomPeople.name = _appdelegate.peopleNameFeed[index];
            randomPeople.age  = @(50+index);
            randomPeople.lastname = _appdelegate.peopleLastNameFeed[index];
            randomPeople.department = _appdelegate.departmentNameFeed[index];
    } completion:^(BOOL finished) {
        if (finished)
            NSLog(@"Seems that context save perfect");
        else
            NSLog(@"Context fail when saving");
    }];

}
    //id <NSFetchedResultsSectionInfo> sectionInfo = [_mainViewController.fetchedResultController sections][0];
    
}

@end
