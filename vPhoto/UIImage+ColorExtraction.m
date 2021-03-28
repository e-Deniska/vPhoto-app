//
//  UIImage+ColorExtraction.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 18.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "UIImage+ColorExtraction.h"

@implementation UIImage (ColorExtraction)

-(NSArray *)majorColors
{
    return [self majorColorsByScalingToSize:10];
}

-(NSArray*)majorColorsByScalingToSize:(int)imageSize
{
    CGSize size = CGSizeMake(imageSize, imageSize);
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:(imageSize * 2)];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [newImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = 0;
    for (int i = 0 ; i < (imageSize * imageSize) ; ++i)
    {
        if ((i % imageSize == 0) || (i % imageSize == (imageSize - 1)))
        {
            CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
            CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
            CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
            CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
            
            UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            [result addObject:acolor];
        }
        
        byteIndex += 4;
    }
    
    free(rawData);
    return [result copy];
}

@end
