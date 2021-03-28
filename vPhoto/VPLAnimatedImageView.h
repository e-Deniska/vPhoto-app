//
//  VPLAnimatedImageView.h
//  vPlaces
//
//  Created by Danis Tazetdinov on 16.11.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VPLAnimatedImageViewAnimationBlock)();

@interface VPLAnimatedImageView : UIView

- (void)animateImage:(UIImage*)image duration:(NSTimeInterval)duration;
-(UIImage*)imageAtRect:(CGRect)cropRect;
-(void)updateCurrentImage;
-(void)redrawImage;

@property (nonatomic, copy) VPLAnimatedImageViewAnimationBlock animationBlock;

@end
