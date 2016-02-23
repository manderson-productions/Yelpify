//
//  MANetworkManager.m
//  Yelpify
//
//  Created by Mark Anderson on 2/21/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import "MANetworkManager.h"
#import "MARequestBuilder.h"
#import "MALocationManager.h"

@implementation MANetworkManager

+ (MANetworkManager *)sharedInstance {
    static dispatch_once_t onceToken;
    static MANetworkManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager setup];
    });
    return manager;
}

- (void)setup {

}

#pragma mark - Class Methods

+ (void)searchWithOffset:(NSUInteger)offset completionBlock:(APIResultsBlock)completionBlock {
    // Get the locality for the user if one is available. Otherwise, sending nil will defer to the
    // default location with which to search local businesses
    CLPlacemark *currentPlacemark = [MALocationManager currentPlacemark];
    NSString *locality = nil;
    if (currentPlacemark) {
        locality = currentPlacemark.locality;
    }
    NSURLRequest *request = [MARequestBuilder searchRequestWithOffset:offset location:locality];

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (!error && httpResponse.statusCode == 200) {

            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSArray *businessArray = searchResponseJSON[@"businesses"];
            completionBlock(businessArray, nil);
        } else {
            completionBlock(nil, error);
        }
    }] resume];
}

@end
