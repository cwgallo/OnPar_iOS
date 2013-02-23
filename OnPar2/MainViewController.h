//
//  MainViewController.h
//  OnPar2
//
//  Created by Chad Galloway on 2/12/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

@interface MainViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (strong, nonatomic) IBOutlet UIButton *btnStart;
@property (strong, nonatomic) IBOutlet UIButton *btnNew;


- (IBAction)startButton:(id)sender;
- (IBAction)newButton:(id)sender;
- (IBAction)continueRound:(id)sender;

- (void)deleteEverything:(id)appDelegate;

@end
