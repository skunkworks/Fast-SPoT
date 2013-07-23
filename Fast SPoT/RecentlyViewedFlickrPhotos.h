//
//  RecentlyViewedFlickrPhotos.h
//  Fast SPoT
//
//  Created by Richard Shin on 7/22/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentlyViewedFlickrPhotos : NSObject

+ (RecentlyViewedFlickrPhotos *)sharedInstance;

- (void)addPhoto:(NSDictionary *)photo;

// Returns NSArray of NSDictionary
- (NSArray *)allPhotosSortedAscending:(BOOL)ascending;

@end
