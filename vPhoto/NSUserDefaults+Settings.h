//
//  NSUserDefaults+Settings.h
//  vPhoto
//
//  Created by Danis Tazetdinov on 20.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VPHSavedFlickrUserListUpdatedNotification;

@interface NSUserDefaults (Settings)

@property (nonatomic, copy) NSString *hueName;
@property (nonatomic, readonly) NSString *appUsername;

@property (nonatomic, assign) NSTimeInterval slideDuration;
@property (nonatomic, assign) BOOL randomImages;

@property (nonatomic, assign) BOOL photoFillsScreen;

@property (nonatomic, copy) NSArray *lampNumbers;

@property (nonatomic, copy) NSArray *flickrUsers;
-(void)addFlickrUsersObject:(NSString *)object;

@end
