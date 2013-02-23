//
//  Finish_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/19/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Finish_VC.h"

@interface Finish_VC ()
{
    NSMutableDictionary *golfers;
    NSMutableDictionary *rounds;
    
    User *currentGolfer;
    Round *currentRound;
    Hole *currentHole;
}

@end

@implementation Finish_VC

@synthesize lblPutts, lblScore, stepPutts, stepScore, switchFIR;

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
    
    // set the current Round, Hole, and Shot
    currentRound = [rounds objectForKey: currentGolfer.userID];
    
    currentHole = nil;
    
    for (Hole *h in currentRound.holes) {
        if ([currentGolfer.stageInfo.holeNumber isEqualToNumber: h.holeNumber]) {
            currentHole = h;
            break;
        }
    }
    
    [self stepperInit];
    
    self.lblScore.text = [NSString stringWithFormat: @"%.f", self.stepScore.value];
    self.lblPutts.text = [NSString stringWithFormat: @"%.f", self.stepPutts.value];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender
{
    currentHole.holeScore = [NSNumber numberWithInt: self.stepScore.value];
    currentHole.putts = [NSNumber numberWithInt: self.stepPutts.value];
    
    int scoreGIR = [currentHole.holeScore intValue] - [currentHole.putts intValue];
    
    int parGIR = [currentHole.par intValue] - 2;
    
    if (scoreGIR <= parGIR) {
        currentHole.green_in_reg = [NSNumber numberWithBool: YES];
    } else {
        currentHole.green_in_reg = [NSNumber numberWithBool: NO];
    }
    
    currentHole.fairway_in_reg = [NSNumber numberWithBool: self.switchFIR.isOn];
    
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
     
    int holeNumber = [currentGolfer.stageInfo.holeNumber intValue];
     
    // do not advance to hole 19
    if (holeNumber + 1 != 19) {
        currentGolfer.stageInfo.holeNumber = [NSNumber numberWithInt: holeNumber + 1];
    } else {
        // if they finish hole 18, set them to stage done
        currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_START];
        currentGolfer.stageInfo.holeNumber = [NSNumber numberWithInt: 1];
    }
    
    //NSLog(@"CURRENT HOLE: %@", currentHole);
     
    // save the user's updated information
    NSError *error;
     
    if (![[appDelegate managedObjectContext] save: &error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)scoreChange:(id)sender
{
    double stepperValue = self.stepScore.value;
    self.lblScore.text = [NSString stringWithFormat: @"%.f", stepperValue];
}

- (IBAction)puttChange:(id)sender
{
    double stepperValue = self.stepPutts.value;
    self.lblPutts.text = [NSString stringWithFormat: @"%.f", stepperValue];
}

-(void)stepperInit
{
    self.stepScore.value = [currentHole.par intValue];
    self.stepScore.minimumValue = 1;
    self.stepScore.maximumValue = [currentHole.par intValue] * 4;
    self.stepScore.stepValue = 1;
    self.stepScore.wraps = YES;
    self.stepScore.autorepeat = YES;
    self.stepScore.continuous = YES;
    
    self.stepPutts.value = 0;
    self.stepPutts.minimumValue = 0;
    self.stepPutts.maximumValue = 10;
    self.stepPutts.stepValue = 1;
    self.stepPutts.wraps = YES;
    self.stepPutts.autorepeat = YES;
    self.stepPutts.continuous = YES;
}

@end
