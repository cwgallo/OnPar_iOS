//
//  Play_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Play_VC.h"
#import "MainViewController.h" // needed for deleteEverything

@interface Play_VC ()

@end

@implementation Play_VC{
    NSMutableDictionary *golfers;
    NSMutableDictionary *rounds;
    
    User *currentGolfer;
    Round *currentRound;
    Hole *currentHole;
    Shot *currentShot;
    
    CLLocation *centerOfGreen;
    
    int selectedClubType;
    int selectedClubNumber;
    int selectedClub;
}

@synthesize myImageView, myScrollView, navBar, txtClub;
@synthesize startButton, endButton, finishButton, skipButton, doneButton;
@synthesize clubType, woodNum, hybridNum, ironNum, wedgeType;
@synthesize holeLabel, parLabel, stageLabel, distanceToGreeLabel, holeDistanceLabel;

@synthesize locationMgr = _locationMgr;
@synthesize lastLocation = _lastLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Loads

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // longPress gesture initializer
    UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    gesture.minimumPressDuration = 0.1;
    gesture.numberOfTouchesRequired = 1;
    [myImageView addGestureRecognizer: gesture];
    
    // Preparing Club Selection
    [self populateClubArrays];
    clubPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    clubPicker  .delegate = self;
    clubPicker  .dataSource = self;
    [clubPicker  setShowsSelectionIndicator:YES];
    txtClub.inputView =  clubPicker;
    
    // Create done button in UIPickerView
    UIToolbar*  mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    mypickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [mypickerToolbar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    // TODO - add club selection label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 216, 23)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Club Selection";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    UIBarButtonItem *barLabel = [[UIBarButtonItem alloc] initWithCustomView:label];
    [barItems addObject:barLabel];
    
    
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
    [barItems addObject:doneBtn];
    [mypickerToolbar setItems:barItems animated:YES];
    txtClub.inputAccessoryView = mypickerToolbar;
    
    
    // location manager
    self.locationMgr = [[CLLocationManager alloc] init];
    
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationMgr.delegate = self;
    
    // the app has to have services enabled to function
    // so check if they are enabled
    // if not alert them to turn it on and send them back a page

    // just constantly track satelite location
    [self.locationMgr startUpdatingLocation];
    
    // should only have to retrieve the golfers once
    golfers = [[NSMutableDictionary alloc] init];
    rounds = [[NSMutableDictionary alloc] init];
    
    // load golfers that are in database
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    NSFetchRequest *userFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *user = [NSEntityDescription entityForName: @"User"
                                            inManagedObjectContext: [appDelegate managedObjectContext]];
    [userFetch setEntity: user];
    NSArray *users = [[appDelegate managedObjectContext] executeFetchRequest: userFetch error: &error];
    
    // load the rounds from the database to see if there are any
    // there should always be some in the DB
    NSFetchRequest *roundFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *round = [NSEntityDescription entityForName: @"Round"
                                             inManagedObjectContext: [appDelegate managedObjectContext]];
    [roundFetch setEntity: round];
    NSArray *DBrounds = [[appDelegate managedObjectContext] executeFetchRequest: roundFetch error: &error];
    
    if (DBrounds.count != 0) {
        for (Round *r in DBrounds) {
            [rounds setObject: r forKey: r.userID];
        }
    }
    
    for (User *u in users) {
        [golfers setObject: u forKey: u.userID];
        
        // check to see if this is the current golfer
        if ([u.stageInfo.currentGolfer isEqualToNumber: [NSNumber numberWithBool: YES]]) {
            currentGolfer = u;
        }
    }
    
    
    // set correct hole image
    if (currentGolfer.nickname != nil)
        [navBar setTitle:currentGolfer.nickname];
    else
        [navBar setTitle:currentGolfer.name];
    
    //[self setHoleImageForUser: currentGolfer];
}

