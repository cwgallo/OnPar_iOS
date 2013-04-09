//
//  Math.m
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Math.h"

@implementation Math


- (id) init
{
    self = [super init];
    return self;
}

- (LLPair *)getLatLonFromSelectedXY: (XYPair*)selectedXY FromImageView: (UIImageView*)imageView OnHole: (Hole*)currentHole
{
    // retrieve known points for this hole
    
    //NSLog(@"Tee X: %@ \nTee Y: %@", currentHole.firstRefX, currentHole.firstRefY);
    XYPair *teeXY0 = [[XYPair alloc] initWithX: [currentHole.firstRefX doubleValue] andY: [currentHole.firstRefY doubleValue]];
    //NSLog(@"Tee Lat: %@ \nTee Long: %@", currentHole.firstRefLat, currentHole.firstRefLong);
    LLPair *teeLLDeg = [[LLPair alloc] initWithLat: [currentHole.firstRefLat doubleValue] andLon: [currentHole.firstRefLong doubleValue]];
    LLPair *teeLLRad = [[LLPair alloc] initWithLLPair:[teeLLDeg deg2rad]];
    XYPair *teeLLRadFlat = [[XYPair alloc] initWithX:teeLLRad._lon andY:teeLLRad._lat];
    //NSLog(@"FlatTee is %@", teeLLRadFlat);
    
    //NSLog(@"Green X: %@ \nGreen Y: %@", currentHole.secondRefX, currentHole.secondRefY);
    XYPair *greenXY0 = [[XYPair alloc] initWithX: [currentHole.secondRefX doubleValue] andY: [currentHole.secondRefY doubleValue]];
    //NSLog(@"Green Lat: %@ \nGreen Long: %@", currentHole.secondRefLat, currentHole.secondRefLong);
    LLPair *greenLLDeg = [[LLPair alloc] initWithLat: [currentHole.secondRefLat doubleValue] andLon: [currentHole.secondRefLong doubleValue]];
    LLPair *greenLLRad = [[LLPair alloc] initWithLLPair:[greenLLDeg deg2rad]];
    XYPair *greenLLRadFlat = [[XYPair alloc] initWithX:greenLLRad._lon andY:greenLLRad._lat];
    //NSLog(@"FlatGreen is %@", greenLLRadFlat);
    
    XYPair *selectedXY0 = [[XYPair alloc] initWithXYPair:selectedXY];
    LLPair *selectedLLDeg = [[LLPair alloc] init];
    LLPair *selectedLLRad = [[LLPair alloc] init];
    
    // Get height of image
    double height = imageView.bounds.size.height * 2; // times 2 bc it is only half size
    //NSLog(@"Height of image is: %f", height);
    
    // 1st coordinate conversion
    XYPair *teeXY1 = [self convertXY0toXY1WithXYPair:teeXY0 andHeight:height];
    //NSLog(@"teeXY1: %@", teeXY1);
    XYPair *greenXY1 = [self convertXY0toXY1WithXYPair:greenXY0 andHeight:height];
    //NSLog(@"greenXY1: %@", greenXY1);
    XYPair *selectedXY1 = [self convertXY0toXY1WithXYPair:selectedXY0 andHeight:height];
    //NSLog(@"selectedXY1: %@", selectedXY1);
    
    // Calculate angle of rotation
    SinCosPair *rotation = [self angleOfRotationUsingTeeXY:teeXY1 andTeeLL:teeLLRad andGreenXY:greenXY1 andGreenLL:greenLLRad];
    
    
    // 2nd coordinate conversion
    XYPair *teeXY2 = [self convertXY1toXY2WithXYPair:teeXY1 andAngles:rotation];
    //NSLog(@"TeeXY2 is %@", teeXY2);
    XYPair *greenXY2 = [self convertXY1toXY2WithXYPair:greenXY1 andAngles:rotation];
    //NSLog(@"GreenXY2 is %@", greenXY2);
    XYPair *selectedXY2 = [self convertXY1toXY2WithXYPair:selectedXY1 andAngles:rotation];
    //NSLog(@"SelectedXY2 is %@", selectedXY2);
    
    // Get Flat Earth Scaling Factors
    XYPair *scaleFactors = [[XYPair alloc] initWithXYPair:[self getXYtoLatLonFlatEarthScaleUsingTeeXY:teeXY2 andTeeLLRadFlat:teeLLRadFlat andGreenXY:greenXY2 andGreenLLRadFlat:greenLLRadFlat]];
    
    //NSLog(@"Scaling factors are %@", scaleFactors);
    
    // Get Aim LL
    selectedLLRad = [self calculateSelectedLLUsingSelectedXY: (XYPair*)selectedXY2 andGreenXY: (XYPair*)greenXY2 andGreenLLRadFlat: (XYPair*)greenLLRadFlat andScaleFactors: (XYPair*) scaleFactors];
    
    selectedLLDeg = [selectedLLRad rad2deg];
    
    //NSLog(@"AimLLRad is %@", aimLLRad);
    //NSLog(@"SelectedLLDeg is %@", selectedLLDeg);
    
    // calculate distances to display
    // from current location to aim point
    // from aim point to center of green
    // from current location to green
    
    // changing to return the lat/long degress
    //return aimLLRad;
    return selectedLLDeg;
}


