//
//  UIColor+TintColor.m
//  vPhotos
//
//  Created by Danis Tazetdinov on 13.02.14.
//  Copyright (c) 2014 Danis Tazetdinov. All rights reserved.
//

#import "UIColor+TintColor.h"

@implementation UIColor (TintColor)

+(instancetype)tintColor
{
    static dispatch_once_t onceToken;
    static UIColor *_tintColor;
    dispatch_once(&onceToken, ^{
        _tintColor = [UIColor colorWithRed:0.008f green:0.851f blue:1.0f alpha:1.0f];
    });
    return _tintColor;
}


@end
