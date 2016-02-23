//
//  MAHomeCollectionViewController.m
//  Yelpify
//
//  Created by Mark Anderson on 2/21/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import "MAHomeCollectionViewController.h"
#import "MANetworkManager.h"
#import "MABusinessCollectionViewCell.h"
#import "Yelpify-Swift.h"
#import "MAImageCache.h"
#import "MALocationManager.h"

static NSString *const kCollectionViewCellReuseID = @"CollectionViewCellReuseID";
static NSUInteger const kNumberOfSectionsInCollectionView = 1;
static CGFloat const kPullToRefreshOffset = 100.0;
static CGFloat const kNumCellsPerRow = 3.0;

@interface MAHomeCollectionViewController ()

@property (strong, nonatomic) MAImageCache *imageCache;
@property (assign, nonatomic) BOOL isRefreshing;

@end

@implementation MAHomeCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupCache];
    [self handleUserLocationAndInitialNetworkRequest];
}

#pragma mark - Setup Methods

- (void)setupCache {
    self.imageCache = [MAImageCache unarchive];
}

- (void)handleUserLocationAndInitialNetworkRequest {
    __weak typeof(self)weakSelf = self;
    [MALocationManager beginTrackingUserLocationWithAuthStatusChangedBlock:^(CLAuthorizationStatus status) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) { return; }

        if (status == kCLAuthorizationStatusDenied) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Yelpify"
                                                                                     message:@"If you would like to see specific \
                                                  businesses in your location, please turn \
                                                  on location services in your settings."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No thanks"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [strongSelf requestBusinesses];
                                                                 }];
            UIAlertAction *openSettingsAction = [UIAlertAction actionWithTitle:@"Take me there"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                                           NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                           if (settingsURL) {
                                                                               [[UIApplication sharedApplication] openURL:settingsURL];
                                                                           }
                                                                       }];
            [alertController addAction:cancelAction];
            [alertController addAction:openSettingsAction];
            [strongSelf presentViewController:alertController animated:YES completion:nil];
        } else {
            [strongSelf requestBusinesses];
        }
    }];
}

#pragma mark - Custom Methods

- (void)requestBusinesses {
    self.isRefreshing = YES;
    [MAActivityIndicatorView show];

    __weak typeof(self)weakSelf = self;
    [MANetworkManager searchWithOffset:self.imageCache.count completionBlock:^(NSArray *results, NSError *error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) { return; }

        void (^cleanup)(BOOL) = ^(BOOL doReloadData) {
            [MAActivityIndicatorView hide];
            if (doReloadData) {
                [strongSelf.collectionView reloadData];
            }
            strongSelf.isRefreshing = NO;
        };

        void (^unexpectedBehavior)(NSString *) = ^(NSString *message) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showAlertControllerWithMessage:message withCompletionBlock:^{
                    cleanup(NO);
                }];
            });
        };

        // Some unexpected behavior occurred; handle it appropriately
        NSString *unexpectedBehaviorMessage = nil;
        if (error) {
            unexpectedBehaviorMessage = error.localizedDescription;
        } else if (!results.count) {
            unexpectedBehaviorMessage = @"We could not find any businesses in your location. Please try again later.";
        }

        // Great success; Filter the results and cache the images from the results
        if (!unexpectedBehaviorMessage) {
            [strongSelf cacheResults:results withCompletionBlock:^{
                cleanup(YES);
            }];
        } else {
            unexpectedBehavior(unexpectedBehaviorMessage);
        }
    }];
}

#pragma mark - Helper Methods

- (void)cacheResults:(NSArray *)results withCompletionBlock:(void(^)(void))completionBlock {
    __block NSMutableArray *imageURLs = [NSMutableArray arrayWithCapacity:results.count];
    [results enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj[@"image_url"]) {
            [imageURLs addObject:[NSURL URLWithString:obj[@"image_url"]]];
        }
    }];
    [self.imageCache cacheImagesFromURLStrings:imageURLs withCompletionBlock:^{
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), completionBlock);
        }
    }];
}

- (BOOL)shouldRefresh:(UIScrollView *)scrollView {
    return !self.isRefreshing &&
            scrollView.contentOffset.y + scrollView.frame.size.height >
            scrollView.contentSize.height + kPullToRefreshOffset;
}

- (void)showAlertControllerWithMessage:(NSString *)message withCompletionBlock:(void(^)(void))completionBlock {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Yelpify"
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             if (completionBlock) {
                                                                 completionBlock();
                                                             }
                                                         }];
    __weak typeof(self)weakSelf = self;
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              __strong typeof(weakSelf)strongSelf = weakSelf;
                                                              if (completionBlock) {
                                                                  completionBlock();
                                                              }
                                                              if (strongSelf) {
                                                                  [strongSelf requestBusinesses];
                                                              }
                                                          }];
    [controller addAction:cancelAction];
    [controller addAction:tryAgainAction];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - CollectionView Delegate / Datasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    MABusinessCollectionViewCell *cell = (MABusinessCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseID forIndexPath:indexPath];

    UIImage *image = [self.imageCache imageAtIndex:indexPath.row];
    if (image) {
        [cell setBusinessImage:image];
    }

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageCache.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kNumberOfSectionsInCollectionView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat widthHeight = collectionView.frame.size.width / kNumCellsPerRow - 10;

    return CGSizeMake(widthHeight, widthHeight);
}

#pragma mark - UIScrollviewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self shouldRefresh:scrollView]) {
        [self requestBusinesses];
    }
}

@end