- (XYPair *)getXYFromSelectedLatLon: (LLPair*)selectedLatLon InImageView: (UIImageView*) imageView OnHole: (Hole*)currentHole
{
    
    LLPair *selectedLLDeg = [[LLPair alloc] initWithLat:selectedLatLon._lat andLon:selectedLatLon._lon];
    LLPair *selectedLLRad = [[LLPair alloc] initWithLLPair: [selectedLLDeg deg2rad]];
    XYPair *selectedLLRadFlat = [[XYPair alloc] initWithX:selectedLLRad._lon andY:selectedLLRad._lat];
    
    // retrieve known points for this hole
    
    //NSLog(@"Tee X: %@ \nTee Y: %@", currentHole.firstRefX, currentHole.firstRefY);
    XYPair *teeXY0 = [[XYPair alloc] initWithX: [currentHole.firstRefX doubleValue] andY: [currentHole.firstRefY doubleValue]];
    //NSLog(@"Tee Lat: %@ \nTee Long: %@", currentHole.firstRefLat, currentHole.firstRefLong);
    LLPair *teeLLDeg = [[LLPair alloc] initWithLat: [currentHole.firstRefLat doubleValue] andLon: [currentHole.firstRefLong doubleValue]];
    LLPair *teeLLRad = [[LLPair alloc] initWithLLPair:[teeLLDeg deg2rad]];
    XYPair *teeLLRadFlat = [[XYPair alloc] initWithX:teeLLRad._lon andY:teeLLRad._lat];
    //NSLog(@"FlatTee is %@", teeLLRadFlat);
    
    //NSLog(@"Green X: %@ \nGreen Y: %@", currentHole.secondRefX, currentHole.secondRefY);
    XYPair *greenXY0 = [[XYPair alloc] initWithX: [currentHole.secondRefX doubleValue] andY: [currentHole.secondRefY doubleValue]];
    //NSLog(@"Green Lat: %@ \nGreen Long: %@", currentHole.secondRefLat, currentHole.secondRefLong);
    LLPair *greenLLDeg = [[LLPair alloc] initWithLat: [currentHole.secondRefLat doubleValue] andLon: [currentHole.secondRefLong doubleValue]];
    LLPair *greenLLRad = [[LLPair alloc] initWithLLPair:[greenLLDeg deg2rad]];
    XYPair *greenLLRadFlat = [[XYPair alloc] initWithX:greenLLRad._lon andY:greenLLRad._lat];
    //NSLog(@"FlatGreen is %@", greenLLRadFlat);

    // Get height of image
    double height = imageView.bounds.size.height * 2; // times 2 bc it is only half size
    //NSLog(@"Height of image is: %f", height);
    
    // 1st coordinate conversion
    XYPair *teeXY1 = [self convertXY0toXY1WithXYPair:teeXY0 andHeight:height];
    XYPair *greenXY1 = [self convertXY0toXY1WithXYPair:greenXY0 andHeight:height];
    
    // Calculate angle of rotation
    SinCosPair *rotation = [self angleOfRotationUsingTeeXY:teeXY1 andTeeLL:teeLLRad andGreenXY:greenXY1 andGreenLL:greenLLRad];
    
    // 2nd coordinate conversion
    XYPair *teeXY2 = [self convertXY1toXY2WithXYPair:teeXY1 andAngles:rotation];
    XYPair *greenXY2 = [self convertXY1toXY2WithXYPair:greenXY1 andAngles:rotation];    
    
    // Get Flat Earth Scaling Factors
    XYPair *scaleFactors = [[XYPair alloc] initWithXYPair:[self getXYtoLatLonFlatEarthScaleUsingTeeXY:teeXY2 andTeeLLRadFlat:teeLLRadFlat andGreenXY:greenXY2 andGreenLLRadFlat:greenLLRadFlat]];
    
    //NSLog(@"Scaling factors are %@", scaleFactors);
    
    // first convert
    XYPair *locationXY2 = [[XYPair alloc] initWithXYPair: [self scaleConvertForLatLontoXY:selectedLLRadFlat withTeeXY: teeXY2 TeeLLRadFlat: teeLLRadFlat GreenXY: greenXY2 GreenLLRadFlat: greenLLRadFlat andScaleFactors: scaleFactors]];
    //NSLog(@"selectedXY2: %@", locationXY2);
    
    // second convert
    XYPair *locationXY1 = [[XYPair alloc] initWithXYPair:[self convertXY2toXY1WithXYPair: locationXY2 andAngles: rotation]];
    //NSLog(@"selectedXY1: %@", locationXY1);
    
    // last convert
    XYPair *locationXY0 = [[XYPair alloc] initWithXYPair:[self convertXY1toXY0WithXYPair:locationXY1 andHeight:height]];
    //NSLog(@"selectedXY0: %@", locationXY0);
    
    return locationXY0;
}



