//
//  VPHFlickrFetcher.h
//  vPhoto
//
//  Created by Danis Tazetdinov on 19.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPHFlickrPhoto.h"
#import "VPHFlickrPhotoset.h"
#import "VPHFlickrUser.h"

typedef void (^VPHFlickrUserCompletion)(VPHFlickrUser *flickrUser);
typedef void (^VPHFlickrPhotosetsCompletion)(NSArray *photosets);
typedef void (^VPHFlickrPhotosCompletion)(NSArray *photos);


@interface VPHFlickrFetcher : NSObject

+(instancetype)sharedFetcher;

-(void)findUserWithName:(NSString*)userName completion:(VPHFlickrUserCompletion)completionBlock;
-(void)findUserWithEmail:(NSString*)email completion:(VPHFlickrUserCompletion)completionBlock;

-(void)getPhotosetsOfUser:(VPHFlickrUser*)user completion:(VPHFlickrPhotosetsCompletion)completionBlock;
-(void)getPhotosInPhotoset:(VPHFlickrPhotoset*)photoset completion:(VPHFlickrPhotosCompletion)completionBlock;
-(void)getPhotosOfUser:(VPHFlickrUser*)user completion:(VPHFlickrPhotosCompletion)completionBlock;
-(void)getRecentPhotosWithCompletion:(VPHFlickrPhotosCompletion)completionBlock;
-(void)getInterestingPhotosWithCompletion:(VPHFlickrPhotosCompletion)completionBlock;

@end
