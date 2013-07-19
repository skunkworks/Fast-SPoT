//
//  StanfordPhotosDetailedTVC.m
//  SPoT
//
//  Created by Richard Shin on 7/16/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "StanfordPhotosDetailedTVC.h"

@interface StanfordPhotosDetailedTVC ()

@end

@implementation StanfordPhotosDetailedTVC

- (NSString *)cellIdentifier {
    return @"Stanford Tagged Photo";
}

- (NSString *)imageViewSegueIdentifier {
    return @"Show Stanford Tagged Photo";
}

@end
