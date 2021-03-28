//
//  VPHSecondWindow.h
//  vPhoto
//
//  Created by Danis Tazetdinov on 22.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VPLAnimatedImageView.h"

@interface VPHSecondWindow : NSObject

+(instancetype)secondWindow;

@property (nonatomic, strong, readonly) UIWindow *window;
@property (nonatomic, weak, readonly) VPLAnimatedImageView *animatedImageView;

-(void)connectWindowIfPossible;

@end
