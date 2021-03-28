//
//  VPHSlideshowViewController.h
//  vPhoto
//
//  Created by Danis Tazetdinov on 20.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VPHSlideshowViewControllerDataSource;
//@protocol VPHSlideshowViewControllerDelegate;

@interface VPHSlideshowViewController : UIViewController

// methods to override
@property (nonatomic, weak) id<VPHSlideshowViewControllerDataSource> dataSource;

@property (nonatomic, strong) NSArray *lamps;

@end

@protocol VPHSlideshowViewControllerDataSource

-(UIImage*)nextImageForSlideshowController:(VPHSlideshowViewController *)slideshow;
-(BOOL)isNextImageReadyForSlideshowController:(VPHSlideshowViewController*)slideshow;


-(BOOL)isNextImageAvailableForSlideshowController:(VPHSlideshowViewController*)slideshow;

@end
