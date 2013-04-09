//
//  XYPair.h
//  OnPar
//
//  Created by Chad Galloway on 1/27/13.
//  Copyright (c) 2013 Mississippi State. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYPair : NSObject

@property(nonatomic) double _x;
@property(nonatomic) double _y;

#pragma mark - Initialization
- (id)init;
- (id)initWithX: (double)x andY: (double)y;
- (id)initWithXYPair: (XYPair*)xy;

#pragma mark - Printing
- (NSString *)description;

#pragma mark - Distance Calculations
- (double)distanceInX: (XYPair*)xy;
- (double)distanceInY: (XYPair*)xy;
- (double)distanceInXY: (XYPair*)xy;

@end
