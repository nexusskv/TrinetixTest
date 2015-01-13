//
//  CitiesViewController.m
//  TrinetixTest
//
//  Created by rost on 12.01.15.
//  Copyright (c) 2015 Rost. All rights reserved.
//

#import "CitiesViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DataLoader.h"
#import "DataFetcher.h"
#import "CityCustomCell.h"


@interface CitiesViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UITableView *citiesTable;
@property (nonatomic, strong) NSArray *citiesArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL pullDownToRefreshFlag;
@property (nonatomic, strong) UISearchBar *searchBar;
@end


@implementation CitiesViewController


#pragma mark - View life cycle
- (void)loadView {
    [super loadView];
    
    self.title = @"Cities";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
 
    
    self.citiesTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.citiesTable.delegate = self;
    self.citiesTable.dataSource = self;
    self.citiesTable.contentInset = UIEdgeInsetsMake(5.0f, 0.0f, 6.0f, 0.0f);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Update location."];
    [self.refreshControl addTarget:self action:@selector(refreshControlSelector:) forControlEvents:UIControlEventValueChanged];
    [self.citiesTable addSubview:self.refreshControl];
    [self.view addSubview:self.citiesTable];
    
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Please add filter by city";
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.barStyle                 = UIBarStyleDefault;
    self.searchBar.barTintColor = [UIColor colorWithRed:232.0f/255.0f green:218.0f/255.0f blue:186.0f/255.0f alpha:1.0f];
    self.searchBar.showsCancelButton = YES;
    [self.view addSubview:self.searchBar];

    self.citiesTable.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"tableView"   : self.citiesTable};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(44)-[tableView]|"
                                                                      options:0
                                                                      metrics:nil                                                                        views:views]];
    
    if ([[[DataFetcher shared] fetchCities] count] > 0)
        self.citiesArray = [[DataFetcher shared] fetchCities];
    else
        [self getCities];
    
    self.pullDownToRefreshFlag = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect searchRect = CGRectZero;
    searchRect.size.width = self.view.bounds.size.width;
    searchRect.size.height = 44.0f;
    self.searchBar.frame = searchRect;
}
#pragma mark -


#pragma mark - TableView dataSource & delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Pull down to refresh location.";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.citiesArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(CityCustomCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *colorView = [[UIView alloc] initWithFrame:cell.frame];
    colorView.backgroundColor = [UIColor colorWithRed:252.0f/255.0f green:252.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    cell.backgroundView = colorView;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    City *city = self.citiesArray[indexPath.row];
   
    [cell setCityImage:city.image];
    [cell setCity:city.city];
    [cell setStreet:city.street];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";

    CityCustomCell *cell = (CityCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[CityCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark -


#pragma mark - CoreLocation delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (newLocation) {
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude
                                                                 longitude:newLocation.coordinate.longitude];
        for (City *city in self.citiesArray) {            
            CLLocation *cityLocation = [[CLLocation alloc] initWithLatitude:[city.latitude doubleValue]
                                                                  longitude:[city.longitude doubleValue]];
            CLLocationDistance meters = [cityLocation distanceFromLocation:currentLocation];
            
            [[DataFetcher shared] updateCityWithId:city.uid byValue:@(meters)];
        }
        
        [self sortFreshCities];
    }
    
    [self.locationManager stopUpdatingLocation];
    
    if (self.pullDownToRefreshFlag)
        [self hideRefreshIndicator];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
    
    [self showMessage:@"Please enable current location \n in settings on your simulator or device."
            withTitle:@"Current location error!"];
}
#pragma mark -


#pragma mark - SearchBar delegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        if (searchBar.text.length > 1) {
            NSArray *filteredCities = [self filterCities:self.citiesArray byEnteredCity:searchBar.text];
            
            if ([filteredCities count] > 0) {
                self.citiesArray = filteredCities;
                [self sortFreshCities];
            } else {
                [self loadValuesFromDB];
            }
        }
    } else {
        [self loadValuesFromDB];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self loadValuesFromDB];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}
#pragma mark -


#pragma mark - getCities
- (void)getCities {
    DataLoader *dataLoader = [[DataLoader alloc] initWithCallback:^(id resultObject) {
        
        if ([(NSNumber *)resultObject boolValue])
            [self loadValuesFromDB];
    }];
    
    [dataLoader loadData];
}
#pragma mark - 


#pragma mark - loadValuesFromDB
- (void)loadValuesFromDB {
    self.citiesArray = nil;
    self.citiesArray = [[DataFetcher shared] fetchCities];
    
    if ([self.citiesArray count] > 0)
        [self.citiesTable reloadData];
}
#pragma mark -


#pragma mark - refreshControl
- (void)refreshControlSelector:(id)sender {
    [self.locationManager startUpdatingLocation];
    self.pullDownToRefreshFlag = YES;
}

- (void)hideRefreshIndicator {
    [self.refreshControl endRefreshing];
    self.pullDownToRefreshFlag = NO;
}
#pragma mark -


#pragma mark - sortFreshCities
- (void)sortFreshCities {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"distanse"  ascending:YES];
    self.citiesArray = [self.citiesArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    
    [self.citiesTable reloadData];
}
#pragma mark -


#pragma mark - filterCities:byEnteredCity:
- (NSArray *)filterCities:(NSArray *)cities byEnteredCity:(NSString *)city {
    NSMutableArray *filterResultCities = [NSMutableArray array];
    
    for (City *filterCity in cities) {
        NSRange cityRange  = [filterCity.city rangeOfString:city options:(NSCaseInsensitiveSearch)];
        
        if (cityRange.location != NSNotFound)
            [filterResultCities addObject:filterCity];
    }
    
    return filterResultCities;
}
#pragma mark -


#pragma mark - showMessage:withTitle:
- (void)showMessage:(NSString *)message withTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}
#pragma mark -

@end
