//
//  VPHFlickrPhoto.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 19.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPHFlickrPhoto.h"

@interface VPHFlickrPhoto ()

@property (nonatomic, strong, readwrite) NSNumber *photoID;
@property (nonatomic, strong, readwrite) NSNumber *farm;
@property (nonatomic, strong, readwrite) NSNumber *server;

@property (nonatomic, strong, readwrite) NSString *secret;
@property (nonatomic, strong, readwrite) NSString *originalSecret;

@property (nonatomic, strong, readwrite) NSString *originalFormat;

@property (nonatomic, strong, readwrite) NSString *title;

@property (nonatomic, readonly) dispatch_queue_t imageLoadQueue;

@end

@implementation VPHFlickrPhoto

#define FLICKR_PHOTO_ID       @"id"
#define FLICKR_PHOTO_PRIMARY  @"primary"
#define FLICKR_PHOTO_FARM     @"farm"
#define FLICKR_PHOTO_SERVER   @"server"
#define FLICKR_PHOTO_SECRET   @"secret"
#define FLICKR_PHOTO_TITLE    @"title"
#define FLICKR_PHOTO_SECRET_O @"originalsecret"
#define FLICKR_PHOTO_FORMAT_O @"originalformat"

+(instancetype)flickrPhotoUsingDictionary:(NSDictionary *)dictionary
{
    VPHFlickrPhoto *photo = [[self alloc] init];
    NSNumber *photoID = [dictionary valueForKeyPath:FLICKR_PHOTO_PRIMARY];
    if (!photoID)
    {
        photoID = [dictionary valueForKeyPath:FLICKR_PHOTO_ID];
    }
    photo.photoID = photoID;
    photo.farm = [dictionary valueForKeyPath:FLICKR_PHOTO_FARM];
    photo.server = [dictionary valueForKeyPath:FLICKR_PHOTO_SERVER];
    photo.originalSecret = [dictionary valueForKeyPath:FLICKR_PHOTO_SECRET_O];
    photo.originalFormat = [dictionary valueForKeyPath:FLICKR_PHOTO_FORMAT_O];
    photo.secret = [dictionary valueForKeyPath:FLICKR_PHOTO_SECRET];
    photo.title = [dictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
    
    return ((photo.photoID) && (photo.farm) && (photo.server) && (photo.secret)) ? photo : nil;
}

-(dispatch_queue_t)imageLoadQueue
{
    static dispatch_once_t onceToken;
    static dispatch_queue_t _queue;
    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create("com.tazetdinov.vphotos.imageLoadQueue", DISPATCH_QUEUE_SERIAL);
    });
    return _queue;
}

- (NSURL *)URLForFormat:(VPHFlickrPhotoFormat)format
{
	NSString *fileType = @"jpg";
	
    BOOL hasOriginal = ((self.originalSecret) && (self.originalFormat.length));
    
    NSString *secret = self.secret;
	NSString *formatString = @"s";
	switch (format)
    {
		case VPHFlickrPhotoFormatSquare:
        {
            formatString = @"q";
            break;
        }
            
		case VPHFlickrPhotoFormatLarge:
        {
            formatString = @"b";
            break;
        }
            
		case VPHFlickrPhotoFormatOriginal:
        {
            if (hasOriginal)
            {
                formatString = @"o";
                secret = self.originalSecret;
                fileType = self.originalFormat;
            }
            else
            {
                formatString = @"b";
            }
            break;
        }
	}
    
    NSString *urlString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.%@", self.farm, self.server, self.photoID, secret, formatString, fileType];
    
    DLog(@"got URL %@", urlString);
	return [NSURL URLWithString:urlString];
}

-(void)loadPhotoWithFormat:(VPHFlickrPhotoFormat)format completion:(VPHFlickrPhotoLoadCompletion)completion
{
    if (!completion)
    {
        return;
    }
    VPHFlickrPhotoLoadCompletion completionBlock = [completion copy];
    dispatch_async(self.imageLoadQueue, ^{
        completionBlock([UIImage imageWithData:[NSData dataWithContentsOfURL:[self URLForFormat:format]]]);
    });
    
}

@end
