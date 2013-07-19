//
//  RecentlyViewedPhotos.h
//  SPoT
//
//  Created by Richard Shin on 7/15/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentlyViewedFlickrPhoto : NSObject

// Flickr photo dictionary
@property (strong, nonatomic) NSDictionary *photoDictionary;

// Set automatically when photoDictionary is set
@property (readonly, nonatomic) NSDate *viewed;

 // Saves record to permanent store
- (void)synchronize;

// Returns an array of all recently viewed Flickr photo dictionaries
+ (NSArray *)getAllSortedAscending:(BOOL)ascending;

// Removes all recents
+ (void)clearAll;

@end