- (void)viewWillAppear:(BOOL)animated
{
    // don't hide the nav bar
    [NSTimer scheduledTimerWithTimeInterval:0.20 target:self selector:@selector(showNavBar) userInfo:nil repeats:NO];
    
    // get the picture for the golfer
    UIImage *holeImage = [self getHoleImageForUser: currentGolfer];
    [self displayImage: holeImage];
    
    // set the current Round, Hole, and Shot
    currentRound = [rounds objectForKey: currentGolfer.userID];
    
    currentHole = nil;
    currentShot = nil;
    
    for (Hole *h in currentRound.holes) {
        if ([currentGolfer.stageInfo.holeNumber isEqualToNumber: h.holeNumber]) {
            currentHole = h;
            for (Shot *s in currentHole.shots) {
                if ([currentGolfer.stageInfo.shotNumber isEqualToNumber: s.shotNumber]) {
                    currentShot = s;
                    break;
                }
            }
            break;
        }
    }
    
    centerOfGreen = [[CLLocation alloc] initWithLatitude: [currentHole.secondRefLat doubleValue] longitude: [currentHole.secondRefLong doubleValue]];
    
    self.parLabel.text = [NSString stringWithFormat: @"%@", currentHole.par];
    self.holeLabel.text = [NSString stringWithFormat: @"%@", currentHole.holeNumber];
    self.holeDistanceLabel.text = [NSString stringWithFormat: @"%@", currentHole.distance];
    
    if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_START]]) {
        NSLog(@"Stage START for golfer: %@", currentGolfer.name);
        // hide end button and show start
        endButton.hidden = YES;
        startButton.hidden = NO;
        finishButton.hidden = NO;
        doneButton.hidden = YES;
        skipButton.hidden = NO;
        
        self.stageLabel.text = @"Start shot";
        
    } else if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_CLUB_SELECT]]) {
        NSLog(@"Stage CLUB_SELECT for golfer: %@", currentGolfer.name);
        // there won't be any real change here since it's just another alert
        // hide end button and start
        endButton.hidden = YES;
        startButton.hidden = YES;
        finishButton.hidden = YES;
        doneButton.hidden = YES;
        skipButton.hidden = YES;
        
        self.stageLabel.text = @"Select club";
        
        // manually call club select function
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(selectAClub:) userInfo:nil repeats:NO];
        
    } else if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_AIM]]) {
        NSLog(@"Stage AIM for golfer: %@", currentGolfer.name);
        // hide end button and start button
        endButton.hidden = YES;
        startButton.hidden = YES;
        finishButton.hidden = YES;
        skipButton.hidden = YES;
        
        // hide the done button until there has been an aim made
        // the button will be shown in the aim function
        doneButton.hidden = YES;
        
        self.stageLabel.text = @"Aim";
        
    } else if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_END]]) {
        NSLog(@"Stage END for golfer: %@", currentGolfer.name);
        // show end button and hide start button
        endButton.hidden = NO;
        startButton.hidden = YES;
        finishButton.hidden = YES;
        doneButton.hidden = YES;
        skipButton.hidden = YES;
        
        
        self.stageLabel.text = @"End shot";
        
    } else {
        NSLog(@"Stage DONE for golfer: %@", currentGolfer.name);
        // stage done
        // dont shoe any buttons
        startButton.hidden = YES;
        endButton.hidden = YES;
        skipButton.hidden = YES;
        finishButton.hidden = YES;
        doneButton.hidden = YES;
        
        self.stageLabel.text = @"Finished";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Hole Options

- (IBAction)skipHole:(id)sender
{
    // delete the shots in the current hole
    // if they skip the hole, there is no reason
    // to keep the shots that have already been made
    // go ahead and clear the hole info too
    
    currentHole.shots = [[NSSet alloc] init];
    currentHole.putts = nil;
    currentHole.holeScore = nil;
    currentHole.fairway_in_reg = nil;
    currentHole.green_in_reg = nil;
    
    // update the holeNumber and stage of the User's stage info
    currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_START];
    
    int hole = [currentGolfer.stageInfo.holeNumber intValue];
    
    // do not advance to hole 19
    if (hole + 1 != 19) {
        currentGolfer.stageInfo.holeNumber = [NSNumber numberWithInt: hole + 1];
    } else {
        // if they finish hole 18, set them to stage done
        currentGolfer.stageInfo.holeNumber = [NSNumber numberWithInt: 1];
    }
    
    // create a new hole to add to the hole object with the updated hole number
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    // delete the current shot
    if (currentShot != nil) {
        [[appDelegate managedObjectContext] deleteObject: currentShot];
        currentShot = nil;
    }
    
    //NSLog(@"CURRENT SHOT: %@", currentShot);
    //NSLog(@"CURRENT HOLE: %@", currentHole);
    
    if (![[appDelegate managedObjectContext] save: &error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [self viewWillAppear: NO];
}

- (IBAction)finishHole:(id)sender
{
    // make sure the current shot is finished
    // save the hole to the database
    // update the User's holeNumber in the User's stageInfo
    
    if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_START]]) {
        
        // segue to the scoring VC
        [self performSegueWithIdentifier: @"play2finish" sender: self];
        
    } else {
        // tell the User to finish the hole
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Error" message:@"You must finish the current shot before ending the hole."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
    }
    
    [self viewWillAppear: NO];
}


#pragma mark - Shot Options

