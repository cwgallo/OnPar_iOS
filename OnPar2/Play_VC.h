//
//  Play_VC.h
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import "Config.h"
//#import <CoreLocation/CoreLocation.h>

#define CLUBTYPE   0
#define CLUBNUMBER 1

@interface Play_VC : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    UIPickerView *clubPicker;
}


#pragma mark - View

@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) IBOutlet UIButton *finishButton;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *endButton;
@property (strong, nonatomic) IBOutlet UITextField *txtClub;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UILabel *holeLabel;
@property (weak, nonatomic) IBOutlet UILabel *parLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceToGreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *holeDistanceLabel;

#pragma mark - Core Location

@property (nonatomic, retain) CLLocationManager *locationMgr;
@property (nonatomic, retain) CLLocation *lastLocation;


#pragma mark - Actions

- (IBAction)selectGolfer:(id)sender;
- (IBAction)endGame:(id)sender;
- (IBAction)skipHole:(id)sender;
- (IBAction)finishHole:(id)sender;
- (IBAction)startShot:(id)sender;
- (IBAction)endShot:(id)sender;
- (IBAction)doneAim:(id)sender;



#pragma mark - Club Select

@property(nonatomic, retain) NSMutableArray *clubType;
@property(nonatomic, retain) NSMutableArray *woodNum;
@property(nonatomic, retain) NSMutableArray *hybridNum;
@property(nonatomic, retain) NSMutableArray *ironNum;
@property(nonatomic, retain) NSMutableArray *wedgeType;



#pragma mark - Gesture
- (IBAction)handleTap: (UIGestureRecognizer *)recognizer;
- (IBAction)handleLongPress: (UIGestureRecognizer *)recognizer;

@end
