//
//  VPLColor.m
//  vPlaces
//
//  Created by Danis Tazetdinov on 12.11.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPLColor.h"

@interface VPLColor()

@property (nonatomic, assign, readwrite) int hue; // 0..255
@property (nonatomic, assign, readwrite) int saturation; // 0..255
@property (nonatomic, assign, readwrite) int brightness; // 0..255

@property (nonatomic, assign, readwrite) int brightnessRandomness;

@property (nonatomic, assign, readwrite) NSTimeInterval duration;

@property (nonatomic, assign, readwrite) NSTimeInterval durationRandomness;

@property (nonatomic, assign, readwrite) BOOL smoothTransition;

@property (nonatomic, assign, readwrite) BOOL applyToAllLamps;

@end

@implementation VPLColor

-(void)applyToLamp:(DPHueLight*)lamp
{
    int brightness = self.brightness + (arc4random() % self.brightnessRandomness) - (self.brightnessRandomness / 2);
    brightness = MAX(1,brightness);
    lamp.on = (brightness > 0);
    if (brightness > 0)
    {
        lamp.brightness = @(MIN(255, brightness));
        lamp.hue = @(self.hue);
        lamp.saturation = @(self.saturation);
        if (self.smoothTransition)
        {
            int transitionTime = (int)(self.duration * 5.0f);
            lamp.transitionTime = @(transitionTime);
        }
        else
        {
            lamp.transitionTime = nil;
        }
    }
    DLog(@"[%@] - (%d,%d,%d)", lamp.name, self.hue, self.saturation, brightness);
    
    [lamp write];
}

+(instancetype)colorWithUIColor:(UIColor*)color duration:(NSTimeInterval)duration
{
    CGFloat hue, sat, bri, alpha;
    [color getHue:&hue saturation:&sat brightness:&bri alpha:&alpha];
    return [self colorWithHue:(int)(65535.0f * hue)
                   saturation:(int)(255.0f * sat)
                   brightness:(int)(255.0f * bri)
         brightnessRandomness:50
                     duration:duration
           durationRandomness:0.0f
             smoothTransition:YES
                     allLamps:NO];
}

+(instancetype)colorWithHue:(int)hue
                 saturation:(int)saturation
                 brightness:(int)brightness
       brightnessRandomness:(int)brightnessRandomness
                   duration:(NSTimeInterval)duration
         durationRandomness:(NSTimeInterval)durationRandomness
           smoothTransition:(BOOL)smoothTransition
                   allLamps:(BOOL)allLamps
{
    return [[self alloc] initWithHue:hue
                          saturation:saturation
                          brightness:brightness
                brightnessRandomness:brightnessRandomness
                            duration:duration
                  durationRandomness:durationRandomness
                    smoothTransition:smoothTransition
                            allLamps:allLamps];
}

-(instancetype)initWithHue:(int)hue
                saturation:(int)saturation
                brightness:(int)brightness
      brightnessRandomness:(int)brightnessRandomness
                  duration:(NSTimeInterval)duration
        durationRandomness:(NSTimeInterval)durationRandomness
          smoothTransition:(BOOL)smoothTransition
                  allLamps:(BOOL)allLamps
{
    self = [super init];
    if (self)
    {
        self.hue = hue;
        self.saturation = saturation;
        self.brightness = brightness;
        self.brightnessRandomness = brightnessRandomness;
        self.duration = duration;
        self.durationRandomness = durationRandomness;
        self.smoothTransition = smoothTransition;
        self.applyToAllLamps = allLamps;
    }
    
    return self;
}


@end