- (IBAction)startShot:(id)sender
{
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSError *error;
    
    // check to see if the current shot was reached
    // if there is no current shot, create one
    if (currentShot == nil) {
        Shot *s = [NSEntityDescription
                   insertNewObjectForEntityForName: @"Shot"
                   inManagedObjectContext: [appDelegate managedObjectContext]];
        
        s.shotNumber = currentGolfer.stageInfo.shotNumber;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        } else {
            currentShot = s;
        }
    }
    
    // alert to tell them to press OK at the location of the ball
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Start Shot" message:@"Press OK when at the ball's location for the start of the shot."];
    [alert applyCustomAlertAppearance];
    __weak AHAlertView *weakAlert = alert;
    [alert addButtonWithTitle:@"OK" block:^{
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        currentShot.startLatitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.latitude];
        currentShot.startLongitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.longitude];
        
        currentShot.hole = currentHole;
        [currentHole addShotsObject: currentShot];
        
        // update the user's stage info to be at STAGE_CLUB_SELECT
        currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_CLUB_SELECT];
        
        // save to core data
        
        NSError *error;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        // calling view will appear will make club selection alert come up
        [self viewWillAppear: NO];
        
        weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
    }];
    [alert show];
}

- (IBAction)endShot:(id)sender
{
    // collect the end lat and long of the shot
    // make sure all the fields of the shot are there
    // save shot to DB
    // update user's shotNumber
    // set User's stage to stage_start
    
    currentShot.endLatitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.latitude];
    currentShot.endLongitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.longitude];
    
    if (currentShot.startLatitude == nil || currentShot.startLongitude == nil ||
        currentShot.aimLatitude == nil || currentShot.aimLongitude == nil ||
        currentShot.endLatitude == nil || currentShot.endLongitude == nil ||
        currentShot.club == nil || currentShot.shotNumber == nil) {
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Error" message:@"Some field is not set."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
    } else {
        currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_START];
        int shotNumber = [currentGolfer.stageInfo.shotNumber intValue];
        currentGolfer.stageInfo.shotNumber = [NSNumber numberWithInt: shotNumber + 1];
        
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"End Shot" message:@"Press OK when at the ball's location for the end of the shot."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            currentShot.startLatitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.latitude];
            currentShot.startLongitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.longitude];
            
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
        
        // make sure the shot is relationed to the hole
        currentShot.hole = currentHole;
        [currentHole addShotsObject: currentShot];
        
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        NSError *error;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
    [self viewWillAppear: NO];
}

- (IBAction)doneAim:(id)sender {
    if (currentShot.aimLatitude != nil && currentShot.aimLongitude != nil) {
        currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_END];
        
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        NSError *error;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        [self viewWillAppear: NO];
    } else {
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Select Aim" message:@"You must aim before continuing."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
    }
}


#pragma mark - Ending Game

- (IBAction)endGame:(id)sender
{
    if ([ZFloatingManager shouldFloatingWithIdentifierAppear:@"Golfers"])
    {
        
        ZAction *cancel = [ZAction actionWithTitle:@"Cancel" target:self action:nil object:nil];
        
        NSMutableArray *options = [[NSMutableArray alloc] init];
            
        ZAction *option;
        
        option = [ZAction actionWithTitle: @"Upload Results" target:self action:@selector(uploadResults) object:nil];

        [options addObject: option];
        
        option = [ZAction actionWithTitle: @"Discard Results"  target:self action:@selector(discardResults) object:nil];
            
        [options addObject: option];
        
        ZActionSheet *sheet = [[ZActionSheet alloc] initWithTitle:@"End Game?" cancelAction:cancel destructiveAction:nil otherActions: options];
        sheet.identifier = @"End";
        [sheet showFromBarButtonItem:sender animated:YES];
    }
}

- (void)uploadResults
{
    // Does not matter if all user's have finished the round
    // sometimes a User might leave early, the group may only
    // play nine holes, etc.
    // It is up to the User to decide when the end of the
    // round is.
    
    // Going to a new page so updating location is no
    // longer needed.
    //NSLog(@"Stop updating location");
    [self.locationMgr stopUpdatingLocation];
    
    // Go to upload page
    //NSLog(@"Preparing segue");
    [self performSegueWithIdentifier: @"play2upload" sender:self];
}

- (void)discardResults
{
    // TODO - Display alert
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Discard Round" message:@"Are you sure you wish to discard the results?"];
    [alert applyCustomAlertAppearance];
    __weak AHAlertView *weakAlert = alert;
    [alert setCancelButtonTitle:@"No" block:^{
        // do nothing
        weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
    }];
    [alert addButtonWithTitle:@"Yes" block:^{
        // Going to a new page so updating location is no
        // longer needed.
        [self.locationMgr stopUpdatingLocation];
        
        // Delete everything
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        MainViewController *mvc = [[MainViewController alloc] init];
        [mvc deleteEverything:appDelegate];
        
        // Return to main page
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }];
    [alert show];
}


#pragma mark - Changing Golfers

