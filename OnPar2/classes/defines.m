
/**
 * OnPar - Fall 2012 software engineering senior design project at Mississippi
 *         State University.
 *
 * @author  Fall 2012 Senior Design Team
 * @version 1.0
 * @package OnPar
 */

/**
 * Class defines
 * @package iOS
 * @author  Kevin Benton
 * @version 1.0
 *
 * Constants for use throughout the application.
 *
 */

#import "defines.h"

@implementation defines

NSString *const API_USERNAME = @"cse3213";
NSString *const API_PASSWORD = @"test";

int const DRIVER       = 1;
int const THREE_WOOD   = 2;
int const FOUR_WOOD    = 3;
int const FIVE_WOOD    = 4;
int const SEVEN_WOOD   = 5;
int const NINE_WOOD    = 6;
int const TWO_HYBRID   = 7;
int const THREE_HYBRID = 8;
int const FOUR_HYBRID  = 9;
int const FIVE_HYBRID  = 10;
int const SIX_HYBRID   = 11;
int const TWO_IRON     = 12;
int const THREE_IRON   = 13;
int const FOUR_IRON    = 14;
int const FIVE_IRON    = 15;
int const SIX_IRON     = 16;
int const SEVEN_IRON   = 17;
int const EIGHT_IRON   = 18;
int const NINE_IRON    = 19;
int const PW           = 20;
int const AW           = 21;
int const SW           = 22;
int const LW           = 23;
int const HLW          = 24;

int const AGGIES    = 1;
int const MAROONS   = 2;
int const COWBELLS  = 3;
int const BULLDOGS  = 4;

double const EARTH_RADIUS_IN_YARDS = 13950131.0/2;
double const METERS_TO_YARDS = 1.09361;

int const STAGE_AIM           = 0;
int const STAGE_CLUB_SELECT   = 1;
int const STAGE_START         = 2;
int const STAGE_END           = 3;
int const STAGE_DONE          = 4;

int const MALE = 1;
int const FEMALE = 0;

int const RIGHT_HAND = 1;
int const LEFT_HAND = 0;

NSString *const HOSTNAME = @"shadowrealm.cse.msstate.edu";
NSString *const BASE_URL = @"http://shadowrealm.cse.msstate.edu/gsas/API/";

@end
