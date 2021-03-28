//
//  VPHFlickrUser.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 19.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPHFlickrUser.h"

@interface VPHFlickrUser()

@property (nonatomic, strong, readwrite) NSString *userID;
@property (nonatomic, strong, readwrite) NSString *name;

@end

#define FLICKR_USER_ID   @"id"
#define FLICKR_USER_NAME @"username._content"

@implementation VPHFlickrUser

+(instancetype)flickrUserUsingDictionary:(NSDictionary *)dictionary
{
    VPHFlickrUser *user = [[self alloc] init];
    user.userID = [dictionary valueForKeyPath:FLICKR_USER_ID];
    user.name = [dictionary valueForKeyPath:FLICKR_USER_NAME];
        
    return ((user.userID.length) && (user.name.length)) ? user : nil;
}

@end
