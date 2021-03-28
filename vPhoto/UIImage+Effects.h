//
//  UIImage+Effects.h
//  Blurry
//
//  Created by Danis Tazetdinov on 10/02/14.
//  Copyright (c) 2014 Fujitsu Russia GDC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Effects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius
                       tintColor:(UIColor *)tintColor
           saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                       maskImage:(UIImage *)maskImage;

@end
