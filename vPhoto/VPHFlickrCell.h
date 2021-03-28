//
//  VPHFlickrCell.h
//  vPhotos
//
//  Created by Danis Tazetdinov on 13.02.14.
//  Copyright (c) 2014 Danis Tazetdinov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VPHFlickrCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *coverImage;
@property (nonatomic, weak) IBOutlet UILabel *title;

@property (nonatomic, copy) NSString *flickrUserName;

@end