- (IBAction)selectGolfer:(id)sender;
{
    
    if ([ZFloatingManager shouldFloatingWithIdentifierAppear:@"End"])
    {
        
        ZAction *cancel = [ZAction actionWithTitle:@"Cancel" target:self action:nil object:nil];
        
        NSMutableArray *options = [[NSMutableArray alloc] init];
        
        int counter = 1;
        for (NSNumber *key in golfers) {
            ZAction *option;
            
            User *u = [golfers objectForKey: key];
            
            if (u.nickname != nil)
                option = [ZAction actionWithTitle: u.nickname  target:self action:@selector(changeGolfer:) object: u];
            else
                option = [ZAction actionWithTitle: u.name  target:self action:@selector(changeGolfer:) object: u];
            
            [options addObject: option];
            
            counter++;
        }
        
        ZActionSheet *sheet = [[ZActionSheet alloc] initWithTitle:@"Select A Golfer" cancelAction:cancel destructiveAction:nil otherActions:options];
        
        sheet.identifier = @"Golfers";
        [sheet showFromBarButtonItem:sender animated:YES];
        
    }
}

- (void)changeGolfer:(id)object
{
    // Make golfer change here
    currentGolfer = object;
    
    for (NSNumber *key in golfers) {
        User *u = [golfers objectForKey: key];
        
        if ([u.userID isEqualToNumber: currentGolfer.userID]) {
            u.stageInfo.currentGolfer = [NSNumber numberWithBool: YES];
        } else {
            u.stageInfo.currentGolfer = [NSNumber numberWithBool: NO];
        }
    }
    
    // save the user's stage to the DB
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    if (![[appDelegate managedObjectContext] save: &error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    // Set nav bar title
    if (currentGolfer.nickname != nil) {
        self.navBar.title = [[NSString alloc] initWithFormat:@"%@", currentGolfer.nickname];
    } else {
        self.navBar.title = [[NSString alloc] initWithFormat:@"%@", currentGolfer.name];
    }
    
    [self viewWillAppear: NO];
}


#pragma mark - helper functions
- (void) displayImage: (UIImage *) image
{
    [myImageView setImage: image];
}

- (UIImage *)getHoleImageForUser: (User *)u
{
    NSNumber *hole = u.stageInfo.holeNumber;
    NSString *filename = [NSString stringWithFormat:@"%@%@%@", @"hole", hole, @".png"];
    
    return [UIImage imageNamed:filename];
}


// Borrowed from: http://stackoverflow.com/questions/7313023/overlay-an-image-over-another-image-in-ios
-(UIImage *) drawImage:(UIImage*) fgImage
              inImage:(UIImage*) bgImage
              atPoint:(CGPoint)  point
{
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    [fgImage drawInRect:CGRectMake( point.x - 10, point.y - 10, fgImage.size.width, fgImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mark - core location

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (!self.lastLocation) {
        self.lastLocation = newLocation;
    }
    
    if (newLocation.coordinate.latitude != self.lastLocation.coordinate.latitude &&
        newLocation.coordinate.longitude != self.lastLocation.coordinate.longitude) {
        self.lastLocation = newLocation;
        [self.locationMgr stopUpdatingLocation];
    }
    
    // update distance to center of green
    CLLocationDistance distance = [self.lastLocation distanceFromLocation: centerOfGreen];
    
    // display the results
    if (distance < 999.00) {
        self.distanceToGreeLabel.text = [NSString stringWithFormat: @"%1.2f", distance * METERS_TO_YARDS];
    } else {
        self.distanceToGreeLabel.text = @">999";
    }
}

- (void) locationManager: (CLLocationManager *) manager didFailWithError: (NSError *) error
{
    if (error.code == 1) {
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Location Error" message:@"Location services must be enabled for this application. This includes the addition of a GPS module for iPod touches. Location services can be edited in Settings."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            [self.locationMgr stopUpdatingLocation];
            
            // go back a VC
            [[self navigationController] popViewControllerAnimated:YES];
            
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
    } else {
        NSLog(@"Receieved Core Location error %@", error);
        NSLog(@"%ld", (long)error.code);
    }
    [self.locationMgr stopUpdatingLocation];
}

#pragma mark - Gestures

- (IBAction)handleTap: (UIGestureRecognizer *)recognizer
{
    // set the User's curent shot aim lat/long
    if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_AIM]]) {
        // Get tap location within myImageView
        CGPoint aimLocation = [recognizer locationInView:self.myImageView];
        
        // myImageView is 1/2 size of original image so multiply by 2 to get original pixel values
        aimLocation.x *= 2;
        aimLocation.y *= 2;
        
        XYPair *aim = [[XYPair alloc] initWithX:aimLocation.x andY:aimLocation.y];
        
        LLPair *llpair = [self calculateAimLLWithAimXY:aim];
        
        // set aim lat/long here
        currentShot.aimLatitude = [NSNumber numberWithDouble: llpair._lat];
        currentShot.aimLongitude = [NSNumber numberWithDouble: llpair._lon];
        
        //NSLog(@"Shot lat: %@", currentShot.aimLatitude);
        //NSLog(@"Shot long: %@", currentShot.aimLongitude);
        
        // save the club selection and user's stage to the DB
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        NSError *error;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        // redraw the picture
        NSString *filename = [NSString stringWithFormat:@"%@%@%@", @"hole", currentHole.holeNumber, @".png"];
        
        UIImage *holeImage = [UIImage imageNamed:filename];
        UIImage *redDot = [UIImage imageNamed: @"reddot.png"];
        
        UIImage *newImage = [self drawImage: redDot
                                    inImage: holeImage
                                    atPoint: aimLocation];
        
        [myImageView setImage: newImage];
        
        // instead of transitioning, show the done button
        self.doneButton.hidden = NO;
    }
}

- (IBAction)handleLongPress: (UIGestureRecognizer *)recognizer
{
    // set the User's curent shot aim lat/long
    if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_AIM]]) {
        // Get tap location within myImageView
        CGPoint aimLocation = [recognizer locationInView:self.myImageView];
        
        // myImageView is 1/2 size of original image so multiply by 2 to get original pixel values
        aimLocation.x *= 2;
        aimLocation.y *= 2;
        
        XYPair *aim = [[XYPair alloc] initWithX:aimLocation.x andY:aimLocation.y];
        
        LLPair *llpair = [self calculateAimLLWithAimXY:aim];
        
        // set aim lat/long here
        currentShot.aimLatitude = [NSNumber numberWithDouble: llpair._lat];
        currentShot.aimLongitude = [NSNumber numberWithDouble: llpair._lon];
        
        //NSLog(@"Shot lat: %@", currentShot.aimLatitude);
        //NSLog(@"Shot long: %@", currentShot.aimLongitude);
        
        // save the club selection and user's stage to the DB
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        NSError *error;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        // redraw the picture
        NSString *filename = [NSString stringWithFormat:@"%@%@%@", @"hole", currentHole.holeNumber, @".png"];
        
        UIImage *holeImage = [UIImage imageNamed:filename];
        UIImage *redDot = [UIImage imageNamed: @"reddot.png"];
        
        UIImage *newImage = [self drawImage: redDot
                                    inImage: holeImage
                                    atPoint: aimLocation];
        
        [myImageView setImage: newImage];
        
        // instead of transitioning, show the done button
        self.doneButton.hidden = NO;
    }
}

