//
//  Golfer_VC.h
//  OnPar2
//
//  Created by Chad Galloway on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import "Config.h"

@interface GolferVC : UIViewController<UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate>

@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UITableView *golferTableView;
@property (strong, nonatomic) IBOutlet UIStepper *holeStepper;
@property (strong, nonatomic) IBOutlet UILabel *holeNumberLabel;
@property (strong, nonatomic) IBOutlet UIView *myView;

- (IBAction)startRound:(id)sender;
- (IBAction)valueChanged:(id)sender;

@end
