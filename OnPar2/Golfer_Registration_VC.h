//
//  RegistrationVC.h
//  OnPar2
//
//  Created by Chad Galloway on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import "Config.h"

@interface Golfer_Registration_VC : UIViewController

@property (strong, nonatomic) IBOutlet SLGlowingTextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet SLGlowingTextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet SLGlowingTextField *emailAddressTextField;
@property (strong, nonatomic) IBOutlet SLGlowingTextField *membershipNumberTextField;
@property (strong, nonatomic) IBOutlet SLGlowingTextField *nicknameTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *teeSegment;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)teeChanged:(id)sender;

@end