#pragma mark - Calculate Aim LL

- (LLPair*)calculateAimLLWithAimXY: (XYPair*)aimXY{
    
    // retrieve known points for this hole
    
    //NSLog(@"First Tee X: %@ \nFirst Tee Y: %@", currentHole.firstRefX, currentHole.firstRefY);
    XYPair *teeXY0 = [[XYPair alloc] initWithX: [currentHole.firstRefX doubleValue] andY: [currentHole.firstRefY doubleValue]];
    //NSLog(@"First Tee Lat: %@ \nFirst Tee Long: %@", currentHole.firstRefLat, currentHole.firstRefLong);
    LLPair *teeLLDeg = [[LLPair alloc] initWithLat: [currentHole.firstRefLat doubleValue] andLon: [currentHole.firstRefLong doubleValue]];
    LLPair *teeLLRad = [[LLPair alloc] initWithLLPair:[teeLLDeg deg2rad]];
    XYPair *teeLLRadFlat = [[XYPair alloc] initWithX:teeLLRad._lon andY:teeLLRad._lat];
    //NSLog(@"FlatTee is %@", teeLLRadFlat);
    
    //NSLog(@"Second Tee X: %@ \nSecond Tee Y: %@", currentHole.secondRefX, currentHole.secondRefY);
    XYPair *centerXY0 = [[XYPair alloc] initWithX: [currentHole.secondRefX doubleValue] andY: [currentHole.secondRefY doubleValue]];
    //NSLog(@"Second Tee Lat: %@ \nSecond Tee Long: %@", currentHole.secondRefLat, currentHole.secondRefLong);
    LLPair *centerLLDeg = [[LLPair alloc] initWithLat: [currentHole.secondRefLat doubleValue] andLon: [currentHole.secondRefLong doubleValue]];
    LLPair *centerLLRad = [[LLPair alloc] initWithLLPair:[centerLLDeg deg2rad]];
    XYPair *centerLLRadFlat = [[XYPair alloc] initWithX:centerLLRad._lon andY:centerLLRad._lat];
    //NSLog(@"FlatCenter is %@", centerLLRadFlat);
    
    XYPair *aimXY0 = [[XYPair alloc] initWithXYPair:aimXY];
    LLPair *aimLLDeg = [[LLPair alloc] init];
    LLPair *aimLLRad = [[LLPair alloc] init];
    
    // Get height of image
    double height = myImageView.bounds.size.height * 2; // times 2 bc it is only half size
    ///NSLog(@"Height of image is: %f", height);
    
    // 1st coordinate conversion
    XYPair *teeXY1 = [self convertXY0toXY1WithXYPair:teeXY0 andHeight:height];
    XYPair *centerXY1 = [self convertXY0toXY1WithXYPair:centerXY0 andHeight:height];
    XYPair *aimXY1 = [self convertXY0toXY1WithXYPair:aimXY0 andHeight:height];
    
    // Calculate angle of rotation
    double rotation = [self angleOfRotationUsingTeeXY:teeXY1 andTeeLL:teeLLRad andCenterXY:centerXY1 andCenterLL:centerLLRad];
    
    // 2nd coordinate conversion
    XYPair *teeXY2 = [self convertXY1toXY2WithXYPair:teeXY1 andAngle:rotation];
    //NSLog(@"TeeXY2 is %@", teeXY2);
    XYPair *centerXY2 = [self convertXY1toXY2WithXYPair:centerXY1 andAngle:rotation];
    //NSLog(@"CenterXY2 is %@", centerXY2);
    XYPair *aimXY2 = [self convertXY1toXY2WithXYPair:aimXY1 andAngle:rotation];
    //NSLog(@"AimXY2 is %@", aimXY2);
    
    // Get Flat Earth Scaling Factors
    XYPair *scaleFactors = [[XYPair alloc] initWithXYPair:[self getFlatEarthScaleUsingTeeXY:teeXY2 andTeeLLRadFlat:teeLLRadFlat andCenterXY:centerXY2 andCenterLLRadFlat:centerLLRadFlat]];
    
    //NSLog(@"Scaling factors are %@", scaleFactors);
    
    // Get Aim LL
    aimLLRad = [self getAimLLUsingAimXY: (XYPair*)aimXY2 andCenterXY: (XYPair*)centerXY2 andCenterLLRadFlat: (XYPair*)centerLLRadFlat andScaleFactors: (XYPair*) scaleFactors];
    aimLLDeg = [aimLLRad rad2deg];
    
    //NSLog(@"AimLLRad is %@", aimLLRad);
    NSLog(@"AimLLDeg is %@", aimLLDeg);
    
    // calculate distances to display
    // from current location to aim point
    // from aim point to center of green
    // from current location to green
    
    // changing to return the lat/long degress
    //return aimLLRad;
    return aimLLDeg;
}


