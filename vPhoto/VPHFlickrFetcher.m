//
//  VPHFlickrFetcher.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 19.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

// Flickr account:
// Key:
// ffb1fca0b151cc822dcdb0942a8b7b6e
//
// Secret:
// 417d9e9ef0b35829

#define FLICKR_API_KEY @"ffb1fca0b151cc822dcdb0942a8b7b6e"

#import "VPHFlickrFetcher.h"

@interface VPHFlickrFetcher()

@property (nonatomic, readonly) NSURLSession *session;

@end

@implementation VPHFlickrFetcher

-(NSURLSession *)session
{
    static dispatch_once_t onceToken;
    static NSURLSession * _session;
    dispatch_once(&onceToken, ^{
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    });

    return _session;
}

-(NSURL*)URLWithMethod:(NSString*)method parameters:(NSString*)parameters
{
    NSMutableString *query = [NSMutableString string];
    [query appendFormat:@"https://api.flickr.com/services/rest/?method=%@", method];
    [query appendFormat:@"&format=json&nojsoncallback=1&api_key=%@", FLICKR_API_KEY];
    if (parameters.length)
    {
        [query appendString:@"&"];
        [query appendString:parameters];
    }
    
    return [NSURL URLWithString:[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


+(instancetype)sharedFetcher
{
    static dispatch_once_t onceToken;
    static id _fetcher;
    dispatch_once(&onceToken, ^{
        _fetcher = [[self alloc] init];
    });
    return _fetcher;
}

#define FLICKR_USER_DICTIONARY @"user"

#define FLICKR_METHOD_GETUSER @"flickr.people.findByUsername"
-(void)findUserWithName:(NSString*)userName completion:(VPHFlickrUserCompletion)completionBlock
{
    if (!completionBlock)
    {
        return;
    }
    VPHFlickrUserCompletion completion = [completionBlock copy];
    NSURL *queryURL = [self URLWithMethod:FLICKR_METHOD_GETUSER
                               parameters:[NSString stringWithFormat:@"username=%@", userName]];
    NSURLRequest *request = [NSURLRequest requestWithURL:queryURL];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         //DLog(@"got response %@, %@", response, error);
                         if (!error)
                         {
                             NSError * __autoreleasing jsonError;
                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                             //DLog(@"%@, %@", json, jsonError);
                             
                             if ((json) && (!error))
                             {
                                 VPHFlickrUser *user = [VPHFlickrUser flickrUserUsingDictionary:[json valueForKeyPath:FLICKR_USER_DICTIONARY]];
                                 completion(user);
                             }
                             else
                             {
                                 completion(nil);
                             }
                         }
                         else
                         {
                             completion(nil);
                         }
                         
                     }] resume];
}

#define FLICKR_METHOD_GETUSEREMAIL @"flickr.people.findByEmail"
-(void)findUserWithEmail:(NSString *)email completion:(VPHFlickrUserCompletion)completionBlock
{
    if (!completionBlock)
    {
        return;
    }
    VPHFlickrUserCompletion completion = [completionBlock copy];
    NSURL *queryURL = [self URLWithMethod:FLICKR_METHOD_GETUSEREMAIL
                               parameters:[NSString stringWithFormat:@"find_email=%@", email]];
    NSURLRequest *request = [NSURLRequest requestWithURL:queryURL];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         //DLog(@"got response %@, %@", response, error);
                         if (!error)
                         {
                             NSError * __autoreleasing jsonError;
                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                             //DLog(@"%@, %@", json, jsonError);
                             
                             if ((json) && (!error))
                             {
                                 VPHFlickrUser *user = [VPHFlickrUser flickrUserUsingDictionary:[json valueForKeyPath:FLICKR_USER_DICTIONARY]];
                                 completion(user);
                             }
                             else
                             {
                                 completion(nil);
                             }
                         }
                         else
                         {
                             completion(nil);
                         }
                         
                     }] resume];
}

#define FLICKR_METHOD_GETPHOTOSETS @"flickr.photosets.getList"
#define FLICKR_PHOTOSETS @"photosets.photoset"

-(void)getPhotosetsOfUser:(VPHFlickrUser *)user completion:(VPHFlickrPhotosetsCompletion)completionBlock
{
    if (!completionBlock)
    {
        return;
    }
    VPHFlickrUserCompletion completion = [completionBlock copy];
    NSURL *queryURL = [self URLWithMethod:FLICKR_METHOD_GETPHOTOSETS
                               parameters:[NSString stringWithFormat:@"user_id=%@", user.userID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:queryURL];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         //DLog(@"got response %@, %@", response, error);
                         if (!error)
                         {
                             NSError * __autoreleasing jsonError;
                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                             //DLog(@"%@, %@", json, jsonError);
                             
                             if ((json) && (!error))
                             {
                                 NSArray *photosetDicts = [json valueForKeyPath:FLICKR_PHOTOSETS];
                                 NSMutableArray *photosets = [NSMutableArray arrayWithCapacity:photosetDicts.count];
                                 for (NSDictionary *photosetDict in photosetDicts)
                                 {
                                     [photosets addObject:[VPHFlickrPhotoset flickrPhotosetUsingDictionary:photosetDict]];
                                 }
                                 
                                 completion([photosets copy]);
                             }
                             else
                             {
                                 completion(nil);
                             }
                         }
                         else
                         {
                             completion(nil);
                         }
                         
                     }] resume];
}

