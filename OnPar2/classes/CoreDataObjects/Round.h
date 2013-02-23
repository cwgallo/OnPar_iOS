//
//  Round.h
//  OnPar2
//
//  Created by Kevin R Benton on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hole;

@interface Round : NSManagedObject

@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSNumber * courseID;
@property (nonatomic, retain) NSNumber * teeID;
@property (nonatomic, retain) NSNumber * totalScore;
@property (nonatomic, retain) NSString * startTime;
@property (nonatomic, retain) NSSet *holes;
@end

@interface Round (CoreDataGeneratedAccessors)

- (void)addHolesObject:(Hole *)value;
- (void)removeHolesObject:(Hole *)value;
- (void)addHoles:(NSSet *)values;
- (void)removeHoles:(NSSet *)values;

@end
