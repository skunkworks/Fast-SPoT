//
//  ImageViewController.m
//  Shutterbug
//
//  Created by Richard Shin on 7/14/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation ImageViewController
- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [self resetImage];
}

- (UIImageView *)imageView {
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = .2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        // Grab image data from URL. Do this with a serial dispatch queue
        NSURL *imageURL = self.imageURL;
        [self.activityIndicator startAnimating];
        
        dispatch_queue_t imageQ = dispatch_queue_create("Image queue", NULL);
        dispatch_async(imageQ, ^{
            // Simulate network latency
            [NSThread sleepForTimeInterval:2];
            
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            // Successfully pulled image. Check that user hasn't chosen another image URL before displaying
            if (self.imageURL == imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        [self fitImageToWindow];
                    }
                    [self.activityIndicator stopAnimating];
                });
            }
        });
    }
}

// Readjust our zoom scale so that the image view fits as much as possible in the scroll view
- (void)fitImageToWindow
{
    // Logic:
    // 1. Find the scroll view's dimension ratio (width/height).
    //    2. If the photo's width/height ratio is lesser -- photo is relatively taller than the scroll view -- fit by height.
    //    3. If the photo's ratio is higher -- photo is relatively wider than scroll view -- fit by width.
    CGFloat scrollViewRatio = self.scrollView.bounds.size.width / self.scrollView.bounds.size.height;
    CGFloat imageViewRatio = self.imageView.bounds.size.width / self.imageView.bounds.size.height;
    
    CGFloat zoomScale;
    if (imageViewRatio < scrollViewRatio) {
        zoomScale = self.scrollView.bounds.size.height / self.imageView.bounds.size.height;
    } else {
        zoomScale = self.scrollView.bounds.size.width / self.imageView.bounds.size.width;
    }
    
    self.scrollView.zoomScale = zoomScale;
}

// When the bounds change, we need to automatically zoom so that as much of the photo is possible
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Refit the image to scroll view's current dimensions 
    [self fitImageToWindow];
}

@end
