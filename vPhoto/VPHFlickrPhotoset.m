//
//  VPHFlickrPhotoset.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 19.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPHFlickrPhotoset.h"

@interface VPHFlickrPhotoset ()

@property (nonatomic, strong, readwrite) NSNumber *photosetID;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *details;

@property (nonatomic, strong, readwrite) VPHFlickrPhoto *photo;

@end

#define FLICKR_PHOTOSET_TITLE @"title._content"
#define FLICKR_PHOTOSET_DETAILS @"description._content"
#define FLICKR_PHOTOSET_ID @"id"

@implementation VPHFlickrPhotoset

+(instancetype)flickrPhotosetUsingDictionary:(NSDictionary *)dictionary
{
    VPHFlickrPhotoset *photoset = [[self alloc] init];
    photoset.photosetID = [dictionary valueForKeyPath:FLICKR_PHOTOSET_ID];
    photoset.title = [dictionary valueForKeyPath:FLICKR_PHOTOSET_TITLE];
    photoset.details = [dictionary valueForKeyPath:FLICKR_PHOTOSET_DETAILS];
    photoset.photo = [VPHFlickrPhoto flickrPhotoUsingDictionary:dictionary];
        
    return ((photoset.photosetID) && (photoset.title.length)) ? photoset : nil;
}

@end
