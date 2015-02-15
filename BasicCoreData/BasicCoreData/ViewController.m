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

@interface ViewController ()<UITableViewDataSource, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultController;
@end

@implementation ViewController{
    AppDelegate *_appDelegate;
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = [UIApplication sharedApplication].delegate;
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
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    return cell;
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
    
    //create a local fetched resutlcontroller controller
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:localContext sectionNameKeyPath:@"department" cacheName:cache];
    
    _fetchedResultController = frc;
    _fetchedResultController.delegate = self;
    NSError *error = nil;
    BOOL successFetch =  [_fetchedResultController performFetch:&error];
    if (!successFetch)
        NSLog(@"hmm something went wrong creating fetchedResultController");

    
    return _fetchedResultController;
}

@end
