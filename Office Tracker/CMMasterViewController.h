//
//  CMMasterViewController.h
//  Office Tracker
//
//  Created by Marc Brown on 2/8/14.
//  Copyright (c) 2014 Creative Mess, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface CMMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
