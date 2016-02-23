//
//  MACacheObject.m
//  Yelpify
//
//  Created by Mark Anderson on 2/22/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import "MACacheObject.h"

static NSString * const kCacheObjectKey = @"key";
static NSString * const kCacheObjectData = @"data";

@interface MACacheObject()

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSPurgeableData *data;

@end

@implementation MACacheObject

- (instancetype)initWithData:(NSPurgeableData *)data forKey:(NSString *)key {
    if (self = [super init]) {

        self.data = data;
        self.key = key;

        return self;
    }
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {

        self.data = [aDecoder decodeObjectForKey:kCacheObjectData];
        self.key = [aDecoder decodeObjectForKey:kCacheObjectKey];

        return self;
    }
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.data forKey:kCacheObjectData];
    [aCoder encodeObject:self.data forKey:kCacheObjectKey];
}

- (BOOL)isEqual:(id)object {
    return self == object || self.key == [(MACacheObject *)object key];
}

@end
