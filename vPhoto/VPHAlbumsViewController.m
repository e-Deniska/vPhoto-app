//
//  VPHAlbumsViewController.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 18.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

@import AssetsLibrary;

#import "VPHAlbumsViewController.h"
#import "VPHAlbumCell.h"
#import "VPHFlickrCell.h"
#import "VPHMenuSectionHeaderView.h"

#import "VPHFlickrFetcher.h"

#import "DPHue.h"
#import "DPHueLight.h"

#import "VPLDiscoveryViewController.h"
#import "VPLSettingsViewController.h"
#import "VPHSlideshowViewController.h"
#import "VPHFlickrUserSearchViewController.h"

#import "VPHSecondWindow.h"

@interface VPHAlbumsViewController () <VPLDiscoveryViewControllerDelegate, VPHSlideshowViewControllerDataSource>

@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) NSArray *albums;
@property (nonatomic, assign) BOOL enumeratingAlbums;

@property (strong, nonatomic) ALAssetsGroup *currentAlbum;
@property (assign, nonatomic) NSInteger currentAlbumPhotoIndex;

@property (nonatomic, strong) NSArray *flickrPhotos;
@property (nonatomic, assign) NSInteger currentFlickrPhotoIndex;
@property (nonatomic, strong) UIImage *currentFlickrPhotoImage;

@property (nonatomic, assign) BOOL showingFlickr;

@property (nonatomic, strong) NSArray *savedFlickrUsers;

@property (nonatomic, strong) DPHue *hue;

@property (nonatomic, assign) BOOL shouldReconnect;

@property (nonatomic, weak) CAGradientLayer *backgroundGradientLayer;

@end

@implementation VPHAlbumsViewController

