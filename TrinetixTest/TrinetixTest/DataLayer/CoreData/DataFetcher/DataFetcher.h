//
//  DataFetcher.h
//  TrinetixTest
//
//  Created by rost on 12.01.15.
//  Copyright (c) 2015 Rost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "City.h"


@interface DataFetcher : NSObject

+ (instancetype)shared;

- (void)saveCities:(NSArray *)array;
- (NSArray *)fetchCities;
- (void)updateCityWithId:(id)cityUid byValue:(id)newValue;
@end