#pragma mark - Coordinate Conversions

- (XYPair*)convertXY0toXY1WithXYPair: (XYPair*)xy andHeight: (double)height{
    
    XYPair *results = [[XYPair alloc] init];
    results._x = xy._x;
    results._y = height - xy._y;
    return results;
}

- (XYPair*)convertXY1toXY2WithXYPair: (XYPair*)xy andAngle: (double)angle{
    
    XYPair *results = [[XYPair alloc] init];
    results._x = xy._x*cos(angle) - xy._y*sin(angle);
    results._y = xy._x*sin(angle) - xy._y*cos(angle);
    return results;
}


#pragma mark - Angle of Rotation

- (double)angleOfRotationUsingTeeXY: (XYPair*)teeXY1 andTeeLL: (LLPair*)teeLLRad andCenterXY: (XYPair*)centerXY1 andCenterLL: (LLPair*)centerLLRad{
    
    // Calculate sin and cos in XY
    double sinXY = [self sinPixelUsingPoint1: (XYPair*)teeXY1 andPoint2: (XYPair*)centerXY1];
    double cosXY = [self cosPixelUsingPoint1: (XYPair*)teeXY1 andPoint2: (XYPair*)centerXY1];
    
    // Calculate sin and cos in LL
    double sinLL = [self sinGPSUsingPoint1:teeLLRad andPoint2:centerLLRad];
    double cosLL = [self cosGPSUsingPoint1:teeLLRad andPoint2:centerLLRad];
    
    // Calculate sin and cos of angle of rotation
    double sinRot = [self sinLLminusXYUsingSinLL:sinLL andCosLL:cosLL andSinXY:sinXY andCosXY:cosXY];
    double cosRot = [self cosLLminusXYUsingSinLL:sinLL andCosLL:cosLL andSinXY:sinXY andCosXY:cosXY];
    
    // Calculate angle
    double sinRotation = asin(sinRot);
    double cosRotation = acos(cosRot);
    
    // TESTING
    NSLog(@"Angle of rotation derived... ");
    NSLog(@"From SIN");
    NSLog(@"\tDegrees: %f", sinRotation*180.0/M_PI);
    NSLog(@"\tRadians: %f", sinRotation);
    NSLog(@"From COS");
    NSLog(@"\tDegrees: %f", cosRotation*180.0/M_PI);
    NSLog(@"\tRadians: %f", cosRotation);
	
    return sinRotation;
}