-(void)updateLocalAlbums
{
    self.albums = nil;
    NSMutableArray *albums = [NSMutableArray array];
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    if (group)
                                    {
                                        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                        if (group.numberOfAssets)
                                        {
                                            [albums addObject:group];
                                        }
                                    }
                                    else
                                    {
                                        self.albums = [albums copy];
                                        self.enumeratingAlbums = NO;
                                        [self.collectionView reloadData];
                                    }
                                }
                              failureBlock:^(NSError *error) {
                                  self.enumeratingAlbums = NO;
//                                  [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                  [self.collectionView reloadData];
                              }];
    
    self.enumeratingAlbums = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[ (id)[UIColor whiteColor].CGColor, (id)[UIColor tintColor].CGColor ];
    self.collectionView.backgroundView = [[UIView alloc] init];
    [self.collectionView.backgroundView.layer insertSublayer:gradientLayer atIndex:0];
    self.backgroundGradientLayer = gradientLayer;
    
    self.shouldReconnect = YES;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        UIImage *background = [UIImage imageNamed:@"background"];
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.collectionView.frame];
//        imageView.contentMode = UIViewContentModeCenter;
//        imageView.image = background;
//        self.collectionView.backgroundView = imageView;
//    }
//    else
//    {
//        UIImage *background = [UIImage imageNamed:@"backgroundPad"];
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.collectionView.frame];
//        imageView.contentMode = UIViewContentModeCenter;
//        imageView.image = background;
//        self.collectionView.backgroundView = imageView;
//        
//    }
    self.library = [[ALAssetsLibrary alloc] init];
    
    [self updateLocalAlbums];
    [[VPHSecondWindow secondWindow] connectWindowIfPossible];
    // Do any additional setup after loading the view.
    
    self.savedFlickrUsers = [NSUserDefaults standardUserDefaults].flickrUsers;
    [[NSNotificationCenter defaultCenter] addObserverForName:VPHSavedFlickrUserListUpdatedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      DLog(@"flickr users updated");
                                                      self.savedFlickrUsers = [NSUserDefaults standardUserDefaults].flickrUsers;
                                                      [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      DLog(@"on open refreshing local libraries");
                                                      [self updateLocalAlbums];
//                                                      [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                      [self.collectionView reloadData];
                                                  }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat maxDimension = MAX(self.collectionView.layer.bounds.size.height,
                               self.collectionView.layer.bounds.size.width);
    
    self.backgroundGradientLayer.frame = CGRectMake(self.collectionView.backgroundView.layer.bounds.origin.x,
                                                    self.collectionView.backgroundView.layer.bounds.origin.y,
                                                    maxDimension,
                                                    maxDimension);
    self.backgroundGradientLayer.locations = @[ @(0.0f),
                                                @(self.collectionView.layer.bounds.size.height / maxDimension) ];
    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration
{
    self.backgroundGradientLayer.locations = @[ @(0.0f),
                                                @( self.collectionView.layer.bounds.size.height /
                                                   self.backgroundGradientLayer.bounds.size.height ) ];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ((!self.hue) && (self.shouldReconnect))
    {
        [self performSegueWithIdentifier:@"DiscoverHues" sender:nil];
        self.shouldReconnect = NO;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSettings"])
    {
        VPLSettingsViewController *vc = (VPLSettingsViewController *)[segue.destinationViewController topViewController];
        vc.hue = self.hue;
    }
    else if ([segue.identifier isEqualToString:@"DiscoverHues"])
    {
        VPLDiscoveryViewController *vc = (VPLDiscoveryViewController *)[segue.destinationViewController topViewController];
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ShowAlbumSlideshow"])
    {
        self.showingFlickr = NO;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        self.currentAlbum = self.albums[indexPath.item];
        self.currentAlbumPhotoIndex = 0;
        
        NSArray *lampNumbers = [NSUserDefaults standardUserDefaults].lampNumbers;
        NSMutableArray *lamps = [NSMutableArray arrayWithCapacity:lampNumbers.count];
        for (DPHueLight *light in self.hue.lights)
        {
            if ([lampNumbers containsObject:light.number])
            {
                [lamps addObject:light];
//                light.on = YES;
//                [light write];
            }
        }
        VPHSlideshowViewController *vc = segue.destinationViewController;
        vc.dataSource = self;
        vc.lamps = lamps;
    }
    else if ([segue.identifier isEqualToString:@"ShowFlickrRecentSlideshow"])
    {
        self.showingFlickr = YES;
        NSArray *lampNumbers = [NSUserDefaults standardUserDefaults].lampNumbers;
        NSMutableArray *lamps = [NSMutableArray arrayWithCapacity:lampNumbers.count];
        self.currentFlickrPhotoIndex = 0;
        self.currentFlickrPhotoImage = nil;
        for (DPHueLight *light in self.hue.lights)
        {
            if ([lampNumbers containsObject:light.number])
            {
                [lamps addObject:light];
//                light.on = YES;
//                [light write];
            }
        }
        VPHSlideshowViewController *vc = segue.destinationViewController;
        vc.dataSource = self;
        vc.lamps = lamps;
        [[VPHFlickrFetcher sharedFetcher] getInterestingPhotosWithCompletion:^(NSArray *photos) {
            self.flickrPhotos = photos;
            DLog(@"got %lu photos", (unsigned long)photos.count);
            [[self.flickrPhotos firstObject] loadPhotoWithFormat:VPHFlickrPhotoFormatOriginal
                                                      completion:^(UIImage *photo) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (photo)
                                                              {
                                                                  self.currentFlickrPhotoImage = photo;
                                                              }
                                                              else
                                                              {
                                                                  self.currentFlickrPhotoIndex = -1;
                                                              }
                                                          });
                                                      }];
            self.currentFlickrPhotoIndex++;
        }];
    }
    else if ([segue.identifier isEqualToString:@"ShowFlickrUserSearch"])
    {
        VPHFlickrUserSearchViewController *vc = segue.destinationViewController;
        vc.hue = self.hue;
    }
    else if ([segue.identifier isEqualToString:@"ShowSavedFlickrUser"])
    {
        VPHFlickrUserSearchViewController *vc = segue.destinationViewController;
        VPHAlbumCell *cell = sender;
        vc.flickrUserName = cell.flickrUserName;
        vc.hue = self.hue;
    }
}

-(void)discoveryViewController:(VPLDiscoveryViewController *)sender didConnectToHue:(DPHue *)hue
{
    self.hue = hue;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)discoveryViewControllerDidFail:(VPLDiscoveryViewController *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"[Hue not found title]",
                                                              @"Hue not found title")
                                    message:NSLocalizedString(@"[Hue not found message]",
                                                              @"Hue not found message")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"[Ok]", @"Ok button title")
                          otherButtonTitles:nil] show];
    }];
}

-(void)discoveryViewControllerDidCancel:(VPLDiscoveryViewController *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)dismissSettings:(UIStoryboardSegue*)sender
{
    
}

-(IBAction)dismissSettingsAndReconnectToHue:(UIStoryboardSegue*)sender
{
    self.hue = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self performSegueWithIdentifier:@"DiscoverHues" sender:self];
    }
    else
    {
        self.shouldReconnect = YES;
    }
}

-(IBAction)dismissSettingsAndClearFlickrUserList:(UIStoryboardSegue*)sender
{
    [NSUserDefaults standardUserDefaults].flickrUsers = nil;
}


