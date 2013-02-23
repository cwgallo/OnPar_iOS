//
//  Golfer_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Golfer_VC.h"

@implementation GolferVC{
    NSMutableArray *golfers;
    MBProgressHUD *HUD;
}

@synthesize golferTableView;
@synthesize holeStepper;
@synthesize addButton;
@synthesize myView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self showNavBar];
    [self stepperInitialization];
    
    self.holeNumberLabel.text = [NSString stringWithFormat:@"%.f", holeStepper.value];
}

- (void)viewWillAppear:(BOOL)animated{
    
    // delay before showing navbar
    //[NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(showNavBar) userInfo:nil repeats:NO];
    //[self showNavBar];
    
    
    
    golfers = [[NSMutableArray alloc] init];
    
    // load golfers that are in database
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"User"
                                              inManagedObjectContext: [appDelegate managedObjectContext]];
    [fetchRequest setEntity: entity];
    NSArray *fetchedObjects = [[appDelegate managedObjectContext] executeFetchRequest: fetchRequest error: &error];
    for (User *u in fetchedObjects) {
        [golfers addObject: u];
    }
    
    [golferTableView reloadData];
    
    if (golfers.count == 0)
    {
        // disable start button
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        // enable start button
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    if (golfers.count == 4)
    {
        // hide add button
        addButton.hidden = YES;
    }
}

#pragma mark - TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [golfers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"golfer";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    User *u = [golfers objectAtIndex: indexPath.row];
    
    // if they have a nickname, display the username
    // else display the full name
    // for the details, display what tee they are using.
    
    if (u.nickname) {
        cell.textLabel.text = u.nickname;
    } else {
        cell.textLabel.text = u.name;
    }
    
    if (u.tee == [NSNumber numberWithInt: AGGIES]) {
        cell.detailTextLabel.text = @"Aggies";
    } else if (u.tee == [NSNumber numberWithInt: COWBELLS]) {
        cell.detailTextLabel.text = @"Cowbells";
    } else if (u.tee == [NSNumber numberWithInt: MAROONS]) {
        cell.detailTextLabel.text = @"Maroons";
    } else {
        cell.detailTextLabel.text = @"Bulldogs";
    }
    
    return cell;
}

#pragma  mark - Custom Header methods


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myHeaderView = [[UIView alloc] initWithFrame: CGRectMake(0.0f,-50.0f, tableView.contentSize.width,70.0f)];
    myHeaderView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.text = @"Golfers:";
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    label.backgroundColor = [UIColor clearColor];
    [myHeaderView addSubview:label];
    
    return myHeaderView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

#pragma mark - Custom Footer methods

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* myFooterView = [[UIView alloc] initWithFrame: CGRectMake(0.0f,-50.0f, tableView.contentSize.height,70.0f )];
    myFooterView.backgroundColor = [UIColor clearColor];
    [tableView addSubview:myFooterView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width-22, 18)];
    label.textAlignment = NSTextAlignmentCenter;
    
    // change footer text
    if (golfers.count == 0)
        label.text = @"Add Some Golfers!";
    else
        label.text = @"Maximum of 4";
        
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    label.backgroundColor = [UIColor clearColor];
    [myFooterView addSubview:label];
    
    return myFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0;
}

