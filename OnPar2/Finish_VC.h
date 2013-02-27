//
//  Finish_VC.h
//  OnPar2
//
//  Created by Chad Galloway on 2/19/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import "Config.h"

@interface Finish_VC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblScore;
@property (weak, nonatomic) IBOutlet UILabel *lblPutts;
@property (weak, nonatomic) IBOutlet UILabel *lblFIR;
@property (weak, nonatomic) IBOutlet UIStepper *stepScore;
@property (weak, nonatomic) IBOutlet UIStepper *stepPutts;
@property (weak, nonatomic) IBOutlet UISwitch *switchFIR;

- (IBAction)save:(id)sender;
- (IBAction)scoreChange:(id)sender;
- (IBAction)puttChange:(id)sender;


@end
