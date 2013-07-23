//
//  RecentlyViewedFlickrPhotos.m
//  Fast SPoT
//
//  Created by Richard Shin on 7/22/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "RecentlyViewedFlickrPhotos.h"
#import "RecentlyViewedFlickrPhoto.h"
#import "FlickrFetcher.h"

@interface RecentlyViewedFlickrPhotos ()

// Key: NSString *photoId, Value: RecentlyViewedFlickrPhoto *rvfp
@property (strong, nonatomic) NSMutableDictionary *photoDictionary;

@end

@implementation RecentlyViewedFlickrPhotos

#define RECENTLY_VIEWED_PHOTOS_KEY @"RecentlyViewedFlickrPhotos_All"
#define MAX_RECENTLY_VIEWED_PHOTOS 10

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

- (NSMutableDictionary *)photoDictionary {
    if (!_photoDictionary) _photoDictionary = [[NSMutableDictionary alloc] init];
    return _photoDictionary;
}

+ (RecentlyViewedFlickrPhotos *)sharedInstance {
    static RecentlyViewedFlickrPhotos *sharedInstance;
    
    @synchronized(self) {
        if (!sharedInstance) sharedInstance = [[RecentlyViewedFlickrPhotos alloc] init];
        return sharedInstance;
    }
}

- (id)init {
    self = [super init];
    
    NSDictionary *userDefaultsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:RECENTLY_VIEWED_PHOTOS_KEY];
    
    if ([userDefaultsDictionary count]) {
        for (id key in [userDefaultsDictionary allKeys]) {
            id plist = userDefaultsDictionary[key];
            RecentlyViewedFlickrPhoto *rvfp = [[RecentlyViewedFlickrPhoto alloc] initFromPropertyList:plist];
            if (rvfp) {
                self.photoDictionary[key] = rvfp;
            }
        }
    }
    
    return self;
}

- (void)addPhoto:(NSDictionary *)photo
{
    NSString *photoId = photo[FLICKR_PHOTO_ID];
    
    RecentlyViewedFlickrPhoto *rvfp = self.photoDictionary[photoId];
    if (!rvfp) rvfp = [[RecentlyViewedFlickrPhoto alloc] init];
    rvfp.photoDictionary = photo;
    
    @synchronized(self) {
        NSMutableDictionary *userDefaultsDictionary = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:RECENTLY_VIEWED_PHOTOS_KEY] mutableCopy];
        if (!userDefaultsDictionary) userDefaultsDictionary = [[NSMutableDictionary alloc] init];
        
        // Add/update
        self.photoDictionary[photoId] = rvfp;
        userDefaultsDictionary[photoId] = [rvfp asPropertyList];

        // Remove if past capacity
        while ([self.photoDictionary count] > MAX_RECENTLY_VIEWED_PHOTOS) {
            RecentlyViewedFlickrPhoto *leastRecentlyViewed = [self popLeastRecentlyViewed];
            [userDefaultsDictionary removeObjectForKey:leastRecentlyViewed.photoDictionary[FLICKR_PHOTO_ID]];
        }
        
        // Push changes to store -- must use synchronize, otherwise it may not propagate to store properly in cases where app is terminated through XCode
        [[NSUserDefaults standardUserDefaults] setObject:userDefaultsDictionary forKey:RECENTLY_VIEWED_PHOTOS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (RecentlyViewedFlickrPhoto *)popLeastRecentlyViewed
{
    id leastRecentlyViewedKey = nil;
    
    NSDate *earliest = [NSDate date];
    for (id key in [self.photoDictionary allKeys]) {
        NSDate *viewed = ((RecentlyViewedFlickrPhoto *)self.photoDictionary[key]).viewed;
        if ([viewed compare:earliest] == NSOrderedAscending) {
            earliest = viewed;
            leastRecentlyViewedKey = key;
        }
    }
    
    RecentlyViewedFlickrPhoto *rvfp = self.photoDictionary[leastRecentlyViewedKey];
    [self.photoDictionary removeObjectForKey:leastRecentlyViewedKey];
    return rvfp;
}
               
               

- (NSArray *)allPhotosSortedAscending:(BOOL)ascending
{
    NSArray *sortedArray = [[self.photoDictionary allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        RecentlyViewedFlickrPhoto *rvfp1 = (RecentlyViewedFlickrPhoto *)obj1;
        RecentlyViewedFlickrPhoto *rvfp2 = (RecentlyViewedFlickrPhoto *)obj2;
        if (ascending) return [rvfp1.viewed compare:rvfp2.viewed];
        else           return [rvfp2.viewed compare:rvfp1.viewed];
    }];
    return [sortedArray valueForKey:@"photoDictionary"];
}

@end
