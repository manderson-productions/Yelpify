//
//  MARequestBuilder.m
//  Yelpify
//
//  Created by Mark Anderson on 2/21/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import "MARequestBuilder.h"
#import <TDOAuth/TDOAuth.h>

static NSString * const kConsumerKey = @"9iGKraKub2xJy5bTTsNyjg";
static NSString * const kConsumerSecret = @"NS-BECfkQxWOdmJr89nORy7nlxY";
static NSString * const kToken = @"TKA2Qf39NPufCzuPP7OisYR2_5qjP5vF";
static NSString * const kTokenSecret = @"jjJlPqgA-yzpTezbg2_zFt53TgM";
static NSUInteger const kDefaultRateLimit = 18;
static NSString * const kDefaultLocation = @"Brooklyn";

static NSString * const kAPIHost = @"api.yelp.com";
static NSString * const kSearchAPIPath = @"/v2/search/";
static NSString * const kHTTPSScheme = @"https";

@implementation MARequestBuilder

+ (NSURLRequest *)searchRequestWithOffset:(NSUInteger)offset {
    return [MARequestBuilder searchRequestWithOffset:offset location:kDefaultLocation];
}

+ (NSURLRequest *)searchRequestWithOffset:(NSUInteger)offset location:(NSString *)location {
    return [MARequestBuilder searchRequestWithOffset:offset location:location rateLimit:kDefaultRateLimit];
}

+ (NSURLRequest *)searchRequestWithOffset:(NSUInteger)offset
                                 location:(NSString *)location
                                rateLimit:(NSUInteger)rateLimit {
    NSDictionary *params = @{@"offset": @(offset), @"location": location, @"rateLimit": @(rateLimit)};
    return [TDOAuth URLRequestForPath:kSearchAPIPath
                        GETParameters:params
                               scheme:kHTTPSScheme
                                 host:kAPIHost
                          consumerKey:kConsumerKey
                       consumerSecret:kConsumerSecret
                          accessToken:kToken
                          tokenSecret:kTokenSecret];
}

@end
