//
//  ViewController.m
//  BasicCoreData
//
//  Created by Boris Chirino on 14/02/15.
//  Copyright (c) 2015 Dev. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "People.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultController;
@end

@implementation ViewController{
    /*
    Apple say It’s best practice to use a property on an object any time you need to keep track of a value or another object.
    If you do need to define your own instance variables without declaring a property, you can add them inside braces at the top of the class interface or implementation
     */
    
    
    // this is not weird, its just a private instance variable aka .ivar, as i do not need a property for this
    // , the memory access will be pretty much faster than with a synthetized property. Its not a good pattern have your AppDelegate with tons of global variables but for this simple example its ok.
  __block  AppDelegate *_appDelegate;
    NSArray     *_peopleNameSeed;
    NSArray     *_peopleLastNameSeed;
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
     _appDelegate        = [UIApplication sharedApplication].delegate;
    _peopleNameSeed     = @[@"Mila", @"Jhon", @"Albert", @"Jhoseph"];
    _peopleLastNameSeed = @[@"Seed", @"Travolta", @"Einstein", @"Jojovich"];
    
    self.navigationController.edgesForExtendedLayout =  UIRectEdgeBottom;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSArray *sections = [self.fetchedResultController sections];
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultController sections][section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"exampleIdentifier"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [(People*)[self peopleWithIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]] department];
}

#pragma mark - instance methods

- (People*)peopleWithIndexPath:(NSIndexPath*)indexPath{
    People *peopleObject = [self.fetchedResultController objectAtIndexPath:indexPath];
    return peopleObject;
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    People *peopleObject  = [self peopleWithIndexPath:indexPath];
    cell.textLabel.text   = peopleObject.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Aged %@", [peopleObject.age stringValue]];
}
#pragma mark - UIActions


- (void)saveInbackgroundOnPrivateQueue:(void(^)(NSManagedObjectContext *localContext))block
                            completion:(void(^)(BOOL finished))finished
{
    __strong typeof(_appDelegate) strongSelf = _appDelegate;
    
    dispatch_queue_t backgroundQ = dispatch_queue_create("bcf.concurrentQ.test", DISPATCH_QUEUE_CONCURRENT);
  
    //our concurrent queue to save thousands of petabytes without blocking the ui
  dispatch_async(backgroundQ, ^{
      NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
      NSManagedObjectContext *mainContext = strongSelf.managedObjectContext;
        privateContext.parentContext = mainContext;
        
        [privateContext performBlockAndWait:^{
            if (block)
                block(privateContext);
        }];
        
        NSError *error;
        BOOL successSave = [privateContext save:&error];
      
      //return the save to the main queue
      dispatch_async(dispatch_get_main_queue(), ^{
          if (!successSave)
              finished(NO);
          else
              finished(YES);
      });
      
  });
    
}

- (IBAction)addEntryAction:(id)sender {
    //create a private context/
    
    //This is a private context, used for CRUD operations on objects without fire KVO notifications because does not operate on the main threat

    [self saveInbackgroundOnPrivateQueue:^(NSManagedObjectContext *localContext) {
        
        People *randomPeople = [NSEntityDescription insertNewObjectForEntityForName:@"People"                                                                       inManagedObjectContext:localContext];
        
        int index = arc4random_uniform(3);
        randomPeople.name = _peopleNameSeed[index];
        randomPeople.age  = @(50+index);
        randomPeople.lastname = _peopleLastNameSeed[index];
        randomPeople.department = @"Directors";

    } completion:^(BOOL finished) {
        if (finished)
            NSLog(@"Seems that context save perfect");
            else
            NSLog(@"Context fail when saving");
    }];
}

- (IBAction)removeEntryAction:(id)sender {
}


#pragma mark - properties

- (NSFetchedResultsController *)fetchedResultController{
    
    NSManagedObjectContext *localContext = _appDelegate.managedObjectContext;
    
    if (_fetchedResultController || !localContext) {
        return _fetchedResultController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:localContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    [fetchRequest setPredicate:nil];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // setting cache name
    NSString *cache = NSStringFromClass([self class]);

    //delete chache if exist
    [NSFetchedResultsController deleteCacheWithName:cache];
    
    //create a local fetched result controller
    
    /*
       Setter methods can have additional side-effects. They may trigger KVC notifications, 
     or perform further tasks if you write your own custom methods. As i'm writing my custom method for this property i'll initialize NSFetchedResultsController in a local scope, and assign it to my ivar, in that way there's should not be KVC propagation that affect
     my UI.
     */
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:localContext
                                                                            sectionNameKeyPath:@"department"
                                                                                     cacheName:cache];
    
    _fetchedResultController = frc;
    _fetchedResultController.delegate = self;
    NSError *error = nil;
    BOOL successFetch =  [_fetchedResultController performFetch:&error];
    if (!successFetch)
        NSLog(@"hmm something went wrong creating fetchedResultController");

    
    return _fetchedResultController;
}


#pragma mark - FetchedResutlControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    NSLog(@"%s  with type %lu",__PRETTY_FUNCTION__, type);
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSLog(@"%s  with type %lu",__PRETTY_FUNCTION__, type);
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
