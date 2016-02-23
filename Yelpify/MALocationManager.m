//
//  MALocationManager.m
//  Yelpify
//
//  Created by Mark Anderson on 2/22/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import "MALocationManager.h"

@interface MALocationManager() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) CLAuthorizationStatusChangedBlock authStatusChangedBlock;
@property (strong, nonatomic) CLPlacemark *currentPlacemark;

@end

@implementation MALocationManager

#pragma mark - Private Methods

+ (MALocationManager *)sharedInstance {
    static dispatch_once_t onceToken;
    static MALocationManager *locationManager = nil;
    dispatch_once(&onceToken, ^{
        locationManager = [[self alloc] init];
        [locationManager setup];
    });
    return locationManager;
}

- (void)setup {
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyKilometer;
}

#pragma mark - Public Methods

+ (void)beginTrackingUserLocationWithAuthStatusChangedBlock:(CLAuthorizationStatusChangedBlock)authStatusChangedBlock {
    if (![CLLocationManager locationServicesEnabled]) {
        authStatusChangedBlock([CLLocationManager authorizationStatus]);
        return;
    }
    MALocationManager *locationManager = [MALocationManager sharedInstance];
    locationManager.authStatusChangedBlock = authStatusChangedBlock;
    [locationManager.manager requestWhenInUseAuthorization];
}

+ (CLPlacemark *)currentPlacemark {
    return [MALocationManager sharedInstance].currentPlacemark;
}

+ (CLAuthorizationStatus)currentAuthStatus {
    return [CLLocationManager authorizationStatus];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    // This gets called when the app becomes active, despite whether or not the actual permissions changed yet.
    // Therefore, we ignore the kCLAuthorizationStatusNotDetermined state and only call the authStatusChangedBlock
    // when the user has made a decision.
    if (status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    }
    if (self.authStatusChangedBlock) {
        self.authStatusChangedBlock(status);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = locations[0];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    // We only really care about retrieving the initial placemark for a user's location for the purpose of this project
    [manager stopUpdatingLocation];

    __weak typeof(self)weakSelf = self;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) { return; }
        if (!error && placemarks && placemarks.count) {
            strongSelf.currentPlacemark = placemarks[0];
        } else {
            [manager startUpdatingLocation];
        }
    }];
}

@end
