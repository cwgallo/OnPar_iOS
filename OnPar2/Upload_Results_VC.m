//
//  Upload_Results_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Upload_Results_VC.h"
#import "MainViewController.h" // needed for deleteEverything

@interface Upload_Results ()

@end

@implementation Upload_Results
{
}

//@synthesize golfer1Label, golfer1Switch;
//@synthesize golfer2Label, golfer2Switch;
//@synthesize golfer3Label, golfer3Switch;
//@synthesize golfer4Label, golfer4Switch;
@synthesize navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"Upload will appear");
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"Upload did appear");
}

- (void)viewDidLayoutSubviews
{
    //NSLog(@"Upload did layout subviews");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadResults:(id)sender
{
    NSLog(@"Upload results");
    // send emails if any
    
    // create spinner
    
    // upload rounds from database
    // algorithm steps
    // 1. check to see if API is reachable
    // 2. obtain all rounds in the database
    // 3. loop through all rounds
    //      1. make a JSON representation of the round
    //      2. make the request
    
    // holes that have no information set, i.e., no shots, no score, no
    // FIR, no GIR, nothing
    // it will be skipped for the upload
    // This way if they forgot a hole, they can skip it, but it won't be uploaded
    // because that will just take extra room in the central DB
    
    // check for reachability
    Reachability *reach = [Reachability reachabilityWithHostname: HOSTNAME];
    
    if ([reach isReachableViaWiFi]) {
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        NSError *error;
        NSFetchRequest *roundFetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *round = [NSEntityDescription entityForName: @"Round"
                                                 inManagedObjectContext: [appDelegate managedObjectContext]];
        [roundFetch setEntity: round];
        NSArray *DBrounds = [[appDelegate managedObjectContext] executeFetchRequest: roundFetch error: &error];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        hud.labelText = @"Loading...";
        
        int __block numberOfRounds = DBrounds.count;
        int __block count = 1;
        
        // constructing the JSON
        for (Round *r in DBrounds) {
            
            // construct the JSON
            NSMutableArray *JSONholes = [[NSMutableArray alloc] init];
            
            int totalScore = 0;
            
            for (Hole *h in r.holes) {
                if (h.putts == nil && h.holeScore == nil && h.shots.count == 0) {
                    // the User did not do anything on this hole. Skip it
                    NSLog(@"Should skip this hole: %@", h.holeNumber);
                    continue;
                }
                
                NSMutableArray *JSONshots = [[NSMutableArray alloc] init];
                
                for (Shot *s in h.shots) {
                    NSMutableDictionary *shotLow = [[NSMutableDictionary alloc] init];
                    
                    [shotLow setObject: s.club ? s.club : [NSNull null] forKey: @"club"];
                    [shotLow setObject: s.shotNumber ? s.shotNumber : [NSNull null] forKey: @"shotNumber"];
                    [shotLow setObject: s.startLatitude ? s.startLatitude : [NSNull null] forKey: @"startLatitude"];
                    [shotLow setObject: s.startLongitude ? s.startLongitude : [NSNull null] forKey: @"startLongitude"];
                    [shotLow setObject: s.aimLatitude ? s.aimLatitude : [NSNull null] forKey: @"aimLatitude"];
                    [shotLow setObject: s.aimLongitude ? s.aimLongitude : [NSNull null] forKey: @"aimLongitude"];
                    [shotLow setObject: s.endLatitude ? s.endLatitude : [NSNull null] forKey: @"endLatitude"];
                    [shotLow setObject: s.endLongitude ? s.endLongitude : [NSNull null] forKey: @"endLongitude"];
                    
                    NSDictionary *shot = [[NSDictionary alloc] initWithObjectsAndKeys: shotLow, @"shot", nil];
                    
                    [JSONshots addObject: shot];
                }
                
                NSMutableDictionary *holeLow = [[NSMutableDictionary alloc] init];
                
                [holeLow setObject: h.holeNumber ? h.holeNumber : [NSNull null] forKey: @"holeNumber"];
                [holeLow setObject: h.holeScore ? h.holeScore : [NSNull null] forKey: @"holeScore"];
                [holeLow setObject: h.fairway_in_reg ? h.fairway_in_reg : [NSNull null] forKey: @"FIR"];
                [holeLow setObject: h.green_in_reg ? h.green_in_reg : [NSNull null] forKey: @"GIR"];
                [holeLow setObject: h.putts ? h.putts : [NSNull null] forKey: @"putts"];
                
                totalScore += [h.holeScore intValue];
                
                [holeLow setObject: JSONshots forKey: @"shots"];
                
                NSDictionary *hole = [[NSDictionary alloc] initWithObjectsAndKeys: holeLow, @"hole", nil];
                
                [JSONholes addObject: hole];
            }
            
            
            NSMutableDictionary *courseLow = [[NSMutableDictionary alloc] init];
            [courseLow setObject: r.courseID ? r.courseID : [NSNull null] forKey: @"id"];
            
            NSDictionary *course = [[NSDictionary alloc] initWithObjectsAndKeys: courseLow, @"course", nil];
            
            NSMutableDictionary *userLow = [[NSMutableDictionary alloc] init];
            [userLow setObject: r.userID ? r.userID : [NSNull null] forKey: @"id"];
            
            NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys: userLow, @"user", nil];
            
            NSMutableDictionary *round = [[NSMutableDictionary alloc] init];
            
            [round setObject: r.teeID ? r.teeID : [NSNull null] forKey: @"teeID"];
            [round setObject: [NSNumber numberWithInt: totalScore] ? [NSNumber numberWithInt: totalScore] : [NSNull null] forKey: @"totalScore"];
            [round setObject: r.startTime ? r.startTime : [NSNull null] forKey: @"startTime"];
            [round setObject: course forKey: @"course"];
            [round setObject: user forKey: @"user"];
            
            [round setObject: JSONholes forKey: @"holes"];
            
            NSDictionary *roundTop = [[NSDictionary alloc] initWithObjectsAndKeys: round, @"round", nil];
            
            NSLog(@"%@", [[SBJsonWriter alloc] stringWithObject: roundTop]);
            
            // construct the request
            [[LRResty authenticatedClientWithUsername: API_USERNAME
                                             password: API_PASSWORD
              ]
             post: [NSString stringWithFormat: @"%@%@", BASE_URL, @"rounds/"]
             payload: [[SBJsonWriter alloc] stringWithObject: roundTop]
             headers: [NSDictionary dictionaryWithObject: @"application/json"
                                                  forKey: @"Content-Type"
                       ]
             withBlock: ^(LRRestyResponse *r) {
                 if (r.status == 201) {
                     // good upload
                     // don't really need to do anything here I think
                 } else {
                     // uh oh
                     NSLog(@"%d", r.status);
                     AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong."];
                     [alert applyCustomAlertAppearance];
                     __weak AHAlertView *weakAlert = alert;
                     [alert addButtonWithTitle:@"OK" block:^{
                         weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                     }];
                     [alert show];
                 }
                 
                 if (count == numberOfRounds) {
                     // hide spinner and transition
                     [MBProgressHUD hideHUDForView: self.view animated: YES];
                     
                     // delete everything in the DB
                     id appDelegate = (id)[[UIApplication sharedApplication] delegate];
                     MainViewController *mvc = [[MainViewController alloc] init];
                     [mvc deleteEverything:appDelegate];
                     
                     // aler the user that it's done then delete everything and go to main page
                     AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Success" message:@"Your rounds have been uploaded successfully."];
                     [alert applyCustomAlertAppearance];
                     [alert addButtonWithTitle:@"OK" block:^{
                         // segue back to main
                         [[self navigationController] popToRootViewControllerAnimated: YES];
                     }];
                     [alert show];
                 } else {
                     count++;
                 }
             }
             ];
            
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

@end
