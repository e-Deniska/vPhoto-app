//
//  VPHSlideshowViewController.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 20.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPHSlideshowViewController.h"
#import "UIImage+ColorExtraction.h"

#import "DPHueLight.h"
#import "VPLColor.h"

#import "VPLAnimatedImageView.h"
#import "VPHSecondWindow.h"
#import "UIImage+Effects.h"

#import <QuartzCore/QuartzCore.h>

NSString * const kVPHLampKey = @"VPHLampKey";

@interface VPHSlideshowViewController ()
@property (weak, nonatomic) IBOutlet VPLAnimatedImageView *mainAnimatedImageView;

@property (nonatomic, weak) NSTimer *slideTimer;

@property (nonatomic, strong) NSMutableArray *colorTimers;

@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) NSArray *imageColors;

@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIImageView *controlsBackground;
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleFullscreenButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingIndicator;

- (IBAction)photoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)playOrPause:(UIButton*)sender;
- (IBAction)nextPhoto:(UIButton *)sender;

@end

@implementation VPHSlideshowViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIStatusBarAnimationFade : UIStatusBarAnimationSlide;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.controlsView.alpha = 0.0f;
    self.controlsView.hidden = YES;
    self.controlsView.layer.cornerRadius = 33.0f;
    
    self.playOrPauseButton.tintColor = [UIColor whiteColor];
    [self.playOrPauseButton setImage:[[UIImage imageNamed:@"controls-pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                            forState:UIControlStateNormal];
    [self.playOrPauseButton setImage:[[UIImage imageNamed:@"controls-pause-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                            forState:UIControlStateHighlighted];
    
    self.nextButton.tintColor = [UIColor whiteColor];
    [self.nextButton setImage:[[UIImage imageNamed:@"controls-next"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateNormal];
    [self.nextButton setImage:[[UIImage imageNamed:@"controls-next-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateHighlighted];
    
    self.stopButton.tintColor = [UIColor whiteColor];
    [self.stopButton setImage:[[UIImage imageNamed:@"controls-stop"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateNormal];
    [self.stopButton setImage:[[UIImage imageNamed:@"controls-stop-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateHighlighted];
    self.toggleFullscreenButton.tintColor = [UIColor whiteColor];
    if ([NSUserDefaults standardUserDefaults].photoFillsScreen)
    {
        [self.toggleFullscreenButton setImage:[[UIImage imageNamed:@"controls-fit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                     forState:UIControlStateNormal];
        [self.toggleFullscreenButton setImage:[[UIImage imageNamed:@"controls-fit-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                     forState:UIControlStateHighlighted];
    }
    else
    {
        [self.toggleFullscreenButton setImage:[[UIImage imageNamed:@"controls-fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                     forState:UIControlStateNormal];
        [self.toggleFullscreenButton setImage:[[UIImage imageNamed:@"controls-fill-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                     forState:UIControlStateHighlighted];
    }
    [self updateControlsBackgroundWithDuration:1.0f updateImage:YES];
}

-(void)updateControlsBackgroundWithDuration:(NSTimeInterval)duration updateImage:(BOOL)updateImage
{
    if (updateImage)
    {
        [self.mainAnimatedImageView updateCurrentImage];
    }
    
    UIImage *cropped = [self.mainAnimatedImageView imageAtRect:self.controlsView.frame];
    DLog(@"cropped %@, %@, %@", NSStringFromCGSize(cropped.size),
         NSStringFromCGRect(self.controlsBackground.frame), NSStringFromCGRect(self.controlsView.frame));
    
    
    UIImageView *imageView =  [[UIImageView alloc] initWithImage:[cropped applyTintEffectWithColor:self.view.tintColor]];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    imageView.translatesAutoresizingMaskIntoConstraints = YES;
    imageView.alpha = 0.0f;
    [self.controlsView insertSubview:imageView aboveSubview:self.controlsBackground];
    
    if (duration)
    {
        [UIView animateWithDuration:duration
                         animations:^{
                             imageView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [self.controlsBackground removeFromSuperview];
                             self.controlsBackground = imageView;
                         }];
    }
    else
    {
        imageView.alpha = 1.0f;
        [self.controlsBackground removeFromSuperview];
        self.controlsBackground = imageView;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [VPHSecondWindow secondWindow].animatedImageView.hidden = NO;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.mainAnimatedImageView.animationBlock = ^{
        [self updateControlsBackgroundWithDuration:1.0f updateImage:NO];
    };
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self displayNextImage:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"stopping animation")
    [self stopAmbientColors];
    [self.slideTimer invalidate];
    self.slideTimer = nil;
    [VPHSecondWindow secondWindow].animatedImageView.hidden = YES;
    [[VPHSecondWindow secondWindow].animatedImageView animateImage:nil duration:0.1f];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.mainAnimatedImageView.animationBlock = nil;
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration
{
//    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateControlsBackgroundWithDuration:duration updateImage:YES];
}

-(void)displayNextImage:(NSTimer*)timer
{
    [timer invalidate];
    DLog(@"timer fired");
    if ([self.dataSource isNextImageAvailableForSlideshowController:self])
    {
        if ([self.dataSource isNextImageReadyForSlideshowController:self])
        {
            if (self.imageLoadingIndicator.isAnimating)
            {
                [self.imageLoadingIndicator stopAnimating];
            }
            self.currentImage = [self.dataSource nextImageForSlideshowController:self];
            DLog(@"next image %@", self.currentImage);
            
            if (self.currentImage)
            {
                self.imageColors = self.currentImage.majorColors;
                //DLog(@"colors = %lld, views %lld", (long long)self.imageColors.count, (long long)self.colors.count)
                [self.mainAnimatedImageView animateImage:self.currentImage duration:1.0f];
                
                [[VPHSecondWindow secondWindow].animatedImageView animateImage:self.currentImage
                                                                      duration:1.0f];
                
                [self stopAmbientColors];
                [self startAmbientColors];
            }
            
            self.slideTimer = [NSTimer scheduledTimerWithTimeInterval:[NSUserDefaults standardUserDefaults].slideDuration
                                                               target:self
                                                             selector:@selector(displayNextImage:)
                                                             userInfo:nil
                                                              repeats:NO];
            
        }
        else
        {
            self.slideTimer = [NSTimer scheduledTimerWithTimeInterval:([NSUserDefaults standardUserDefaults].slideDuration / 4)
                                                               target:self
                                                             selector:@selector(displayNextImage:)
                                                             userInfo:nil
                                                              repeats:NO];
        }
    }
    else
    {
        DLog(@"we're about to dismiss slide show");
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"DismissSlideshow" sender:self];
        });
    }
}

#pragma mark - Hue lamp managment

-(void)startAmbientColors
{
    if ((self.imageColors.count) && (self.lamps.count))
    {
        self.colorTimers = [NSMutableArray arrayWithCapacity:self.lamps.count];
        for (DPHueLight *lamp in self.lamps)
        {
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                              target:self
                                                            selector:@selector(applyRandomAmbientColor:)
                                                            userInfo:@{ kVPHLampKey : lamp }
                                                             repeats:NO];
            [self.colorTimers addObject:timer];
        }
    }
}

-(void)stopAmbientColors
{
    for (NSTimer *timer in self.colorTimers)
    {
        [timer invalidate];
    }
    self.colorTimers = nil;
}

-(void)applyRandomAmbientColor:(NSTimer*)timer
{
    DPHueLight *lamp = timer.userInfo[kVPHLampKey];
    [self.colorTimers removeObject:timer];
    
    UIColor *color = self.imageColors[arc4random() % self.imageColors.count];

    NSTimeInterval interval = [NSUserDefaults standardUserDefaults].slideDuration / 2.0f;
    VPLColor *hueColor = [VPLColor colorWithUIColor:color duration:interval];

#warning Interval + some randomness
//    NSTimeInterval interval = color.duration - (color.durationRandomness / 2);
//    interval += (color.durationRandomness / 100.0f) * (arc4random() % 100);
    
    [hueColor applyToLamp:lamp];
    
    NSTimer *nextTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                          target:self
                                                        selector:@selector(applyRandomAmbientColor:)
                                                        userInfo:@{ kVPHLampKey : lamp }
                                                         repeats:NO];
    [self.colorTimers addObject:nextTimer];
}



- (IBAction)photoTapped:(UITapGestureRecognizer *)sender
{
    if (self.controlsView.hidden)
    {
        self.controlsView.hidden = NO;
        [UIView animateWithDuration:0.5f
                         animations:^{
                             self.controlsView.alpha = 1.0f;
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.5f
                         animations:^{
                             self.controlsView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             self.controlsView.hidden = YES;
                         }];
    }
}

- (IBAction)playOrPause:(id)sender
{
    if (self.slideTimer)
    {
        [self.slideTimer invalidate];
        self.slideTimer = nil;
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            [self.playOrPauseButton setTitle:NSLocalizedString(@"[PlayPad]", @"Play button title")
//                                    forState:UIControlStateNormal];
//        }
//        else
//        {
//            [self.playOrPauseButton setTitle:NSLocalizedString(@"[Play]", @"Play button title")
//                                    forState:UIControlStateNormal];
//        }
        [self.playOrPauseButton setImage:[[UIImage imageNamed:@"controls-play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                forState:UIControlStateNormal];
        [self.playOrPauseButton setImage:[[UIImage imageNamed:@"controls-play-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                forState:UIControlStateHighlighted];
    }
    else
    {
        [self displayNextImage:nil];
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            [self.playOrPauseButton setTitle:NSLocalizedString(@"[PausePad]", @"Pause button for iPad title")
//                                    forState:UIControlStateNormal];
//        }
//        else
//        {
//            [self.playOrPauseButton setTitle:NSLocalizedString(@"[Pause]", @"Pause button title")
//                                    forState:UIControlStateNormal];
//        }
        [self.playOrPauseButton setImage:[[UIImage imageNamed:@"controls-pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                forState:UIControlStateNormal];
        [self.playOrPauseButton setImage:[[UIImage imageNamed:@"controls-pause-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                forState:UIControlStateHighlighted];
    }
}

- (IBAction)nextPhoto:(UIButton *)sender
{
    [self stopAmbientColors];
    [self.slideTimer invalidate];
    self.slideTimer = nil;
    [self displayNextImage:nil];
}

-(IBAction)toggleFullscreenMode:(id)sender
{
    if ([NSUserDefaults standardUserDefaults].photoFillsScreen)
    {
        [NSUserDefaults standardUserDefaults].photoFillsScreen = NO;
        [self.toggleFullscreenButton setImage:[[UIImage imageNamed:@"controls-fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                     forState:UIControlStateNormal];
        [self.toggleFullscreenButton setImage:[[UIImage imageNamed:@"controls-fill-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                     forState:UIControlStateHighlighted];
    }
    else
    {
        [NSUserDefaults standardUserDefaults].photoFillsScreen = YES;
        [self.toggleFullscreenButton setImage:[[UIImage imageNamed:@"controls-fit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                     forState:UIControlStateNormal];
        [self.toggleFullscreenButton setImage:[[UIImage imageNamed:@"controls-fit-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                     forState:UIControlStateHighlighted];
    }
    
    
    [self.mainAnimatedImageView redrawImage];
    [[VPHSecondWindow secondWindow].animatedImageView redrawImage];
    [self updateControlsBackgroundWithDuration:1.0f updateImage:NO];
}


@end
