//
//  VPHFlickrPhoto.h
//  vPhoto
//
//  Created by Danis Tazetdinov on 19.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VPHFlickrPhotoLoadCompletion)(UIImage* photo);

typedef NS_ENUM(NSUInteger, VPHFlickrPhotoFormat)
{
	VPHFlickrPhotoFormatSquare = 1,    // thumbnail
	VPHFlickrPhotoFormatLarge = 2,     // normal size
	VPHFlickrPhotoFormatOriginal = 64  // high resolution
};


@interface VPHFlickrPhoto : NSObject

+(instancetype)flickrPhotoUsingDictionary:(NSDictionary*)dictionary;

@property (nonatomic, strong, readonly) NSString *title;

- (NSURL *)URLForFormat:(VPHFlickrPhotoFormat)format;

-(void)loadPhotoWithFormat:(VPHFlickrPhotoFormat)format completion:(VPHFlickrPhotoLoadCompletion)completion;

@end
