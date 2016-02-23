//
//  MAImageCache.h
//  Yelpify
//
//  Created by Mark Anderson on 2/22/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MAImageCache : NSObject <NSCoding>

+ (MAImageCache * _Nonnull)unarchive;
- (void)archive;

- (UIImage * _Nullable)imageAtIndex:(NSUInteger)index;
- (void)cacheImagesFromURLStrings:(NSArray * _Nonnull)imageURLs
              withCompletionBlock:(void(^ _Nullable)(void))completionBlock;
- (NSUInteger)count;

@end
