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

static NSString *const kCollectionViewCellReuseID = @"CollectionViewCellReuseID";
static NSUInteger const kNumberOfSectionsInCollectionView = 1;
static CGFloat const kPullToRefreshOffset = 100.0;
static CGFloat const kNumCellsPerRow = 3.0;

@interface MAHomeCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *imageCache;
@property (assign, nonatomic) BOOL isRefreshing;

@end

@implementation MAHomeCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupCache];
    [self requestBusinesses];
}

#pragma mark - Setup Methods

- (void)setupCache {
    self.imageCache = [NSMutableArray array];
}

#pragma mark - Custom Methods

- (void)requestBusinesses {
    __weak typeof(self)weakSelf = self;
    [MAActivityIndicatorView show];
    [MANetworkManager searchWithOffset:self.imageCache.count completionBlock:^(NSArray *results, NSError *error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {

            dispatch_group_t dispatchGroup = dispatch_group_create();

            for (NSDictionary *result in results) {
                dispatch_group_enter(dispatchGroup);
                __block NSURL *imageURL = [NSURL URLWithString:result[@"image_url"]];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSPurgeableData *data = [NSPurgeableData dataWithContentsOfURL:imageURL];

                    // TODO: Not threadsafe, put on custom serial queue!!!
                    [strongSelf.imageCache addObject:[UIImage imageWithData:data]];
                    dispatch_group_leave(dispatchGroup);
                });
            }

            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
                strongSelf.isRefreshing = NO;
                [MAActivityIndicatorView hide];
                [strongSelf.collectionView reloadData];
            });
        }
    }];
}

- (BOOL)shouldRefresh:(UIScrollView *)scrollView {
    return !self.isRefreshing &&
            scrollView.contentOffset.y + scrollView.frame.size.height >
            scrollView.contentSize.height + kPullToRefreshOffset;
}

#pragma mark - CollectionView Delegate / Datasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    MABusinessCollectionViewCell *cell = (MABusinessCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseID forIndexPath:indexPath];

    [cell setBusinessImage:self.imageCache[indexPath.row]];

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self shouldRefresh:scrollView]) {
        self.isRefreshing = YES;
        [self requestBusinesses];
    }
}

@end