#pragma mark - Coordinate Conversions xy->gps

- (XYPair*)convertXY0toXY1WithXYPair: (XYPair*)xy andHeight: (double)height
{
    XYPair *results = [[XYPair alloc] init];
    results._x = xy._x;
    results._y = height - xy._y;
    return results;
}

- (XYPair*)convertXY1toXY2WithXYPair: (XYPair*)xy andAngles: (SinCosPair*)angles
{
    
    XYPair *results = [[XYPair alloc] init];
    results._y = ((sin(angles._sin)*xy._x) - (cos(angles._sin)*xy._y)) /
    ((cos(angles._sin)*cos(angles._cos)) - (sin(angles._cos)*sin(angles._sin)));
    results._x = (xy._x + (results._y * sin(angles._cos))) / (cos(angles._sin));
    return results;
}




#pragma mark - Coordinate Conversions gps->xy

- (XYPair*)convertXY2toXY1WithXYPair: (XYPair*)xy andAngles: (SinCosPair*)angles
{
    XYPair *results = [[XYPair alloc] init];
    results._y = ((sin(angles._sin) * xy._x) - (cos(angles._sin) * xy._y)) / ((cos(angles._sin) *cos(angles._cos)) - (sin(angles._cos) * sin(angles._sin)));
    results._x = ((xy._x + (results._y * sin(angles._cos)))/ cos(angles._cos));
    return results;
}

- (XYPair*)convertXY1toXY0WithXYPair: (XYPair*)xy andHeight: (double)height
{
    XYPair *results = [[XYPair alloc] init];
    results._x = xy._x;
    results._y = height - xy._y;
    return results;
}



#pragma mark - Angle of Rotation

- (SinCosPair*)angleOfRotationUsingTeeXY: (XYPair*)teeXY1 andTeeLL: (LLPair*)teeLLRad andGreenXY: (XYPair*)greenXY1 andGreenLL: (LLPair*)greenLLRad{
    
    // Calculate sin and cos in XY
    double sinXY = [self sinPixelUsingPoint1: (XYPair*)teeXY1 andPoint2: (XYPair*)greenXY1];
    double cosXY = [self cosPixelUsingPoint1: (XYPair*)teeXY1 andPoint2: (XYPair*)greenXY1];
    
    // Calculate sin and cos in LL
    double sinLL = [self sinGPSUsingPoint1:teeLLRad andPoint2:greenLLRad];
    double cosLL = [self cosGPSUsingPoint1:teeLLRad andPoint2:greenLLRad];
    
    // Calculate sin and cos of angle of rotation
    double sinRot = [self sinLLminusXYUsingSinLL:sinLL andCosLL:cosLL andSinXY:sinXY andCosXY:cosXY];
    double cosRot = [self cosLLminusXYUsingSinLL:sinLL andCosLL:cosLL andSinXY:sinXY andCosXY:cosXY];
    
    // Calculate angle
    double sinRotation = asin(sinRot);
    double cosRotation = acos(cosRot);
    
    /*
    // TESTING
    NSLog(@"Angle of rotation derived... ");
    NSLog(@"From SIN");
    NSLog(@"\tDegrees: %f", sinRotation*180.0/M_PI);
    NSLog(@"\tRadians: %f", sinRotation);
    NSLog(@"From COS");
    NSLog(@"\tDegrees: %f", cosRotation*180.0/M_PI);
    NSLog(@"\tRadians: %f", cosRotation);
	*/
    
    // Package results
    SinCosPair *rotation = [[SinCosPair alloc] initWithSin:sinRotation andCos:cosRotation];
    
    return rotation;
}


