//
//  Hole.h
//  OnPar2
//
//  Created by Kevin R Benton on 2/18/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Round, Shot;

@interface Hole : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * fairway_in_reg;
@property (nonatomic, retain) NSNumber * firstRefLat;
@property (nonatomic, retain) NSNumber * firstRefLong;
@property (nonatomic, retain) NSNumber * firstRefX;
@property (nonatomic, retain) NSNumber * firstRefY;
@property (nonatomic, retain) NSNumber * green_in_reg;
@property (nonatomic, retain) NSNumber * holeNumber;
@property (nonatomic, retain) NSNumber * holeScore;
@property (nonatomic, retain) NSNumber * par;
@property (nonatomic, retain) NSNumber * putts;
@property (nonatomic, retain) NSNumber * secondRefLat;
@property (nonatomic, retain) NSNumber * secondRefLong;
@property (nonatomic, retain) NSNumber * secondRefX;
@property (nonatomic, retain) NSNumber * secondRefY;
@property (nonatomic, retain) Round *round;
@property (nonatomic, retain) NSSet *shots;
@end

@interface Hole (CoreDataGeneratedAccessors)

- (void)addShotsObject:(Shot *)value;
- (void)removeShotsObject:(Shot *)value;
- (void)addShots:(NSSet *)values;
- (void)removeShots:(NSSet *)values;

@end