#define FLICKR_METHOD_GETUSERPHOTOS @"flickr.people.getPublicPhotos"
#define FLICKR_USER_PHOTOS @"photos.photo"
-(void)getPhotosOfUser:(VPHFlickrUser *)user completion:(VPHFlickrPhotosCompletion)completionBlock
{
    if (!completionBlock)
    {
        return;
    }
    VPHFlickrPhotosCompletion completion = [completionBlock copy];
    NSURL *queryURL = [self URLWithMethod:FLICKR_METHOD_GETUSERPHOTOS
                               parameters:[NSString stringWithFormat:@"user_id=%@&per_page=500&extras=original_format&media=photos", user.userID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:queryURL];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         //DLog(@"got response %@, %@", response, error);
                         if (!error)
                         {
                             NSError * __autoreleasing jsonError;
                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                             //DLog(@"%@, %@", json, jsonError);
                             
                             if ((json) && (!error))
                             {
                                 completion([self parsePhotoDictionaryArray:[json valueForKeyPath:FLICKR_USER_PHOTOS]]);
                             }
                             else
                             {
                                 completion(nil);
                             }
                         }
                         else
                         {
                             completion(nil);
                         }
                         
                     }] resume];
}

#define FLICKR_METHOD_GETPHOTOSETPHOTOS @"flickr.photosets.getPhotos"
#define FLICKR_PHOTOSET_PHOTOS @"photoset.photo"
-(void)getPhotosInPhotoset:(VPHFlickrPhotoset*)photoset completion:(VPHFlickrPhotosCompletion)completionBlock
{
    if (!completionBlock)
    {
        return;
    }
    VPHFlickrPhotosCompletion completion = [completionBlock copy];
    NSURL *queryURL = [self URLWithMethod:FLICKR_METHOD_GETPHOTOSETPHOTOS
                               parameters:[NSString stringWithFormat:@"photoset_id=%@&per_page=500&extras=original_format&media=photos", photoset.photosetID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:queryURL];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         //DLog(@"got response %@, %@", response, error);
                         if (!error)
                         {
                             NSError * __autoreleasing jsonError;
                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                             //DLog(@"%@, %@", json, jsonError);
                             
                             if ((json) && (!error))
                             {
                                 completion([self parsePhotoDictionaryArray:[json valueForKeyPath:FLICKR_PHOTOSET_PHOTOS]]);
                             }
                             else
                             {
                                 completion(nil);
                             }
                         }
                         else
                         {
                             completion(nil);
                         }
                         
                     }] resume];
}

#define FLICKR_METHOD_GETRECENT @"flickr.photos.getRecent"
#define FLICKR_RECENT_PHOTOS @"photos.photo"
-(void)getRecentPhotosWithCompletion:(VPHFlickrPhotosCompletion)completionBlock
{
    if (!completionBlock)
    {
        return;
    }
    VPHFlickrPhotosCompletion completion = [completionBlock copy];
    NSURL *queryURL = [self URLWithMethod:FLICKR_METHOD_GETRECENT
                               parameters:[NSString stringWithFormat:@"per_page=500&extras=original_format"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:queryURL];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         //DLog(@"got response %@, %@", response, error);
                         if (!error)
                         {
                             NSError * __autoreleasing jsonError;
                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                             //DLog(@"%@, %@", json, jsonError);
                             
                             if ((json) && (!error))
                             {
                                 completion([self parsePhotoDictionaryArray:[json valueForKeyPath:FLICKR_RECENT_PHOTOS]]);
                             }
                             else
                             {
                                 completion(nil);
                             }
                         }
                         else
                         {
                             completion(nil);
                         }
                         
                     }] resume];
}

#define FLICKR_METHOD_GETINTERESTING @"flickr.interestingness.getList"
#define FLICKR_INTERESTING_PHOTOS @"photos.photo"
-(void)getInterestingPhotosWithCompletion:(VPHFlickrPhotosCompletion)completionBlock
{
    if (!completionBlock)
    {
        return;
    }
    VPHFlickrPhotosCompletion completion = [completionBlock copy];
    NSURL *queryURL = [self URLWithMethod:FLICKR_METHOD_GETINTERESTING
                               parameters:[NSString stringWithFormat:@"per_page=500&extras=original_format"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:queryURL];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         //DLog(@"got response %@, %@", response, error);
                         if (!error)
                         {
                             NSError * __autoreleasing jsonError;
                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                             //DLog(@"%@, %@", json, jsonError);
                             
                             if ((json) && (!error))
                             {
                                 completion([self parsePhotoDictionaryArray:[json valueForKeyPath:FLICKR_INTERESTING_PHOTOS]]);
                             }
                             else
                             {
                                 completion(nil);
                             }
                         }
                         else
                         {
                             completion(nil);
                         }
                         
                     }] resume];
}


-(NSArray*)parsePhotoDictionaryArray:(NSArray*)dictArray
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:dictArray.count];
    for (NSDictionary *dict in dictArray)
    {
        VPHFlickrPhoto *photo = [VPHFlickrPhoto flickrPhotoUsingDictionary:dict];
        if (photo)
        {
            [result addObject:photo];
        }
    }
    return [result copy];
}

@end
