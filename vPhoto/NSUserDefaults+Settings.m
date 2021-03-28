//
//  NSUserDefaults+Settings.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 20.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "NSUserDefaults+Settings.h"
#import "DPHue.h"

#define KEY_SLIDEDURATION @"slideDuration"
#define KEY_RANDOMIMAGES  @"randomImages"
#define KEY_FILLSCREEN    @"photoFillsScreen"

#define KEY_HUENAME     @"hueName"
#define KEY_APPUSERNAME @"appUserName"
#define KEY_LAMPNUMBERS @"lampNumbers"
#define KEY_FLICKRUSERS @"flickrUsers"

#define DEFAULT_SLIDEDURATION 15.0f
#define DEFAULT_RANDOMIMAGES  NO

#define MAX_FLICKER_USERS 25

NSString * const VPHSavedFlickrUserListUpdatedNotification = @"VPHSavedFlickrUserListUpdatedNotification";


@implementation NSUserDefaults (Settings)

-(NSTimeInterval)slideDuration
{
    NSNumber *duration = [self objectForKey:KEY_SLIDEDURATION];
    if (duration)
    {
        return [duration doubleValue];
    }
    else
    {
        return DEFAULT_SLIDEDURATION;
    }
}

-(void)setSlideDuration:(NSTimeInterval)slideDuration
{
    [self setObject:@(slideDuration) forKey:KEY_SLIDEDURATION];
    [self synchronize];
}

-(BOOL)randomImages
{
    NSNumber *random = [self objectForKey:KEY_RANDOMIMAGES];
    if (random)
    {
        return [random boolValue];
    }
    else
    {
        return DEFAULT_RANDOMIMAGES;
    }
}

-(void)setRandomImages:(BOOL)randomImages
{
    [self setObject:@(randomImages) forKey:KEY_RANDOMIMAGES];
    [self synchronize];
}

-(BOOL)photoFillsScreen
{
    return [[self objectForKey:KEY_FILLSCREEN] boolValue];
}

-(void)setPhotoFillsScreen:(BOOL)photoFillsScreen
{
    [self setObject:@(photoFillsScreen) forKey:KEY_FILLSCREEN];
    [self synchronize];
}

-(NSString *)hueName
{
    return [self objectForKey:KEY_HUENAME];
}

-(void)setHueName:(NSString *)hueName
{
    [self setObject:hueName forKey:KEY_HUENAME];
    [self synchronize];
}

-(NSString *)appUsername
{
    NSString *appUsername = [self objectForKey:KEY_APPUSERNAME];
    if (!appUsername)
    {
        appUsername = [DPHue generateUsername];
        [self setObject:appUsername forKey:KEY_APPUSERNAME];
        [self synchronize];
    }
    return appUsername;
}

-(NSArray *)lampNumbers
{
    return [self objectForKey:KEY_LAMPNUMBERS];
}

-(void)setLampNumbers:(NSArray *)lampNumbers
{
    [self setObject:lampNumbers forKey:KEY_LAMPNUMBERS];
    [self synchronize];
}

-(NSArray *)flickrUsers
{
    return [self objectForKey:KEY_FLICKRUSERS];
}

-(void)setFlickrUsers:(NSArray *)flickrUsers
{
    if (flickrUsers)
    {
        [self setObject:flickrUsers forKey:KEY_FLICKRUSERS];
    }
    else
    {
        [self removeObjectForKey:KEY_FLICKRUSERS];
    }
    [self synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:VPHSavedFlickrUserListUpdatedNotification object:self];
}

-(void)addFlickrUsersObject:(NSString *)object
{
    NSMutableArray *flickrUsers = [self.flickrUsers mutableCopy];
    if (flickrUsers)
    {
        if ([flickrUsers containsObject:object])
        {
            [flickrUsers removeObject:object];
        }
        [flickrUsers insertObject:object atIndex:0];
        while (flickrUsers.count > MAX_FLICKER_USERS)
        {
            [flickrUsers removeLastObject];
        }
        self.flickrUsers = flickrUsers;
    }
    else
    {
        self.flickrUsers = @[object];
    }
}

@end
