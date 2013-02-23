//
//  LLPair.h
//  OnPar
//
//  Created by Chad Galloway on 1/27/13.
//  Copyright (c) 2013 Mississippi State. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLPair : NSObject

@property(nonatomic) double _lat;
@property(nonatomic) double _lon;

#pragma mark - Initialization
- (id)init;
- (id)initWithLat: (double)lat andLon: (double) lon;
- (id)initWithLLPair: (LLPair*)ll;

#pragma mark - Printing
- (NSString *)description;

#pragma mark - Distance Calculations
- (double)distanceInLat: (LLPair*)ll;
- (double)distanceInLon: (LLPair*)ll;
- (double)distanceInLatLon: (LLPair*)ll;

#pragma mark - Deg-Rad Conversions
- (LLPair*)deg2rad;
- (LLPair*)rad2deg;

@end
