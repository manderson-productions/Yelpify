//
//  MARequestBuilder.h
//  Yelpify
//
//  Created by Mark Anderson on 2/21/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MARequestBuilder : NSObject

+ (NSURLRequest *)searchRequestWithOffset:(NSUInteger)offset;
+ (NSURLRequest *)searchRequestWithOffset:(NSUInteger)offset location:(NSString *)location;
+ (NSURLRequest *)searchRequestWithOffset:(NSUInteger)offset
                               location:(NSString *)location
                              rateLimit:(NSUInteger)rateLimit;
@end
