//
//  City.h
//  TrinetixTest
//
//  Created by rost on 12.01.15.
//  Copyright (c) 2015 Rost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface City : NSManagedObject

@property (nonatomic, strong) NSNumber *uid;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSNumber *distanse;

@end
