//
//  VPHFlickrUserSearchViewController.h
//  vPhoto
//
//  Created by Danis Tazetdinov on 22.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPHue.h"

@interface VPHFlickrUserSearchViewController : UICollectionViewController

@property (nonatomic, copy) NSString *flickrUserName;

@property (nonatomic, strong) DPHue *hue;

@end
