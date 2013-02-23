
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

#import <Foundation/Foundation.h>

@interface defines : NSObject

// API HTTP Basic Authentication parameters
FOUNDATION_EXPORT NSString *const API_USERNAME;
FOUNDATION_EXPORT NSString *const API_PASSWORD;

// Club constants
FOUNDATION_EXPORT int const DRIVER;
FOUNDATION_EXPORT int const THREE_WOOD;
FOUNDATION_EXPORT int const FOUR_WOOD;
FOUNDATION_EXPORT int const FIVE_WOOD;
FOUNDATION_EXPORT int const SEVEN_WOOD;
FOUNDATION_EXPORT int const NINE_WOOD;
FOUNDATION_EXPORT int const TWO_HYBRID;
FOUNDATION_EXPORT int const THREE_HYBRID;
FOUNDATION_EXPORT int const FOUR_HYBRID;
FOUNDATION_EXPORT int const FIVE_HYBRID;
FOUNDATION_EXPORT int const SIX_HYBRID;
FOUNDATION_EXPORT int const TWO_IRON;
FOUNDATION_EXPORT int const THREE_IRON;
FOUNDATION_EXPORT int const FOUR_IRON;
FOUNDATION_EXPORT int const FIVE_IRON;
FOUNDATION_EXPORT int const SIX_IRON;
FOUNDATION_EXPORT int const SEVEN_IRON;
FOUNDATION_EXPORT int const EIGHT_IRON;
FOUNDATION_EXPORT int const NINE_IRON;
FOUNDATION_EXPORT int const PW;
FOUNDATION_EXPORT int const AW;
FOUNDATION_EXPORT int const SW;
FOUNDATION_EXPORT int const LW;
FOUNDATION_EXPORT int const HLW;

// tee constants
FOUNDATION_EXPORT int const AGGIES;
FOUNDATION_EXPORT int const MAROONS;
FOUNDATION_EXPORT int const COWBELLS;
FOUNDATION_EXPORT int const BULLDOGS;

// Earth radius in yards
FOUNDATION_EXPORT double const EARTH_RADIUS_IN_YARDS;
FOUNDATION_EXPORT double const METERS_TO_YARDS;

// tee constants
FOUNDATION_EXPORT int const STAGE_AIM;
FOUNDATION_EXPORT int const STAGE_CLUB_SELECT;
FOUNDATION_EXPORT int const STAGE_START;
FOUNDATION_EXPORT int const STAGE_END;
FOUNDATION_EXPORT int const STAGE_DONE;

// male and female
FOUNDATION_EXPORT int const MALE;
FOUNDATION_EXPORT int const FEMALE;

// right and left hand
FOUNDATION_EXPORT int const RIGHT_HAND;
FOUNDATION_EXPORT int const LEFT_HAND;

//Base URL
FOUNDATION_EXPORT NSString *const HOSTNAME;
FOUNDATION_EXPORT NSString *const BASE_URL;


@end

