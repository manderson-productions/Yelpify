//
//  MANetworkManager.h
//  Yelpify
//
//  Created by Mark Anderson on 2/21/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APIResultsBlock)(NSArray <NSDictionary <NSString *, NSObject *> *> *results, NSError *error);

@interface MANetworkManager : NSObject

+ (void)searchWithOffset:(NSUInteger)offset completionBlock:(APIResultsBlock)completionBlock;

- (instancetype)init __attribute__((unavailable("Use +searchWithOffset instead.")));

@end