#pragma mark - Trig Angle Identities

- (double)sinPixelUsingPoint1: (XYPair*)point1 andPoint2: (XYPair*)point2{
    
    return [point1 distanceInY:point2] / [point1 distanceInXY:point2];
}

- (double)cosPixelUsingPoint1: (XYPair*)point1 andPoint2: (XYPair*)point2{
    
    return [point1 distanceInX:point2] / [point1 distanceInXY:point2];
}

- (double)sinGPSUsingPoint1: (LLPair*)point1 andPoint2: (LLPair*)point2{
    
    return [point1 distanceInLat:point2] / [point1 distanceInLatLon:point2];
}

- (double)cosGPSUsingPoint1: (LLPair*)point1 andPoint2: (LLPair*)point2{
    
    return [point1 distanceInLon:point2] / [point1 distanceInLatLon:point2];
}


#pragma mark - Trig Sum and Diff Formulas

- (double)sinLLplusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return sinLL*cosXY + cosLL*sinXY;
}

- (double)sinLLminusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return sinLL*cosXY - cosLL*sinXY;
}

- (double)cosLLplusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return cosLL*cosXY - sinLL*sinXY;
}

- (double)cosLLminusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return cosLL*cosXY + sinLL*sinXY;
}


#pragma mark - Scaling

- (XYPair*)getFlatEarthScaleUsingTeeXY: (XYPair*)teeXY2 andTeeLLRadFlat: (XYPair*)teeLLRadFlat andCenterXY: (XYPair*)centerXY2 andCenterLLRadFlat: (XYPair*)centerLLRadFlat{
    
    double scaleX = [teeLLRadFlat distanceInX:centerLLRadFlat] / [teeXY2 distanceInX:centerXY2];
    double scaleY = [teeLLRadFlat distanceInY:centerLLRadFlat] / [teeXY2 distanceInY:centerXY2];
    
    XYPair *results = [[XYPair alloc] init];
    results._x = scaleX;
    results._y = scaleY;
    
    //NSLog(@"SFs are %@", results);
    
    return results;
}


#pragma mark - Get Aim LL
- (LLPair*)getAimLLUsingAimXY: (XYPair*)aimXY2 andCenterXY: (XYPair*)centerXY2 andCenterLLRadFlat: (XYPair*)centerLLRadFlat andScaleFactors: (XYPair*) scaleFactors{
    
    double aimLon = centerLLRadFlat._x + (aimXY2._x - centerXY2._x) * scaleFactors._x;
    //NSLog(@"Aim longitude is %.8f", aimLon);
    double aimLat = centerLLRadFlat._y + (aimXY2._y - centerXY2._y) * scaleFactors._y;
    //NSLog(@"Aim latitude is %.8f", aimLat);
    
    LLPair *results = [[LLPair alloc] init];
    results._lat = aimLat;
    results._lon = aimLon;
    
    return results;
}

#pragma mark - Club Selection methods

- (void)selectAClub:(id)sender
{
    [txtClub becomeFirstResponder];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == CLUBTYPE)
        return [clubType count];
    else if (component == CLUBNUMBER && selectedClubType == 0)
        return [woodNum count];
    else if (component == CLUBNUMBER && selectedClubType == 1)
        return [hybridNum count];
    else if (component == CLUBNUMBER && selectedClubType == 2)
        return [ironNum count];
    else if (component == CLUBNUMBER && selectedClubType == 3)
        return [wedgeType count];
    else
        return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == CLUBTYPE)
        return [clubType objectAtIndex:row];
    else if (component == CLUBNUMBER && selectedClubType == 0)
        return [woodNum objectAtIndex:row];
    else if (component == CLUBNUMBER && selectedClubType == 1)
        return [hybridNum objectAtIndex:row];
    else if (component == CLUBNUMBER && selectedClubType == 2)
        return [ironNum objectAtIndex:row];
    else if (component == CLUBNUMBER && selectedClubType == 3)
        return [wedgeType objectAtIndex:row];
    else
        return 0;
    
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    selectedClubType = [pickerView selectedRowInComponent:CLUBTYPE];
    
    if (component == CLUBTYPE && selectedClubType >= 0)
    {
        [pickerView reloadComponent:CLUBNUMBER];
        [pickerView selectRow:0 inComponent:CLUBNUMBER animated:YES];
    }
    
    selectedClubNumber = [pickerView selectedRowInComponent:CLUBNUMBER];
    
    //NSLog(@" %i %i selected", selectedClubType, selectedClubNumber);
    
    [self saveClubType: selectedClubType andNum: selectedClubNumber];
    
    //NSLog(@"Selected Club is: %i", selectedClub);
}