#pragma mark - Trig Angle Identities

- (double)sinPixelUsingPoint1: (XYPair*)point1 andPoint2: (XYPair*)point2{
    
    return [point1 distanceInY:point2] / [point1 distanceInXY:point2];
}

- (double)cosPixelUsingPoint1: (XYPair*)point1 andPoint2: (XYPair*)point2{
    
    return [point1 distanceInX:point2] / [point1 distanceInXY:point2];
}

- (double)sinGPSUsingPoint1: (LLPair*)point1 andPoint2: (LLPair*)point2{
    
    return [point1 distanceInLat:point2] / [point1 distanceInLatLon:point2];
}

- (double)cosGPSUsingPoint1: (LLPair*)point1 andPoint2: (LLPair*)point2{
    
    return [point1 distanceInLon:point2] / [point1 distanceInLatLon:point2];
}


#pragma mark - Trig Sum and Diff Formulas

- (double)sinLLplusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return sinLL*cosXY + cosLL*sinXY;
}

- (double)sinLLminusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return sinLL*cosXY - cosLL*sinXY;
}

- (double)cosLLplusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return cosLL*cosXY - sinLL*sinXY;
}

- (double)cosLLminusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return cosLL*cosXY + sinLL*sinXY;
}


#pragma mark - Scaling

- (XYPair*)getXYtoLatLonFlatEarthScaleUsingTeeXY: (XYPair*)teeXY2 andTeeLLRadFlat: (XYPair*)teeLLRadFlat andGreenXY: (XYPair*)greenXY2 andGreenLLRadFlat: (XYPair*)greenLLRadFlat{
    
    double scaleX = [teeLLRadFlat distanceInX:greenLLRadFlat] / [teeXY2 distanceInX:greenXY2];
    double scaleY = [teeLLRadFlat distanceInY:greenLLRadFlat] / [teeXY2 distanceInY:greenXY2];
    
    XYPair *results = [[XYPair alloc] init];
    results._x = scaleX;
    results._y = scaleY;
    
    //NSLog(@"SFs are %@", results);
    
    return results;
}

- (XYPair*)scaleConvertForLatLontoXY: (XYPair*)selectedLLRadFlat withTeeXY:(XYPair*)teeXY2 TeeLLRadFlat: (XYPair*)teeLLRadFlat GreenXY: (XYPair*)greenXY2 GreenLLRadFlat: (XYPair*)greenLLRadFlat andScaleFactors: (XYPair*)sf
{
    XYPair *results = [[XYPair alloc] init];

    //NSLog(@"selectedLLRadFlat: %@", selectedLLRadFlat);
    
    double scaleLon = ((selectedLLRadFlat._x - greenLLRadFlat._x) / sf._x) + greenXY2._x;
    double scaleLat = ((selectedLLRadFlat._y - greenLLRadFlat._y) / sf._y) + greenXY2._y;

    results._x = scaleLon;
    results._y = scaleLat;

    return results;
}



#pragma mark - Get Selected LL
- (LLPair*)calculateSelectedLLUsingSelectedXY: (XYPair*)selectedXY2 andGreenXY: (XYPair*)greenXY2 andGreenLLRadFlat: (XYPair*)greenLLRadFlat andScaleFactors: (XYPair*) scaleFactors
{    
    double selectedLon = greenLLRadFlat._x + (selectedXY2._x - greenXY2._x) * scaleFactors._x;
    //NSLog(@"Aim longitude is %.8f", aimLon);
    double selectedLat = greenLLRadFlat._y + (selectedXY2._y - greenXY2._y) * scaleFactors._y;
    //NSLog(@"Aim latitude is %.8f", aimLat);
    
    LLPair *results = [[LLPair alloc] init];
    results._lat = selectedLat;
    results._lon = selectedLon;
    
    return results;
}

@end
