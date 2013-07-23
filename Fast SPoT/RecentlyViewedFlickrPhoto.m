//
//  RecentlyViewedPhotos.m
//  SPoT
//
//  Created by Richard Shin on 7/15/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "RecentlyViewedFlickrPhoto.h"
#import "FlickrFetcher.h"

@interface RecentlyViewedFlickrPhoto ()
@property (readwrite, nonatomic) NSDate *viewed;
@end

@implementation RecentlyViewedFlickrPhoto

#define RECENT_PHOTO_DICTIONARY @"Photo_Dictionary"
#define RECENT_PHOTO_VIEW_DATE @"Photo_ViewedDate"

- (void)setPhotoDictionary:(NSDictionary *)photoDictionary {
    // We add the viewed date as an entry in the photo dictionary
    _photoDictionary = photoDictionary;
    _viewed = [NSDate date];
}

// Non-designated initializer meant to convert a property list into an instance of RecentlyViewedFlickrPhoto
- (id)initFromPropertyList:(id)plist
{
    self = [self init];
    
    if (self) {
        if ([plist isKindOfClass:[NSDictionary class]]) {
            NSDictionary *plistDictionary = (NSDictionary *)plist;
            _photoDictionary = plistDictionary[RECENT_PHOTO_DICTIONARY];
            _viewed = plistDictionary[RECENT_PHOTO_VIEW_DATE];
            if (!_photoDictionary || !_viewed) self = nil;
        }
    }
    
    return self;
}

// Used to convert instances of RecentlyViewedFlickrPhoto into a property list. Use initFromPropertyList: to reverse this
- (id)asPropertyList
{
    return @{RECENT_PHOTO_VIEW_DATE : self.viewed, RECENT_PHOTO_DICTIONARY : self.photoDictionary};
}

// Print a nice representation of this record for debugging purposes
- (NSString *)description
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    return [NSString stringWithFormat:@"Photo '%@' at %@", self.photoDictionary[FLICKR_PHOTO_TITLE], self.viewed];
}

@end
