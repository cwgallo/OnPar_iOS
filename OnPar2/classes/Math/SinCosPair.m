//
//  SinCosPair.m
//  OnPar2
//
//  Created by Chad Galloway on 2/26/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "SinCosPair.h"

@implementation SinCosPair

@synthesize _sin, _cos;

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self._sin = 0;
        self._cos = 0;
    }
    
    return self;
}

- (id)initWithSin: (double)sin andCos: (double)cos
{
    self = [super init];
    
    if(self)
    {
        self._sin = sin;
        self._cos = cos;
    }
    
    return self;
}

- (id) initWithSinCosPair: (SinCosPair*)pair
{    
    self = [super init];
    
    if(self){
        self._sin = pair._sin;
        self._cos = pair._cos;
    }
    
    return self;
}


#pragma mark - Printing

- (NSString *)description {
    
    return [NSString stringWithFormat:@"(Sin: %.8f, Cos: %.8f)",_sin,_cos];
}


@end
