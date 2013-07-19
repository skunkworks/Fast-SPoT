//
//  RecentlyViewedPhotosTVC.m
//  SPoT
//
//  Created by Richard Shin on 7/15/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "RecentlyViewedPhotosTVC.h"
#import "RecentlyViewedFlickrPhoto.h"

@interface RecentlyViewedPhotosTVC ()
@property (strong, nonatomic) NSArray *recentlyViewedPhotos;
@end

@implementation RecentlyViewedPhotosTVC

// Must be overridden. Contains the reuse identifier of the table view's cell
- (NSString *)cellIdentifier {
    return @"Recently Viewed Photo";
}

- (NSString *)imageViewSegueIdentifier {
    return @"Show Recent Photo";
}

- (void)updateModel
{
    self.recentlyViewedPhotos = [RecentlyViewedFlickrPhoto getAllSortedAscending:NO];
    // Converts between our model recentlyViewedPhotos and the model necessary to display data in our superclass FlickrPhotoTVC
    self.photos = [self.recentlyViewedPhotos valueForKeyPath:@"photoDictionary"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateModel];
}

@end
