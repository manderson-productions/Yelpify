//
//  MAImageCache.m
//  Yelpify
//
//  Created by Mark Anderson on 2/22/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import "MAImageCache.h"
#import "MACacheObject.h"

static NSString * const kCacheKey = @"image_cache";
static NSString * const kCacheFile = @"ImageCache.plist";

@interface MAImageCache()

@property (strong, nonatomic) NSMutableArray <MACacheObject *> *cache;

+ (NSString * _Nonnull)cacheFolder;

@end

@implementation MAImageCache

#pragma mark - NSCoding Protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.cache = [aDecoder decodeObjectForKey:kCacheKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cache forKey:kCacheKey];
}

#pragma mark - Initializer

- (instancetype)init {
    if (self = [super init]) {
        self.cache = [NSMutableArray array];
        return self;
    }
    return nil;
}

#pragma mark - Class Methods

+ (MAImageCache * _Nonnull)unarchive {
    MAImageCache *imageCache = [NSKeyedUnarchiver unarchiveObjectWithFile:[MAImageCache cacheFolder]];
    if (imageCache != nil) {
        return imageCache;
    } else {
        return [[MAImageCache alloc] init];
    }
}

- (void)archive {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSString *filename = [MAImageCache cacheFolder];
    [data writeToFile:filename atomically:YES];
}

+ (NSString *)cacheFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:kCacheFile];
}

#pragma mark - Instance Methods

- (void)cacheImagesFromURLStrings:(NSArray * _Nonnull)imageURLs
              withCompletionBlock:(void(^ _Nullable)(void))completionBlock {

    dispatch_group_t dispatchGroup = dispatch_group_create();

    for (NSURL *imageURL in imageURLs) {
        dispatch_group_enter(dispatchGroup);
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf) {
                NSPurgeableData *data = [NSPurgeableData dataWithContentsOfURL:imageURL];
                [self setImageData:data forKey:imageURL.absoluteString];
                dispatch_group_leave(dispatchGroup);
            }
        });
    }

    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        if (completionBlock) {
            [self archive];
            completionBlock();
        }
    });
}

- (void)setImageData:(NSPurgeableData *)data forKey:(NSString *)key {
    @synchronized(self) {
        MACacheObject *cacheObject = [[MACacheObject alloc] initWithData:data forKey:key];
        if (![self.cache containsObject:cacheObject]) {
            [self.cache addObject:cacheObject];
        } else {
            NSLog(@"Found duplicate");
        }
    }
}

- (UIImage * _Nullable)imageAtIndex:(NSUInteger)index {
    @synchronized(self) {
        MACacheObject *cacheObject = self.cache[index];
        NSData *imageData = (NSData *)cacheObject.data;
        if (imageData) {
            return [UIImage imageWithData:imageData];
        } else {
            return nil;
        }
    }
}

- (NSUInteger)count {
    @synchronized(self) {
        return self.cache.count;
    }
}

@end
