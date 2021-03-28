//
//  VPHFlickrPhotoset.h
//  vPhoto
//
//  Created by Danis Tazetdinov on 19.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPHFlickrPhoto.h"

@interface VPHFlickrPhotoset : NSObject

+(instancetype)flickrPhotosetUsingDictionary:(NSDictionary*)dictionary;

@property (nonatomic, strong, readonly) NSNumber *photosetID;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *details;

@property (nonatomic, strong, readonly) VPHFlickrPhoto *photo;

@end
