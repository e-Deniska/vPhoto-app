//
//  VPHFlickrUser.h
//  vPhoto
//
//  Created by Danis Tazetdinov on 19.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPHFlickrUser : NSObject

+(instancetype)flickrUserUsingDictionary:(NSDictionary*)dictionary;

@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *name;

@end
