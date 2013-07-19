//
//  FlickrPhotoTVC.m
//  Shutterbug
//
//  Created by Richard Shin on 7/14/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "FlickrPhotoTVC.h"
#import "FlickrFetcher.h"
#import "RecentlyViewedFlickrPhoto.h"

@interface FlickrPhotoTVC ()

@end

@implementation FlickrPhotoTVC

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self.tableView reloadData];
}

- (NSString *)cellIdentifier {
    return @""; // abstract
}

- (NSString *)imageViewSegueIdentifier {
    return @""; // abstract
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

// Provides title for table cell
- (NSString *)titleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_TITLE] description];
}

// Provides subtitle for table cell
- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [[self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
}

// Returns the URL for the table view's cell's image photo. Can be overridden to provide a different photo
- (NSURL *)imageURLForRow:(NSUInteger)row
{
    return [FlickrFetcher urlForPhoto:self.photos[0] format:FlickrPhotoFormatSquare];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];

    // Get square image
    NSData *data = [[NSData alloc] initWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatSquare]];
    UIImage *image = [[UIImage alloc] initWithData:data];
    cell.imageView.image = image;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![sender isKindOfClass:[UITableViewCell class]]) return;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    // Validate index path (index path can be nil if invalid)
    if (indexPath) {
        // Validate that this is the right segue
        if ([segue.identifier isEqualToString:self.imageViewSegueIdentifier]) {
            // We make no assumptions about the class type of the destination controller, only that it responds
            // to the selector setImageURL
            if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                NSURL *url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
                [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                
                RecentlyViewedFlickrPhoto *rvfp = [[RecentlyViewedFlickrPhoto alloc] init];
                rvfp.photoDictionary = self.photos[indexPath.row];
                [rvfp synchronize];
            }
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
