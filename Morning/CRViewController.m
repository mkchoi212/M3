//
//  CRViewController.m
//  Morning
//
//  Created by Mike Choi on 1/14/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "EventCell.h"
#import "EventGroup.h"
#import "CRViewController.h"
#import "NSDate+Utilities.h"
#import <EventKit/EventKit.h>

@interface CRViewController ()
@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) NSArray* calendars;
@property (nonatomic, strong) NSArray* eventGroups;
@end

@implementation CRViewController
#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eventStore = [[EKEventStore alloc] init];
    
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError* error)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            if (error != nil)
                            {
                                UIAlertView* alertView = [[UIAlertView alloc] init];
                                alertView.title = @"Error";
                                alertView.message = error.localizedDescription;
                                [alertView addButtonWithTitle:@"OK"];
                                [alertView show];
                                
                                return;
                            }
                            
                            if (!granted)
                            {
                                UIAlertView* alertView = [[UIAlertView alloc] init];
                                alertView.title = @"Calendars Permission Required";
                                alertView.message = @"Go to Settings > Privacy > Calendars and give Due Next access to your calendars.";
                                [alertView addButtonWithTitle:@"OK"];
                                [alertView show];
                                
                                return;
                            }
                            
                            [self loadCalendars];
                            [self refreshEvents];
                        });
     }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:self.eventStore];
}

#pragma mark - Actions

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return self.eventGroups.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    EventGroup* eventGroup = self.eventGroups[section];
    
    return eventGroup.events.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    EventGroup* eventGroup = self.eventGroups[indexPath.section];
    EKEvent* event = eventGroup.events[indexPath.row];
    
    EventCell* cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    cell.event = event;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    EventGroup* eventGroup = self.eventGroups[section];
    
    NSInteger distance = eventGroup.distance;
    NSString *temp;
    if (distance == 0)
        temp = @"TODAY";
    else if (distance == 1)
        temp = @"TOMORROW";
    else{
    temp = [[NSString stringWithFormat:@"In %ld days", (long)eventGroup.distance]uppercaseString ];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 18)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"Raleway" size:12]];
    label.text = temp;
    label.textColor = [UIColor darkGrayColor];
    [view addSubview:label];
    return view;
}



- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    EventGroup* eventGroup = self.eventGroups[indexPath.section];
    EKEvent* event = eventGroup.events[indexPath.row];
    
    if (!event.allDay)
        return 64.0f;
    
    return tableView.rowHeight;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    EventGroup* eventGroup = self.eventGroups[indexPath.section];
    EKEvent* event = eventGroup.events[indexPath.row];
    
    EKEventViewController* eventViewController = [[EKEventViewController alloc] init];
    eventViewController.delegate = self;
    eventViewController.event = event;
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:eventViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - EKCalendarChooserDelegate

- (void)calendarChooserDidCancel:(EKCalendarChooser*)calendarChooser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)calendarChooserDidFinish:(EKCalendarChooser*)calendarChooser
{
    self.calendars = [calendarChooser.selectedCalendars allObjects];
    
    [self saveCalendars];
    [self refreshEvents];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EKEventViewDelegate

-(void)eventViewController:(EKEventViewController*)controller didCompleteWithAction:(EKEventViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)eventStoreChanged:(NSNotification*)notification
{
    [self loadCalendars];
    [self refreshEvents];
}

#pragma mark -

- (void)loadCalendars
{
    NSArray* calendarIdentifiers = [[NSUserDefaults standardUserDefaults] objectForKey:@"Calendars"];
    NSMutableArray* calendars = [[NSMutableArray alloc] initWithCapacity:calendarIdentifiers.count];
    
    for (NSString* calendarIdentifier in calendarIdentifiers)
        [calendars addObject:[self.eventStore calendarWithIdentifier:calendarIdentifier]];
    
    if (calendars.count == 0)
        calendars = [[self.eventStore calendarsForEntityType:EKEntityTypeEvent] mutableCopy];
    
    self.calendars = calendars;
}

- (void)saveCalendars
{
    NSMutableArray* calendarIdentifiers = [[NSMutableArray alloc] initWithCapacity:self.calendars.count];;
    
    // Only save list of calendars if at least one calendar is deselected
    if (self.calendars.count != [self.eventStore calendarsForEntityType:EKEntityTypeEvent].count)
    {
        for (EKCalendar* calendar in self.calendars)
            [calendarIdentifiers addObject:calendar.calendarIdentifier];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:calendarIdentifiers forKey:@"Calendars"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)refreshEvents
{
    if (self.calendars.count != 0)
    {
        NSDate* startDate = [NSDate date];
        NSDate* endDate = [startDate dateByAddingYears:1];
        NSPredicate* predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:self.calendars];
        NSArray* events = [self.eventStore eventsMatchingPredicate:predicate];
        
        self.eventGroups = [EventGroup groupEvents:events sinceDate:startDate];
    }
    else
    {
        self.eventGroups = @[];
    }
    
    [self.tableView reloadData];
}

@end
