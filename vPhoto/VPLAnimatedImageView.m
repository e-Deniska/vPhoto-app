//
//  VPLAnimatedImageView.m
//  vPlaces
//
//  Created by Danis Tazetdinov on 16.11.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPLAnimatedImageView.h"

@interface VPLAnimatedImageView()

@property (nonatomic, weak) UIImageView *displayedImageView;
@property (nonatomic, strong) UIImage *currentImage;

@end

@implementation VPLAnimatedImageView

#warning Animate image for duration

-(void)animateImage:(UIImage *)image duration:(NSTimeInterval)duration
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.translatesAutoresizingMaskIntoConstraints = YES;
    
    imageView.contentMode = [NSUserDefaults standardUserDefaults].photoFillsScreen ?
                            UIViewContentModeScaleAspectFill :
                            UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.image = image;
    imageView.opaque = NO;
    
    CGFloat scale = self.window.screen.scale;
    if (scale == 0.0f)
    {
        scale = [UIScreen mainScreen].scale;
    }
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, YES, scale);
    BOOL success = [imageView drawViewHierarchyInRect:imageView.bounds
                                   afterScreenUpdates:YES];
    if (!success)
    {
        NSLog(@"could not draw view");
    }
    self.currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageView.alpha = 0.0f;
    [self addSubview:imageView];
    if (self.displayedImageView)
    {
        UIImageView *oldImageView = self.displayedImageView;
        self.displayedImageView = imageView;
        [UIView animateWithDuration:1.0f
                         animations:^{
                             imageView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [oldImageView removeFromSuperview];
                         }];
        if (self.animationBlock)
        {
            self.animationBlock();
        }
    }
    else
    {
        imageView.alpha = 1.0f;
        self.displayedImageView = imageView;
        if (self.animationBlock)
        {
            self.animationBlock();
        }
    }
}

-(void)redrawImage
{
    [self animateImage:self.displayedImageView.image duration:1.0];
}

-(void)updateCurrentImage
{
    CGFloat scale = self.window.screen.scale;
    if (scale == 0.0f)
    {
        scale = [UIScreen mainScreen].scale;
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    BOOL success = [self drawViewHierarchyInRect:self.bounds
//                              afterScreenUpdates:YES];
//    if (!success)
//    {
//        NSLog(@"could not draw view");
//    }
    self.currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(UIImage *)imageAtRect:(CGRect)cropRect
{
    if (!self.currentImage)
    {
//        UIGraphicsBeginImageContext(self.bounds.size);
//        [[UIColor blackColor] setFill];
//        CGContextAddRect(UIGraphicsGetCurrentContext(), self.bounds);
//        CGContextFillPath(UIGraphicsGetCurrentContext());
//        self.currentImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        [self updateCurrentImage];
    }
    CGFloat scale = self.window.screen.scale;
    if (scale == 0.0f)
    {
        scale = [UIScreen mainScreen].scale;
    }
    
    CGRect croppingRect = CGRectMake(cropRect.origin.x * scale,
                                     cropRect.origin.y * scale,
                                     cropRect.size.width * scale,
                                     cropRect.size.height * scale);
    
    CGImageRef cgCroped = CGImageCreateWithImageInRect(self.currentImage.CGImage, croppingRect);
    UIImage *image = [UIImage imageWithCGImage:cgCroped
                                         scale:[UIScreen mainScreen].scale
                                   orientation:UIImageOrientationUp];
    if (cgCroped)
    {
        CFRelease(cgCroped);
    }
    return image;
}

@end
