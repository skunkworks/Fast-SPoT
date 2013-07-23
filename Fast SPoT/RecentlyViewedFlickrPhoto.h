//
//  RecentlyViewedPhotos.h
//  SPoT
//
//  Created by Richard Shin on 7/15/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentlyViewedFlickrPhoto : NSObject

- (id)initFromPropertyList:(id)plist;

- (id)asPropertyList;

// Flickr photo dictionary
@property (strong, nonatomic) NSDictionary *photoDictionary;

// Set automatically when photoDictionary is set
@property (readonly, nonatomic) NSDate *viewed;

@end
