//
//  SinCosPair.h
//  OnPar2
//
//  Created by Chad Galloway on 2/26/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SinCosPair : NSObject

@property (nonatomic) double _sin;
@property (nonatomic) double _cos;

- (id)init;
- (id)initWithSin: (double)sin andCos: (double)cos;
- (id) initWithXYPair: (SinCosPair*)pair;

#pragma mark - Printing
- (NSString *)description;

@end
