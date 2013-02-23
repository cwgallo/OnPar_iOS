//
//  Shot.h
//  OnPar2
//
//  Created by Kevin R Benton on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hole;

@interface Shot : NSManagedObject

@property (nonatomic, retain) NSNumber * club;
@property (nonatomic, retain) NSNumber * shotNumber;
@property (nonatomic, retain) NSNumber * aimLatitude;
@property (nonatomic, retain) NSNumber * aimLongitude;
@property (nonatomic, retain) NSNumber * startLatitude;
@property (nonatomic, retain) NSNumber * startLongitude;
@property (nonatomic, retain) NSNumber * endLatitude;
@property (nonatomic, retain) NSNumber * endLongitude;
@property (nonatomic, retain) Hole *hole;

@end
