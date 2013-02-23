//
//  Upload_Results_VC.h
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import "Config.h"

@interface Upload_Results : UIViewController

@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;

#pragma mark - Labels
/*@property (strong, nonatomic) IBOutlet UILabel *golfer1Label;
@property (strong, nonatomic) IBOutlet UILabel *golfer2Label;
@property (strong, nonatomic) IBOutlet UILabel *golfer3Label;
@property (strong, nonatomic) IBOutlet UILabel *golfer4Label;

#pragma mark - Switches
@property (strong, nonatomic) IBOutlet DCRoundSwitch *golfer1Switch;
@property (strong, nonatomic) IBOutlet DCRoundSwitch *golfer2Switch;
@property (strong, nonatomic) IBOutlet DCRoundSwitch *golfer3Switch;
@property (strong, nonatomic) IBOutlet DCRoundSwitch *golfer4Switch;*/

#pragma mark - Actions
- (IBAction)uploadResults:(id)sender;



@end
