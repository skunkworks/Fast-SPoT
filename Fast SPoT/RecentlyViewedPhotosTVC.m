//
//  RecentlyViewedPhotosTVC.m
//  SPoT
//
//  Created by Richard Shin on 7/15/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "RecentlyViewedPhotosTVC.h"
#import "RecentlyViewedFlickrPhotos.h"

@interface RecentlyViewedPhotosTVC ()
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
    NSArray *sortedPhotos = [[RecentlyViewedFlickrPhotos sharedInstance] allPhotosSortedAscending:NO];
    self.photos = sortedPhotos;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateModel];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    NSArray *previousRecentlyViewedPhotos = self.photos;
    [self updateModel];
    
    // We need to animate updates to the recently viewed photo list as the user views the recent photos
    [self.tableView beginUpdates];
    
    for (int i = 0; i < self.photos.count; i++)
    {
        id previousPhoto = previousRecentlyViewedPhotos[i];
        // newRow will get the new row of an object.  i is the old row.
        int newRow = [self.photos indexOfObject:previousPhoto];
        if (newRow != NSNotFound) {
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newRow inSection:0]];
        }
    }
    
    
    [self.tableView endUpdates];
}

@end
