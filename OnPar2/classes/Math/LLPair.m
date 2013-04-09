//
//  LLPair.m
//  OnPar
//
//  Created by Chad Galloway on 1/27/13.
//  Copyright (c) 2013 Mississippi State. All rights reserved.
//

#import "LLPair.h"
#import "defines.h"

@implementation LLPair

@synthesize _lat;
@synthesize _lon;


#pragma mark - Initialization

- (id)init {
    
    self = [super init];
    
    if(self){
        self._lat = 0;
        self._lon = 0;
    }
    
    return self;
}

- (id)initWithLat: (double)lat andLon: (double)lon {
    
    self = [super init];
    
    if(self){
        self._lat = lat;
        self._lon = lon;
    }
    
    return self;
}

- (id)initWithLLPair:(LLPair *)ll{
    
    self = [super init];
    
    if(self){
        self._lat = ll._lat;
        self._lon = ll._lon;
    }
    
    return self;
}


#pragma mark - Printing

- (NSString *)description {
    
    return [NSString stringWithFormat:@"(%.6f,%.6f)",_lat,_lon];
}


#pragma mark - Distance Calculations

- (double)distanceInLat: (LLPair*)ll{
    
    return 2 * EARTH_RADIUS_IN_YARDS * ( (ll._lat - self._lat) / 2);
}


- (double)distanceInLon: (LLPair*)ll{
    return 2 * EARTH_RADIUS_IN_YARDS * asin( sqrt( cos(ll._lat) * cos(self._lat) * pow( sin( (ll._lon - self._lon) / 2 ), 2) ) );
}


- (double)distanceInLatLon: (LLPair*)ll{
    return 2 * EARTH_RADIUS_IN_YARDS * asin( sqrt( pow( sin( (ll._lat - self._lat) / 2 ), 2) + cos(ll._lat) * cos(self._lat) * pow( sin( (ll._lon - self._lon) / 2 ), 2) ) );
}


#pragma mark - Deg-Rad Conversions

- (LLPair*)deg2rad{
    LLPair *temp = [[LLPair alloc] init];
    temp._lat = self._lat * M_PI / 180.0;
    temp._lon = self._lon * M_PI / 180.0;
    return temp;
}

- (LLPair*)rad2deg{
    LLPair *temp = [[LLPair alloc] init];
    temp._lat = self._lat * 180.0 / M_PI;
    temp._lon = self._lon * 180.0 / M_PI;
    return temp;
}

@end
