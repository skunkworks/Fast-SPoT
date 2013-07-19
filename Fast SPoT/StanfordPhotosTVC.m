//
//  StanfordPhotosTVC.m
//  SPoT
//
//  Created by Richard Shin on 7/15/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "StanfordPhotosTVC.h"
#import "FlickrFetcher.h"

@interface StanfordPhotosTVC ()
@property (strong, nonatomic) NSMutableDictionary *tags; // Key = NSString, Value = NSArray of NSDictionary
@property (strong, nonatomic) NSArray *rowTags; // of NSString
@end

@implementation StanfordPhotosTVC

@synthesize photos = _photos;

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    // Any time photos gets updated, we need to update tags as well
    _tags = nil;
    [self.tableView reloadData];
}

- (NSString *)cellIdentifier {
    return @"Stanford Photos Grouped By Tag";
}

// Key is the tag name, value is an array of Flickr photo metadata (as NSDictionary objects)
- (NSDictionary *)tags {
    if (!_tags) {
        _tags = [[NSMutableDictionary alloc] init];

        // self.photo is an NSArray of NSDictionary. We want to parse this and sort it by tag name
        for (id item in self.photos) {
            NSDictionary *photoDictionary = (NSDictionary *)item;
            NSArray *tokenizedTags = [photoDictionary[FLICKR_TAGS] componentsSeparatedByString:@" "];
            
            for (NSString *tag in tokenizedTags) {
                if (!_tags[tag]) {
                    [_tags setValue:@[photoDictionary] forKey:tag];
                }
                else
                {
                    _tags[tag] = [_tags[tag] arrayByAddingObject:photoDictionary];
                }
            }
        }
        
        // We have to use a separate array to keep track of which tag corresponds to which row. We can't rely on
        // using the allKeys method of tags because NSDictionary doesn't guarantee that it will return the same order
        // each time it's invoked.
        _rowTags = [[self.tags allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return ([(NSString *)obj1 compare:(NSString *)obj2 options:NSOrderedAscending]);
        }];
    }
    return _tags;
}

// Tag name, capitalized
- (NSString *)titleForRow:(NSUInteger)row
{
    return [[self.rowTags[row] description] capitalizedString];
}

// Number of photos with this tag
- (NSString *)subtitleForRow:(NSUInteger)row
{
    NSString *tagName = self.rowTags[row];
    return [NSString stringWithFormat:@"%d photos", [self.tags[tagName] count]];
}

// Gives the URL for a cell's image
- (NSURL *)imageURLForRow:(NSUInteger)row
{
    NSString *tagName = self.rowTags[row];
    return [FlickrFetcher urlForPhoto:self.tags[tagName][0] format:FlickrPhotoFormatSquare];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

- (void)viewDidLoad
{
    self.photos = [FlickrFetcher stanfordPhotos];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the index path of the cell that pushed the segue and make sure that the cell index path is valid
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (indexPath) {
        // Make sure we have the right segue
        if ([segue.identifier isEqualToString:@"Show Stanford Tagged Photos Detailed"]) {
            // And finally set the photos that we want to display (i.e. photos with this tag)
            if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                NSString *tagName = self.rowTags[indexPath.row];
                NSArray *photosForTag = self.tags[tagName];
                [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:photosForTag];
                [segue.destinationViewController setTitle:[tagName capitalizedString]];
            }
        }
    }
}

@end
