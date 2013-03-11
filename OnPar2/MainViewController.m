//
//  MainViewController.m
//  OnPar2
//
//  Created by Chad Galloway on 2/12/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "MainViewController.h"
#import "Golfer_VC.h"
#import "Config.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize btnStart, btnNew, btnContinue;

@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self hideNavBar];

}

- (void)viewWillDisappear:(BOOL)animated
{
    // Used to show navbar when other view loads
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
    // end
}

- (void)viewWillAppear:(BOOL)animated
{
    // hide all buttons
    btnContinue.hidden = YES;
    btnNew.hidden = YES;
    btnStart.hidden = YES;
    
    // Used to hide navbar when view appears
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    // end
    
    // pull information from the database
    // if there is any, show the continue button
    // and give them the choice to continue the started round
    
    // load rounds that are in database
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    NSFetchRequest *roundFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *round = [NSEntityDescription entityForName: @"Round"
                                              inManagedObjectContext: [appDelegate managedObjectContext]];
    [roundFetch setEntity: round];
    NSArray *rounds = [[appDelegate managedObjectContext] executeFetchRequest: roundFetch error: &error];
    
    if ([rounds count] > 0) {
        btnNew.hidden = NO;
        btnContinue.hidden = NO;
    } else {
        btnStart.hidden = NO;
    }
    
    // Part of hiding navbar
    [super viewWillAppear:animated];
    // end
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller
/*
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}
 */

- (void)hideNavBar
{
    self.navigationController.navigationBar.hidden = YES;
}


- (IBAction)startButton:(id)sender
{
    // either a new round or deleting the current info and
    // start a new round(s)
    
    // just to make sure there is no stale information in the DB
    // delete everything just to be sure - can't hurt
    
    //[self performSegueWithIdentifier:@"main2options" sender:self];
    [self newButton: self];
}

- (IBAction)newButton:(id)sender
{
    [self deleteEverything: (id)[[UIApplication sharedApplication] delegate]];
    
    [self performSegueWithIdentifier:@"main2options" sender:self];
}

- (IBAction)continueRound:(id)sender
{
    // segue straight to the Play_VC
    // should be able to determine everything from the DB
    
    [self performSegueWithIdentifier:@"main2play" sender:self];
}

- (void)deleteEverything: (id)appDelegate
{
    // clear the User Table
    NSError *error;
    
    NSFetchRequest *userFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *user = [NSEntityDescription entityForName: @"User"
                                            inManagedObjectContext: [appDelegate managedObjectContext]];
    [userFetch setEntity: user];
    NSArray *users = [[appDelegate managedObjectContext] executeFetchRequest: userFetch error: &error];
    for (User *u in users) {
        [[appDelegate managedObjectContext] deleteObject: u];
    }
    
    // clear the Round Table
    NSFetchRequest *roundFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *round = [NSEntityDescription entityForName: @"Round"
                                             inManagedObjectContext: [appDelegate managedObjectContext]];
    [roundFetch setEntity: round];
    NSArray *rounds = [[appDelegate managedObjectContext] executeFetchRequest: roundFetch error: &error];
    for (Round *r in rounds) {
        [[appDelegate managedObjectContext] deleteObject: r];
    }
}

// rotation testing
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
