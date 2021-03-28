//
//  UIImage+ColorExtraction.h
//  vPhoto
//
//  Created by Danis Tazetdinov on 18.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorExtraction)

@property (nonatomic, readonly) NSArray *majorColors;

-(NSArray*)majorColorsByScalingToSize:(int)imageSize;

@end
