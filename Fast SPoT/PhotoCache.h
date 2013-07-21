//
//  PhotoCache.h
//  Fast SPoT
//
//  Created by Richard Shin on 7/20/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCache : NSObject

+ (PhotoCache *)sharedInstance;

@property (nonatomic) NSUInteger capacity;

- (void)addPhoto:(UIImage *)photo fromURL:(NSURL *)url;

- (UIImage *)retrievePhotoForURL:(NSURL *)url;

- (void)clear;
@end
