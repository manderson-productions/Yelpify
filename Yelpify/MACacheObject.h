//
//  MACacheObject.h
//  Yelpify
//
//  Created by Mark Anderson on 2/22/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MACacheObject : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString  * _Nonnull key;
@property (nonatomic, strong, readonly) NSPurgeableData  * _Nullable data;

- (instancetype _Nullable)initWithData:(NSPurgeableData * _Nonnull)data forKey:(NSString * _Nonnull)key;

@end
