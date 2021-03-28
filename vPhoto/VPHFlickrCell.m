//
//  VPHFlickrCell.m
//  vPhotos
//
//  Created by Danis Tazetdinov on 13.02.14.
//  Copyright (c) 2014 Danis Tazetdinov. All rights reserved.
//

#import "VPHFlickrCell.h"

@interface VPHFlickrCell()

@property (nonatomic, assign) BOOL highlightShown;

@end

@implementation VPHFlickrCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.masksToBounds = NO;
    
    self.title.layer.masksToBounds = NO;
    self.title.layer.shadowOffset = CGSizeZero;
    self.title.layer.shadowOpacity = 1.0f;
    self.title.layer.shadowColor = [UIColor blackColor].CGColor;
    self.title.layer.shadowRadius = 3.0f;
    self.title.layer.shouldRasterize = YES;
    
    self.coverImage.layer.masksToBounds = NO;
    self.coverImage.layer.shadowOffset = CGSizeZero;
    self.coverImage.layer.shadowOpacity = 1.0f;
    self.coverImage.layer.shadowColor = [UIColor grayColor].CGColor;
    self.coverImage.layer.shadowRadius = 5.0f;
    self.coverImage.layer.shouldRasterize = YES;
}

-(void)updateSelectionIndication
{
//    DLog(@"got selected=%d, highligted=%d, highlightShown=%d", self.selected, self.highlighted, self.highlightShown);
    if ((self.selected) || (self.highlighted))
    {
        if (!self.highlightShown)
        {
            CABasicAnimation *animationColor = [CABasicAnimation animationWithKeyPath:@"shadowColor"];
            animationColor.toValue = (__bridge id)([UIColor whiteColor].CGColor);
            animationColor.removedOnCompletion = NO;
            animationColor.fillMode = kCAFillModeForwards;
            animationColor.duration = 0.1f;
            
            [self.coverImage.layer addAnimation:animationColor forKey:@"shadowAnimations"];
            self.highlightShown = YES;
        }
    }
    else
    {
        if (self.highlightShown)
        {
            CABasicAnimation *animationColor = [CABasicAnimation animationWithKeyPath:@"shadowColor"];
            animationColor.toValue = (__bridge id)([UIColor grayColor].CGColor);
            animationColor.removedOnCompletion = NO;
            animationColor.fillMode = kCAFillModeForwards;
            animationColor.duration = 0.1f;
            
            [self.coverImage.layer addAnimation:animationColor forKey:@"shadowAnimations"];
            self.highlightShown = NO;
        }
    }
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self updateSelectionIndication];
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateSelectionIndication];
}



-(void)prepareForReuse
{
    //    DLog(@"reusing %@", self.magazineTitle.text);
    [super prepareForReuse];
    [self updateSelectionIndication];
    //    [self updateMotionEffects];
}

@end
