//
//  RegistrationVC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Golfer_Registration_VC.h"
#import "Golfer_VC.h"

@interface Golfer_Registration_VC ()

@end

@implementation Golfer_Registration_VC{
    int tee;
    int hand;
    int gender;
}

@synthesize firstNameTextField, lastNameTextField;
@synthesize emailAddressTextField;
@synthesize membershipNumberTextField;
@synthesize nicknameTextField;
@synthesize handSegment,teeSegment, genderSegment;
@synthesize birthdateTextField;

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
    self.emailAddressTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    // see if there is an email to register
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    NSFetchRequest *systemInfoFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *si = [NSEntityDescription entityForName: @"SystemInfo"
                                            inManagedObjectContext: [appDelegate managedObjectContext]];
    [systemInfoFetch setEntity: si];
    NSArray *DBsi = [[appDelegate managedObjectContext] executeFetchRequest: systemInfoFetch error: &error];
    
    for (SystemInfo *si in DBsi) {
        self.emailAddressTextField.text = si.registerEmail;
        [[appDelegate managedObjectContext] deleteObject: si];
    }
    
    // initialize tee to AGGIES so 0 will not get passed in
    tee = AGGIES;
    
    // initialize handedness and gender
    hand = 1;
    gender = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    // initialize tee to AGGIES so 0 will not get passed in
    tee = AGGIES;
    
    // initialize handedness and gender
    hand = 1;
    gender = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    // Dismiss keyboard(s)
    [firstNameTextField resignFirstResponder];
    [lastNameTextField resignFirstResponder];
    [emailAddressTextField resignFirstResponder];
    [membershipNumberTextField resignFirstResponder];
    [nicknameTextField resignFirstResponder];
    
    // proper algorithm steps
    // 1. Check to make sure all required fields are set.
    // 2. Check email address is a valid email.
    // 3. Check to see if the API is reachable (aka connected to clubhouse WiFi)
    // 4. Start spinner
    // 5. Make request
    // 6. Stop spinner
    // 7. Deal with error, if any
    // 8. Add User to core data
    // 9. dismiss page
    
    // make sure required fields are set
    if (lastNameTextField.text.length != 0
        && firstNameTextField.text.length != 0
        && emailAddressTextField.text.length != 0) {
        
        // check for valid email address
        // Borrowed code from - sligthly modified
        // http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
        
        BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
        NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
        NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if ([emailTest evaluateWithObject: self.emailAddressTextField.text]) {
            
            // check for reachability
            Reachability *reach = [Reachability reachabilityWithHostname: HOSTNAME];
            
            if ([reach isReachable]) {
                
                // start progress spinner
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
                hud.labelText = @"Loading...";
                
                // format the name string correctly
                NSString *name = [NSString stringWithFormat: @"%@%@%@", lastNameTextField.text, @", ", firstNameTextField.text];
                
                // create NSDictionary representing the User to send to the API
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                
                [params setObject: self.membershipNumberTextField.text.length != 0 ? self.membershipNumberTextField.text : [NSNull null] forKey: @"memberID"];
                [params setObject: self.nicknameTextField.text.length != 0 ? self.nicknameTextField.text : [NSNull null] forKey: @"nickname"];
                [params setObject: name ? name : [NSNull null] forKey: @"name"];
                [params setObject: self.emailAddressTextField.text ? self.emailAddressTextField.text : [NSNull null] forKey: @"email"];
                
                NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys: params, @"user" , nil];
                
                // send the request
                [[LRResty authenticatedClientWithUsername: API_USERNAME
                                                 password: API_PASSWORD
                  ]
                 post: [NSString stringWithFormat: @"%@%@", BASE_URL, @"users/"]
                 payload: [[SBJsonWriter alloc] stringWithObject: user]
                 headers: [NSDictionary dictionaryWithObject: @"application/json"
                                                      forKey: @"Content-Type"
                           ]
                 withBlock: ^(LRRestyResponse *r) {
                     // once the request finished, hide the spinner thing
                     [MBProgressHUD hideHUDForView: self.view animated: YES];
                     
                     if (r.status == 201) {
                         // Success
                         // Dismiss View and add golfer
                         // decode the json
                         SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                         NSDictionary *jsonObject = [jsonParser objectWithData: r.responseData];
                         NSDictionary *user = [jsonObject valueForKey: @"user"];
                         
                         // obtain the appDelegate to get the managedObjectContext
                         id appDelegate = (id)[[UIApplication sharedApplication] delegate];
                         
                         // create an error object
                         NSError *error;
                         
                         NSMutableArray *golfers = [[NSMutableArray alloc] init];
                         
                         NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                         NSEntityDescription *entity = [NSEntityDescription entityForName: @"User"
                                                                   inManagedObjectContext: [appDelegate managedObjectContext]];
                         [fetchRequest setEntity: entity];
                         NSArray *fetchedObjects = [[appDelegate managedObjectContext] executeFetchRequest: fetchRequest error: &error];
                         for (User *u in fetchedObjects) {
                             [golfers addObject: u];
                         }
                         
                         // set up the DB
                         User *u = [NSEntityDescription
                                    insertNewObjectForEntityForName: @"User"
                                    inManagedObjectContext: [appDelegate managedObjectContext]];
                         
                         // required fields
                         u.userID =    [[NSNumber alloc] initWithInt: [[user valueForKey: @"id"] intValue]];
                         u.name =      [user valueForKey: @"name"];
                         u.email =     [user valueForKey: @"email"];
                         
                         // optional fields
                         if ([user valueForKey: @"memberID"] != [NSNull null]) {
                             u.memberID =  [user valueForKey: @"memberID"];
                         }
                         if ([user valueForKey: @"nickname"] != [NSNull null]) {
                             u.nickname =  [user valueForKey: @"nickname"];
                         }
                         
                         // set the tee
                         u.tee = [NSNumber numberWithInt:tee];
                         u.order = [NSNumber numberWithInt: [golfers count] + 1];
                         
                         // create a new info entity
                         UserStageInfo *info = [NSEntityDescription
                                                insertNewObjectForEntityForName: @"UserStageInfo"
                                                inManagedObjectContext: [appDelegate managedObjectContext]];
                         
                         info.stage = [NSNumber numberWithInt: STAGE_START];
                         info.holeNumber = @1;
                         info.shotNumber = @1;
                         
                         if (golfers.count == 0) {
                             // set currentGolfer to YES because this is the first golfer added
                             info.currentGolfer = [NSNumber numberWithBool: YES];
                         } else {
                             info.currentGolfer = [NSNumber numberWithBool: NO];
                         }
                         
                         // set relationships
                         info.user = u;
                         u.stageInfo = info;
                         
                         if (![[appDelegate managedObjectContext] save: &error]) {
                             NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                         }
                
                 // go back 2 view controllers
                 [[self navigationController] popToViewController:[[[self navigationController] viewControllers] objectAtIndex: [[[self navigationController] viewControllers] count] - 3]animated:YES];
                     
                     } else {
                         if (r.status >= 500) {
                             AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Server Error" message:@"The server is experiencing problems. Please try again later."];
                             [alert applyCustomAlertAppearance];
                             __weak AHAlertView *weakAlert = alert;
                             [alert addButtonWithTitle:@"OK" block:^{
                                 weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                             }];
                             [alert show];
                         } else if (r.status == 400) {
                             AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"User Error" message:@"Please insert all required information."];
                             [alert applyCustomAlertAppearance];
                             __weak AHAlertView *weakAlert = alert;
                             [alert addButtonWithTitle:@"OK" block:^{
                                 weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                             }];
                             [alert show];
                         } else if (r.status == 412) {
                             AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"User Error" message:@"MemberID and email already taken."];
                             [alert applyCustomAlertAppearance];
                             __weak AHAlertView *weakAlert = alert;
                             [alert addButtonWithTitle:@"OK" block:^{
                                 weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                             }];
                             [alert show];
                         } else if (r.status == 406) {
                             AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"User Error" message:@"MemberID already taken."];
                             [alert applyCustomAlertAppearance];
                             __weak AHAlertView *weakAlert = alert;
                             [alert addButtonWithTitle:@"OK" block:^{
                                 weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                             }];
                             [alert show];
                         } else if (r.status == 409) {
                             AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"User Error" message:@"Email already taken."];
                             [alert applyCustomAlertAppearance];
                             __weak AHAlertView *weakAlert = alert;
                             [alert addButtonWithTitle:@"OK" block:^{
                                 weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                             }];
                             [alert show];
                         } else {
                             // handle this error better
                             AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Unknown Error" message:@"Something went terribly wrong."];
                             [alert applyCustomAlertAppearance];
                             __weak AHAlertView *weakAlert = alert;
                             [alert addButtonWithTitle:@"OK" block:^{
                                 weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                             }];
                             [alert show];
                             
                         }
                     }
                 }
                 ];
                
            } else {
                AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Connection Error" message:@"You must be connected to the Wi-Fi at the club house for this action."];
                [alert applyCustomAlertAppearance];
                __weak AHAlertView *weakAlert = alert;
                [alert addButtonWithTitle:@"OK" block:^{
                    weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                }];
                [alert show];
            }
        } else {
            // email validation failed
            AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Invalid Input" message:@"The email you entered is not a valid email address. Please try again."];
            [alert applyCustomAlertAppearance];
            __weak AHAlertView *weakAlert = alert;
            [alert addButtonWithTitle:@"OK" block:^{
                weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            }];
            [alert show];
        }
    } else {
        // required fields failed
        
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Error" message:@"Please fill out all required fields."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
    }
}

- (IBAction)teeChanged:(id)sender {
    
    switch (self.teeSegment.selectedSegmentIndex) {
            case 0:
                tee = AGGIES;
                NSLog(@"aggies");
                break;
            case 1:
                tee = MAROONS;
                NSLog(@"maroons");
                break;
            case 2:
                tee = COWBELLS;
                NSLog(@"cowbells");
                break;
            case 3:
                tee = BULLDOGS;
                NSLog(@"bulldogs");
                break;
            default:
                break;
        }
}


- (IBAction)handChanged:(id)sender {
    
    switch (self.handSegment.selectedSegmentIndex) {
        case 0:
            // left handed
            hand = 0;
            NSLog(@"left handed");
            break;
        case 1:
            // right handed
            hand = 1;
            NSLog(@"right handed");
            break;
        default:
            break;
    }
}


- (IBAction)genderChanged:(id)sender {
    
    switch (self.genderSegment.selectedSegmentIndex) {
        case 0:
            // male
            gender = 0;
            NSLog(@"male");
            break;
        case 1:
            // female
            gender = 1;
            NSLog(@"female");
            break;
        default:
            break;
    }
}

@end
