//
//  VPHSecondWindow.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 22.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPHSecondWindow.h"
#import "UIScreen+SecondScreen.h"

@interface VPHSecondWindow()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) VPLAnimatedImageView *animatedImageView;

@end

@implementation VPHSecondWindow

+(instancetype)secondWindow
{
    static dispatch_once_t onceToken;
    static id _secondWindow;
    dispatch_once(&onceToken, ^{
        _secondWindow = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenDidConnectNotification
                                                          object:_secondWindow
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [_secondWindow connectWindowIfPossible];
                                                      } ];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenDidDisconnectNotification
                                                          object:_secondWindow
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [_secondWindow connectWindowIfPossible];
                                                      } ];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenModeDidChangeNotification
                                                          object:_secondWindow
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          DLog(@"%@", note);
                                                          DLog(@"%@", note.object);
                                                      }];
    });
    return _secondWindow;
}

-(void)connectWindowIfPossible
{
    UIScreen *secondScreen = [UIScreen secondScreen];
    if (secondScreen)
    {
        secondScreen.overscanCompensation = UIScreenOverscanCompensationInsetApplicationFrame;
        self.window = [[UIWindow alloc] initWithFrame:secondScreen.bounds];
        self.window.screen = secondScreen;
        self.window.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:32.0f];
        label.minimumScaleFactor = 1.0f;

#warning Consider adding animations for label? or better background for window
        
        label.text = NSLocalizedString(@"[Choose photos for slideshow]", @"Choose photos label");
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        label.center = self.window.center;
        [self.window addSubview:label];
        
        VPLAnimatedImageView *imageView = [[VPLAnimatedImageView alloc] initWithFrame:self.window.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.translatesAutoresizingMaskIntoConstraints = YES;
        imageView.contentMode = UIViewContentModeRedraw;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.hidden = YES;
        
        [self.window addSubview:imageView];
        self.animatedImageView = imageView;
        
        self.window.hidden = NO;
    }
    else
    {
        [self.animatedImageView removeFromSuperview];
        self.window.screen = nil;
        self.window.hidden = YES;
        [self.window removeFromSuperview];
        self.window = nil;
        self.animatedImageView = nil;
    }
}

@end
