//
//  StanfordPhotosDetailedTVC.m
//  SPoT
//
//  Created by Richard Shin on 7/16/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "StanfordPhotosDetailedTVC.h"
#import "FlickrFetcher.h"

@interface StanfordPhotosDetailedTVC ()

@end

@implementation StanfordPhotosDetailedTVC

@synthesize photos = _photos;
- (void)setPhotos:(NSArray *)photos {
    _photos = [photos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *obj1Dictionary = (NSDictionary *)obj1;
        NSDictionary *obj2Dictionary = (NSDictionary *)obj2;
        return [(obj1Dictionary[FLICKR_PHOTO_TITLE]) compare:obj2Dictionary[FLICKR_PHOTO_TITLE]];
    }
    ];
}

- (NSString *)cellIdentifier {
    return @"Stanford Tagged Photo";
}

- (NSString *)imageViewSegueIdentifier {
    return @"Show Stanford Tagged Photo";
}

@end