- (IBAction)startRound:(id)sender {
    
    // create round
    // 1. check for internet reachablility 
    // 1. loop through all the golfers
    // 2. start a round with the current time
    // 3. call API to get reference points for their selected tee
    
    // check for reachability
    Reachability *reach = [Reachability reachabilityWithHostname: HOSTNAME];
    
    if ([reach isReachable]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        hud.labelText = @"Loading...";
        
        int __block numberOfGolfers = golfers.count;
        int __block count = 1;
        
        for (User *u in golfers) {
            
            id appDelegate = (id)[[UIApplication sharedApplication] delegate];
            NSError *error;
            
            u.stageInfo.holeNumber = [NSNumber numberWithInt:[[NSNumber numberWithDouble: self.holeStepper.value] intValue]];
            
            if (![[appDelegate managedObjectContext] save: &error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            
            // call the API to obtain the reference points for the holes
            [[LRResty authenticatedClientWithUsername: API_USERNAME
                                             password: API_PASSWORD
              ]
             get: [NSString stringWithFormat: @"%@%@%@%@%@", BASE_URL, @"holes/reference/", @1, @"/", u.tee]
             parameters: nil
             headers: [NSDictionary dictionaryWithObject: @"application/json"
                                                  forKey: @"Content-Type"
                       ]
             withBlock: ^(LRRestyResponse *response) {
                 // 1. decode the JSON
                 // 2. create a hole and fill the reference points
                 // 3. point the hole to the round
                 // 4. save the round
                 
                 if (response.status == 200) {
                     
                     id appDelegate = (id)[[UIApplication sharedApplication] delegate];
                     NSError *error;
                     
                     SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                     NSDictionary *jsonObject = [jsonParser objectWithData: response.responseData];
                     NSArray *JSONholes = [jsonObject objectForKey: @"holes"];
                     
                     Round *r = [NSEntityDescription
                                 insertNewObjectForEntityForName: @"Round"
                                 inManagedObjectContext: [appDelegate managedObjectContext]];
                     
                     // the course ID can maybe change at a later time
                     r.courseID = @1;
                     r.userID = u.userID;
                     r.teeID = u.tee;
                     
                     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                     [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                     
                     NSString *dateString = [formatter stringFromDate: [NSDate date]];
                     
                     r.startTime  = dateString;
                     
                     for (NSDictionary *holeTop in JSONholes) {
                         
                         NSDictionary *hole = [holeTop objectForKey: @"hole"];
                         
                         Hole *h = [NSEntityDescription
                                    insertNewObjectForEntityForName: @"Hole"
                                    inManagedObjectContext: [appDelegate managedObjectContext]];
                         
                         h.holeNumber = [NSNumber numberWithInt: [[hole objectForKey: @"holeNumber"] intValue]];
                         h.par = [NSNumber numberWithInt: [[hole objectForKey: @"par"] intValue]];
                         h.distance = [NSNumber numberWithInt: [[hole objectForKey: @"distance"] intValue]];
                         h.firstRefLat = [NSNumber numberWithDouble: [[hole objectForKey: @"firstRefLat"] doubleValue]];
                         h.firstRefLong = [NSNumber numberWithDouble: [[hole objectForKey: @"firstRefLong"] doubleValue]];
                         h.secondRefLat = [NSNumber numberWithDouble: [[hole objectForKey: @"secondRefLat"] doubleValue]];
                         h.secondRefLong = [NSNumber numberWithDouble: [[hole objectForKey: @"secondRefLong"] doubleValue]];
                         h.firstRefX = [NSNumber numberWithInt: [[hole objectForKey: @"firstRefX"] intValue]];
                         h.firstRefY = [NSNumber numberWithInt: [[hole objectForKey: @"firstRefY"] intValue]];
                         h.secondRefX = [NSNumber numberWithInt: [[hole objectForKey: @"secondRefX"] intValue]];
                         h.secondRefY = [NSNumber numberWithInt: [[hole objectForKey: @"secondRefY"] intValue]];
                         
                         h.round = r;
                         [r addHolesObject: h];
                         
                     }
                     
                     // save the round to the DB
                     if (![[appDelegate managedObjectContext] save: &error]) {
                         NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                     }
                 } else {
                     
                     AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Error" message:@"API error."];
                     [alert applyCustomAlertAppearance];
                     __weak AHAlertView *weakAlert = alert;
                     [alert addButtonWithTitle:@"OK" block:^{
                         weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                     }];
                     [alert show];
                 }
                 
                 //NSLog(@"Count: %d", count);
                 //NSLog(@"numberOfGolers: %d", numberOfGolfers);
                 if (count == numberOfGolfers) {
                     // hide spinner and transition
                     [MBProgressHUD hideHUDForView: self.view animated: YES];
                     
                     // transition
                     [self performSegueWithIdentifier:@"settings2play" sender:self];
                 } else {
                     count++;
                 }
             }];
        }
    } else {
        // internet reachablility failed
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Connection Error" message:@"You must be connected to the Wi-Fi at the club house for this action."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
    }
}

- (IBAction)valueChanged:(id)sender {
    double stepperValue = holeStepper.value;
    self.holeNumberLabel.text = [NSString stringWithFormat:@"%.f", stepperValue];
}

- (void)showNavBar
{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)stepperInitialization
{
    // Hole Stepper Setup
    self.holeStepper.minimumValue = 1;
    self.holeStepper.maximumValue = 18;
    self.holeStepper.stepValue = 1;
    self.holeStepper.wraps = YES;
    self.holeStepper.autorepeat = YES;
    self.holeStepper.continuous = YES;
}

@end