-(IBAction)dismissSlideshow:(UIStoryboardSegue*)sender
{
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            if (self.enumeratingAlbums)
            {
                return 1;
            }
            else
            {
                return self.albums.count;
            }
            
        case 1:
            return 2 + self.savedFlickrUsers.count;
            
        default:
            return NSNotFound;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (self.enumeratingAlbums)
        {
            return [collectionView dequeueReusableCellWithReuseIdentifier:@"LoadingCell" forIndexPath:indexPath];
        }
        else
        {
            VPHAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell"
                                                                           forIndexPath:indexPath];
            ALAssetsGroup *group = self.albums[indexPath.item];
            cell.title.text = [group valueForProperty:ALAssetsGroupPropertyName];
            cell.coverImage.image = [UIImage imageWithCGImage:group.posterImage];
            
            return cell;
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            return [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrRecentCell" forIndexPath:indexPath];
        }
        else if (indexPath.row == 1)
        {
            return [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrSearchCell" forIndexPath:indexPath];
        }
        else
        {
            NSString *userName = self.savedFlickrUsers[indexPath.row - 2];
            VPHFlickrCell *cell = (VPHFlickrCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrUserCell"
                                                                                           forIndexPath:indexPath];
            cell.title.text = userName;
            cell.flickrUserName = userName;
            return cell;
        }
    }
    else
    {
        return nil;
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath
{
    VPHMenuSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                          withReuseIdentifier:@"SectionHeader"
                                                                                 forIndexPath:indexPath];
    switch (indexPath.section)
    {
        case 0:
            header.title.text = NSLocalizedString(@"[Photo albums section]", @"Photo albums section");
            break;
            
        case 1:
            header.title.text = NSLocalizedString(@"[Flickr section]", @"Flickr section");
            break;
            
            
        default:
            break;
    }
    
    return header;
}

-(BOOL)isNextImageAvailableForSlideshowController:(VPHSlideshowViewController *)slideshow
{
    if (self.showingFlickr)
    {
        return ((self.currentFlickrPhotoIndex >= 0) &&
                ((self.currentFlickrPhotoIndex == 0) ||
                 (self.currentFlickrPhotoIndex < self.flickrPhotos.count)));
    }
    else
    {
        DLog(@"%lld of %lld", (long long)self.currentAlbumPhotoIndex, (long long)self.currentAlbum.numberOfAssets);
        return self.currentAlbumPhotoIndex < self.currentAlbum.numberOfAssets;
    }
}

-(BOOL)isNextImageReadyForSlideshowController:(VPHSlideshowViewController*)slideshow
{
    if (self.showingFlickr)
    {
        return self.currentFlickrPhotoImage != nil;
    }
    else
    {
        return YES;
    }
}

-(UIImage *)nextImageForSlideshowController:(VPHSlideshowViewController *)slideshow
{
    if (self.showingFlickr)
    {
        UIImage *currentImage = self.currentFlickrPhotoImage;
        self.currentFlickrPhotoImage = nil;
        VPHFlickrPhoto *photo = self.flickrPhotos[self.currentFlickrPhotoIndex++];
        [photo loadPhotoWithFormat:VPHFlickrPhotoFormatOriginal
                        completion:^(UIImage *photo) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (photo)
                                {
                                    self.currentFlickrPhotoImage = photo;
                                    self.currentFlickrPhotoIndex++;
                                }
                                else
                                {
                                    self.currentFlickrPhotoImage = nil;
                                    self.currentFlickrPhotoIndex = -1;
                                }
                            });
                        }];
        
        return currentImage;
    }
    else
    {
        UIImage * __block image;
        [self.currentAlbum enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if ((index == self.currentAlbumPhotoIndex) && (result))
            {
                CGImageRef imageRef = result.defaultRepresentation.fullResolutionImage;
                image = [UIImage imageWithCGImage:imageRef
                                            scale:result.defaultRepresentation.scale
                                      orientation:[self imageOrientationWithAssetOrientation:result.defaultRepresentation.orientation]];
            }
        }];
        
        self.currentAlbumPhotoIndex++;
        return image;
    }
}

-(UIImageOrientation)imageOrientationWithAssetOrientation:(ALAssetOrientation)assetOrientation
{
    switch (assetOrientation)
    {
        case ALAssetOrientationUp:
            return UIImageOrientationUp;
            
        case ALAssetOrientationUpMirrored:
            return UIImageOrientationUpMirrored;
            
        case ALAssetOrientationDown:
            return UIImageOrientationDown;
            
        case ALAssetOrientationDownMirrored:
            return UIImageOrientationDownMirrored;
            
        case ALAssetOrientationLeft:
            return UIImageOrientationLeft;
            
        case ALAssetOrientationLeftMirrored:
            return UIImageOrientationLeftMirrored;
            
        case ALAssetOrientationRight:
            return UIImageOrientationRight;
            
        case ALAssetOrientationRightMirrored:
            return UIImageOrientationRightMirrored;
            
        default:
            return UIImageOrientationUp;
    }
}

@end
