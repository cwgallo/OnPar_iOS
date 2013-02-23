//
//  XYPair.m
//  OnPar
//
//  Created by Chad Galloway on 1/27/13.
//  Copyright (c) 2013 Mississippi State. All rights reserved.
//

#import "XYPair.h"

@implementation XYPair

@synthesize _x, _y;


#pragma mark - Initialization

- (id) init
{
    self = [super init];
    
    if(self){
        self._x = 0;
        self._y = 0;
    }
    
    return self;
}

- (id) initWithX: (double)x andY: (double)y
{
    self = [super init];
    
    if(self){
        self._x = x;
        self._y = y;
    }
    
    return self;
}

- (id) initWithXYPair: (XYPair*)xy{
    
    self = [super init];
    
    if(self){
        self._x = xy._x;
        self._y = xy._y;
    }
    
    return self;
}


#pragma mark - Printing

- (NSString *)description {
    
    return [NSString stringWithFormat:@"(%.8f,%.8f)",_x,_y];
}


#pragma mark - Distance Calculations

- (double)distanceInX:(XYPair*)xy{
    return xy._x - self._x;
}

- (double)distanceInY:(XYPair*)xy{
    return xy._y - self._y;
}

- (double)distanceInXY:(XYPair*)xy{
    return sqrt( pow([self distanceInX:xy], 2) + pow([self distanceInY:xy], 2));
}

@end
