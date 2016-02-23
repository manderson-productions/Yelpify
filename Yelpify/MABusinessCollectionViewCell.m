//
//  MABusinessCollectionViewCell.m
//  Yelpify
//
//  Created by Mark Anderson on 2/21/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

#import "MABusinessCollectionViewCell.h"

@interface MABusinessCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *businessImageView;

@end

@implementation MABusinessCollectionViewCell

- (void)awakeFromNib {
    self.businessImageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - Public Methods

- (void)setBusinessImage:(UIImage *)businessImage {
    self.businessImageView.image = businessImage;
}

@end
