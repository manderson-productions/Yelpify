//
//  MALocationManager.h
//  Yelpify
//
//  Created by Mark Anderson on 2/22/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^CLAuthorizationStatusChangedBlock)(CLAuthorizationStatus);

@interface MALocationManager : NSObject

+ (void)beginTrackingUserLocationWithAuthStatusChangedBlock:(CLAuthorizationStatusChangedBlock _Nullable)authStatusChangedBlock;
+ (CLPlacemark * _Nullable)currentPlacemark;
+ (CLAuthorizationStatus)currentAuthStatus;

@end
