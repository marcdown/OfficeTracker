//
//  CMMasterViewController.m
//  Office Tracker
//
//  Created by Marc Brown on 2/8/14.
//  Copyright (c) 2014 Creative Mess, LLC. All rights reserved.
//

#import <ESTBeaconManager.h>
#import "CMMasterViewController.h"

#define BEACON_MAJOR 0 // Replace with beacon major id
#define BEACON_MINOR 0 // Replace with beacon minor id

typedef NS_ENUM(NSUInteger, CMEventType) {
    CMEventTypeEnter,
    CMEventTypeExit
};

@interface CMMasterViewController () <ESTBeaconManagerDelegate>

@property (strong, nonatomic) ESTBeaconManager* beaconManager;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation CMMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // craete manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    // create sample region with major value defined
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                       major:BEACON_MAJOR
                                                                       minor:BEACON_MINOR
                                                                  identifier: @"EstimoteSampleRegion"];
    
    // start looking for estimote beacons in region
    [self.beaconManager startMonitoringForRegion:region];
    [self.beaconManager requestStateForRegion:region];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)triggerEventWithType:(CMEventType)type
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:[NSDate date] forKey:@"date"];
    [newManagedObject setValue:@(type == CMEventTypeEnter) forKey:@"entry"];
    [context save:nil];
    
    // Present local notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = type == CMEventTypeEnter ? @"Enter" : @"Exit";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

# pragma mark - ESTBeaconManagerDelegate

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{
    [self triggerEventWithType:CMEventTypeEnter];
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region
{
    [self triggerEventWithType:CMEventTypeExit];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
	[self.fetchedResultsController performFetch:nil];
    
    return _fetchedResultsController;
}    

 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *type = [[object valueForKey:@"entry"] boolValue] ? @"Enter" : @"Exit";
    NSDate *date = [object valueForKey:@"date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.locale = [NSLocale currentLocale];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", type, dateStr];
}

@end
