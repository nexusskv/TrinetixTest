//
//  DataFetcher.m
//  TrinetixTest
//
//  Created by rost on 12.01.15.
//  Copyright (c) 2015 Rost. All rights reserved.
//

#import "DataFetcher.h"
#import <UIKit/UIKit.h>

NSString *const kEntityCity = @"City";

@interface DataFetcher ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end


@implementation DataFetcher

#pragma mark - shared
+ (instancetype)shared
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
#pragma mark -


#pragma mark - fetch / insert cities
- (NSArray *)fetchCities {
    NSArray *valuesArray = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:kEntityCity inManagedObjectContext:self.managedObjectContext]];
    NSArray *fetchedValues = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    if ([fetchedValues count] > 0)
        valuesArray = fetchedValues;
    
    return valuesArray;
}

- (void)saveCities:(NSArray *)array {
    for (NSDictionary *city in array) {
        NSEntityDescription *cityEntity = [NSEntityDescription entityForName:kEntityCity
                                                      inManagedObjectContext:self.managedObjectContext];
        City *newCity = [[City alloc] initWithEntity:cityEntity insertIntoManagedObjectContext:self.managedObjectContext];
        NSNumber *uidNumber         = city[@"uid"];
        NSString *imageString       = city[@"image"];
        NSString *cityString        = city[@"city"];
        NSString *streetString      = city[@"street"];
        NSString *latitudeString    = city[@"latitude"];
        NSString *longitudeString   = city[@"longitude"];
        NSNumber *distNumber        = city[@"distanse"];
        
        if (![uidNumber isKindOfClass:[NSNull class]])
            newCity.uid         = uidNumber;
        
        if ((imageString) && (imageString.length > 0))
            newCity.image       = imageString;
        
        if ((cityString) && (cityString.length > 0))
            newCity.city        = cityString;
        
        if ((streetString) && (streetString.length > 0))
            newCity.street      = streetString;
        
        if ((latitudeString) && ([latitudeString doubleValue] > 0))
            newCity.latitude    = latitudeString;
        
        if ((longitudeString) && ([longitudeString doubleValue] > 0))
            newCity.longitude   = longitudeString;
        
        if (![distNumber isKindOfClass:[NSNull class]])
            newCity.distanse    = distNumber;
    }
    
    [self saveContext];
}

- (void)updateCityWithId:(id)cityUid byValue:(id)newValue {
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityCity inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %f", [(NSNumber *)cityUid doubleValue]];
    [request setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"uid" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];

    NSError *error = nil;
    City *updateCity = [[self.managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0];
    if (updateCity) {
        updateCity.distanse = newValue;
        [self saveContext];
    }
}

- (void)saveContext {
    if (self.managedObjectContext != nil) {
        NSError *error = nil;
        BOOL saveFlag = [self.managedObjectContext save:&error];
        
        if (!saveFlag)
            NSLog(@"City, couldn't save: %@", [error localizedDescription]);
        
        if ([self.managedObjectContext hasChanges] && !saveFlag) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
#pragma mark -


#pragma mark - Core Data
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil)
        return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil)
        return _managedObjectModel;

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TrinetixModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil)
        return _persistentStoreCoordinator;
    
    NSURL *userPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [userPath URLByAppendingPathComponent:@"TrinextixTest.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:@YES forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:@YES forKey:NSInferMappingModelAutomaticallyOption];
    
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error])  {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    return _persistentStoreCoordinator;
}

@end
