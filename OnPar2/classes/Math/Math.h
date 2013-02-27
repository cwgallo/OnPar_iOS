//
//  Math.h
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPair.h"
#import "XYPair.h"
#import "SinCosPair.h"

@interface Math : NSObject

- (id)init;

- (LLPair *)getLatLonFromSelectedXY: (XYPair*)selectedXY FromImageView: (UIImageView*)imageView OnHole: (Hole*)currentHole;

@end