- (void) saveClubType:(int)type andNum:(int)num
{
    // CHANGE LABEL
    switch (type)
    {
            // WOOD
        case 0:
            switch (num)
        {
                // DRIVER
            case 0:
                selectedClub = DRIVER;
                break;
                // 3
            case 1:
                selectedClub = THREE_WOOD;
                break;
                // 4
            case 2:
                selectedClub = FOUR_WOOD;
                break;
                // 5
            case 3:
                selectedClub = FIVE_WOOD;
                break;
                // 7
            case 4:
                selectedClub = SEVEN_WOOD;
                break;
                // 9
            case 5:
                selectedClub = NINE_WOOD;
                break;
        }
            break;
            
            
            // HYBRID
        case 1:
            switch (selectedClubNumber)
        {
                // 2
            case 0:
                selectedClub = TWO_HYBRID;
                break;
                // 3f
            case 1:
                selectedClub = THREE_HYBRID;
                break;
                // 4
            case 2:
                selectedClub = FOUR_HYBRID;
                break;
                // 5
            case 3:
                selectedClub = FIVE_HYBRID;
                break;
                // 6
            case 4:
                selectedClub = SIX_HYBRID;
                break;
        }
            
            break;
            
            // IRON
        case 2:
            switch (selectedClubNumber)
        {
                // 2
            case 0:
                selectedClub = TWO_IRON;
                break;
                // 3
            case 1:
                selectedClub = THREE_IRON;
                break;
                // 4
            case 2:
                selectedClub = FOUR_IRON;
                break;
                // 5
            case 3:
                selectedClub = FIVE_IRON;
                break;
                // 6
            case 4:
                selectedClub = SIX_IRON;
                break;
                // 7
            case 5:
                selectedClub = SEVEN_IRON;
                break;
                // 8
            case 6:
                selectedClub = EIGHT_IRON;
                break;
                // 9
            case 7:
                selectedClub = NINE_IRON;
                break;
        }
            
            break;
            
            // WEDGE
        case 3:
            switch (selectedClubNumber)
        {
            case 0:
                selectedClub = AW;
                break;
            case 1:
                selectedClub = HLW;
                break;
            case 2:
                selectedClub = LW;
                break;
            case 3:
                selectedClub = PW;
                break;
            case 4:
                selectedClub = SW;
                break;
        }
            
            break;
    }
}

-(void)pickerDoneClicked
{
  	//NSLog(@"Done Clicked");

    if (selectedClub != 0) {
        currentShot.club = [NSNumber numberWithInt: selectedClub];
    } else {
        currentShot.club = [NSNumber numberWithInt: DRIVER];
    }
    
    // set User's stage to STAGE_AIM
    currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_AIM];
    
    // save the club selection and user's stage to the DB
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    if (![[appDelegate managedObjectContext] save: &error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [self viewWillAppear: NO];
    
    [txtClub resignFirstResponder];
}

- (void)populateClubArrays
{
    clubType = [[NSMutableArray alloc] init];
    [clubType addObject:@" Wood "];
    [clubType addObject:@" Hybrid "];
    [clubType addObject:@" Iron "];
    [clubType addObject:@" Wedge "];
    
    woodNum = [[NSMutableArray alloc] init];
    [woodNum addObject:@" Driver "];
    [woodNum addObject:@" 3 "];
    [woodNum addObject:@" 4 "];
    [woodNum addObject:@" 5 "];
    [woodNum addObject:@" 7 "];
    [woodNum addObject:@" 9 "];
    
    hybridNum = [[NSMutableArray alloc] init];
    [hybridNum addObject:@" 2 "];
    [hybridNum addObject:@" 3 "];
    [hybridNum addObject:@" 4 "];
    [hybridNum addObject:@" 5 "];
    [hybridNum addObject:@" 6 "];
    
    ironNum = [[NSMutableArray alloc] init];
    [ironNum addObject:@" 2 "];
    [ironNum addObject:@" 3 "];
    [ironNum addObject:@" 4 "];
    [ironNum addObject:@" 5 "];
    [ironNum addObject:@" 6 "];
    [ironNum addObject:@" 7 "];
    [ironNum addObject:@" 8 "];
    [ironNum addObject:@" 9 "];
    
    wedgeType = [[NSMutableArray alloc] init];
    [wedgeType addObject:@" Approach "];
    [wedgeType addObject:@" High Lob "];
    [wedgeType addObject:@" Lob "];
    [wedgeType addObject:@" Pitching "];
    [wedgeType addObject:@" Sand "];
}

- (void)showNavBar
{
    [[[self navigationController] navigationBar] setHidden:NO];
}

@end
