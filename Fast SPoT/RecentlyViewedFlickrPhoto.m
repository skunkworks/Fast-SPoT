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

#define RECENTLY_VIEWED_PHOTOS @"RecentlyViewedFlickrPhotos_All"
#define RECENT_PHOTO_DICTIONARY @"Photo_Dictionary"
#define RECENT_PHOTO_VIEW_DATE @"Photo_ViewedDate"
#define MAX_RECENT_PHOTOS 10

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

// Print a nice representation of this record for debugging purposes
- (NSString *)description
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    return [NSString stringWithFormat:@"Photo ID %@ at %@", self.photoDictionary[FLICKR_PHOTO_ID], self.viewed];
}

// Used to convert instances of RecentlyViewedFlickrPhoto into a property list. Use initFromPropertyList: to reverse this
- (id)asPropertyList
{
    return @{RECENT_PHOTO_VIEW_DATE : self.viewed, RECENT_PHOTO_DICTIONARY : self.photoDictionary};
}

// Store record in permanent store
/* Note: when we store our records in the user defaults, this is the format:
    
[NSUserDefaults standardUserDefaults] dictionaryForKey:[RECENTLY_VIEWED_PHOTOS_KEY]] = NSDictionary *userSettingsDictionary
    -> userSettingsDictionary[NSString *photoId] = id plist = NSDictionary *plistDictionary
        -> plistDictionary[RECENT_PHOTO_VIEW_DATE_KEY] = NSDate *viewed
        -> plistDictionary[RECENT_PHOTO_DICTIONARY_KEY] = NSDictionary *photoDictionary
    -> userSettingsDictionary[NSString *photoId] = id plist = NSDictionary *plistDictionary
        -> plistDictionary[RECENT_PHOTO_VIEW_DATE_KEY] = NSDate *viewed
        -> plistDictionary[RECENT_PHOTO_DICTIONARY_KEY] = NSDictionary *photoDictionary
    -> etc.

*/
- (void)synchronize
{
    // Get our records from permanent store (or make a fresh dictionary if none found)
    NSMutableDictionary *mutableUserSettingsDictionary = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:RECENTLY_VIEWED_PHOTOS] mutableCopy];
    if (!mutableUserSettingsDictionary) mutableUserSettingsDictionary = [[NSMutableDictionary alloc] init];
    
    // Add this record to the dictionary (or update if it already exists)
    mutableUserSettingsDictionary[self.photoDictionary[FLICKR_PHOTO_ID]] = [self asPropertyList];
    
    // Prune earliest record if we've reached max recently viewed photo records
    while ([mutableUserSettingsDictionary count] > MAX_RECENT_PHOTOS) {

        // Have to iterate through all records and find the earliest photo record to pop
        NSString *idOfEarliestPhoto = self.photoDictionary[FLICKR_PHOTO_ID];
        NSDate *earliestDate = self.viewed;
        
        for (id key in [mutableUserSettingsDictionary allKeys]) {
            NSDictionary *plistDictionary = (NSDictionary *)mutableUserSettingsDictionary[key];
            NSDate *photoDate = plistDictionary[RECENT_PHOTO_VIEW_DATE];
            if ([photoDate compare:earliestDate] == NSOrderedAscending) {
                idOfEarliestPhoto = key;
                earliestDate = photoDate;
            }
        }
        
        [mutableUserSettingsDictionary removeObjectForKey:idOfEarliestPhoto];
    }
    
    // Propagate any modifications to the permanent store
    [[NSUserDefaults standardUserDefaults] setObject:mutableUserSettingsDictionary forKey:RECENTLY_VIEWED_PHOTOS];
}

// Returns an NSArray of all recently viewed photos
+ (NSArray *)getAllSortedAscending:(BOOL)ascending
{
    NSDictionary *userSettingsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:RECENTLY_VIEWED_PHOTOS];

    // Build an array of all the recently viewed photos from user settings
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (id plist in [userSettingsDictionary allValues]) {
        RecentlyViewedFlickrPhoto *rvfp = [[RecentlyViewedFlickrPhoto alloc] initFromPropertyList:plist];
        if (rvfp) [mutableArray addObject:rvfp];
    }
    [mutableArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        RecentlyViewedFlickrPhoto *rvfp1 = (RecentlyViewedFlickrPhoto *)obj1;
        RecentlyViewedFlickrPhoto *rvfp2 = (RecentlyViewedFlickrPhoto *)obj2;
        if (ascending) return [rvfp1.viewed compare:rvfp2.viewed];
        else return [rvfp2.viewed compare:rvfp1.viewed];
    }];
    
    return [mutableArray copy];
}

+ (void)clearAll
{
    [[NSUserDefaults standardUserDefaults] setObject:[[NSDictionary alloc] init] forKey:RECENTLY_VIEWED_PHOTOS];
}

@end
