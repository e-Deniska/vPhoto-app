//
//  VPHFlickrUserSearchViewController.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 22.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPHFlickrUserSearchViewController.h"
#import "VPHFlickrFetcher.h"
#import "VPHAlbumCell.h"
#import "VPHMenuSectionHeaderView.h"
#import "VPHSlideshowViewController.h"
#import "DPHueLight.h"

@interface VPHFlickrUserSearchViewController () <UISearchBarDelegate, VPHSlideshowViewControllerDataSource>

@property (nonatomic, strong) NSArray *photosets;
@property (nonatomic, strong) VPHFlickrUser *user;

@property (nonatomic, strong) NSArray *flickrPhotos;
@property (nonatomic, assign) NSInteger selectedFlickrIndex;
@property (nonatomic, strong) UIImage *currentFlickrImage;

@property (nonatomic, assign) BOOL searchingFlickr;

@property (nonatomic, strong) NSCache *imageCache;

@property (nonatomic, weak) CAGradientLayer *backgroundGradientLayer;

@end

@implementation VPHFlickrUserSearchViewController

-(IBAction)dismissSlideshow:(UIStoryboardSegue*)sender
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    self.imageCache = [[NSCache alloc] init];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:self.navigationController.navigationBar.frame];
    searchBar.placeholder = NSLocalizedString(@"[Search flickr users]", @"Search flickr users title");
    searchBar.delegate = self;
    searchBar.showsCancelButton = YES;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.navigationItem.titleView = searchBar;
    if (self.flickrUserName.length)
    {
        searchBar.text = self.flickrUserName;
        self.searchingFlickr = YES;
        [self.collectionView reloadData];
        [self findFlickrUserWithUserName:self.flickrUserName];
    }
    else
    {
        [searchBar becomeFirstResponder];
    }
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    gradientLayer.colors = @[ (id)[UIColor colorWithRed:1.0f green:0.0f blue:0.467f alpha:1.0f].CGColor,
                              (id)[UIColor whiteColor].CGColor,
                              (id)[UIColor colorWithRed:0.0f green:0.36f blue:0.878f alpha:1.0f].CGColor,
                              ];
    self.collectionView.backgroundView = [[UIView alloc] initWithFrame:self.collectionView.frame];
    [self.collectionView.backgroundView.layer insertSublayer:gradientLayer atIndex:0];
    self.backgroundGradientLayer = gradientLayer;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat maxDimension = MAX(self.collectionView.layer.bounds.size.height,
                               self.collectionView.layer.bounds.size.width);
    CGFloat k = self.view.layer.bounds.size.height / maxDimension;
    self.backgroundGradientLayer.frame = CGRectMake(self.collectionView.backgroundView.layer.bounds.origin.x,
                                                    self.collectionView.backgroundView.layer.bounds.origin.y,
                                                    maxDimension,
                                                    maxDimension);
    self.backgroundGradientLayer.locations = @[ @(0.0f),
                                                @(0.5f * k),
                                                @(1.0f * k) ];
    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration
{
    CGFloat maxDimension = MAX(self.collectionView.layer.bounds.size.height,
                               self.collectionView.layer.bounds.size.width);
    CGFloat k = self.view.layer.bounds.size.height / maxDimension;
    self.backgroundGradientLayer.locations = @[ @(0.0f),
                                                @(0.5f * k),
                                                @(1.0f * k) ];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
#warning Show find activity indication
    [searchBar resignFirstResponder];
    NSString *userName = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.searchingFlickr = YES;
    [self.collectionView reloadData];
    if ([userName rangeOfString:@"@"].length > 0)
    {
        // try e-mail first
        [[VPHFlickrFetcher sharedFetcher] findUserWithEmail:userName
                                                 completion:^(VPHFlickrUser *flickrUser) {
                                                     if (flickrUser)
                                                     {
                                                         [self loadPhotosetsOfUser:flickrUser];
                                                     }
                                                     else
                                                     {
                                                         [self findFlickrUserWithUserName:userName];
                                                     }
                                                 }];
        
    }
    else
    {
        // try only username
        [self findFlickrUserWithUserName:userName];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    self.photosets = nil;
    self.searchingFlickr = NO;
    [self.imageCache removeAllObjects];
    [self.collectionView reloadData];
    [searchBar resignFirstResponder];
}


-(void)findFlickrUserWithUserName:(NSString*)userName
{
    [[VPHFlickrFetcher sharedFetcher] findUserWithName:userName
                                            completion:^(VPHFlickrUser *flickrUser) {
                                                if (flickrUser)
                                                {
                                                    [self loadPhotosetsOfUser:flickrUser];
                                                }
                                                else
                                                {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        self.searchingFlickr = NO;
                                                        [self.collectionView reloadData];
                                                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"[Flickr User Not Found]", @"Flickr user not found title")
                                                                                     message:NSLocalizedString(@"[Flickr User Not Found message]", @"Flickr user not found message")
                                                                                    delegate:nil
                                                                           cancelButtonTitle:NSLocalizedString(@"[Ok]", @"Ok button title")
                                                                          otherButtonTitles:nil] show];
                                                    });
                                                }
                                            }];
}

-(void)loadPhotosetsOfUser:(VPHFlickrUser*)user
{
    [[VPHFlickrFetcher sharedFetcher] getPhotosetsOfUser:user
                                              completion:^(NSArray *photosets) {
                                                  if (photosets)
                                                  {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.user = user;
                                                          self.photosets = photosets;
                                                          [self.imageCache removeAllObjects];
                                                          self.searchingFlickr = NO;
                                                          [self.collectionView reloadData];
                                                          
                                                          if (self.photosets.count)
                                                          {
                                                              [[NSUserDefaults standardUserDefaults] addFlickrUsersObject:user.name];
                                                          }
                                                          else
                                                          {
                                                              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"[Flickr User Empty]", @"Flickr user has no photosets title")
                                                                                          message:NSLocalizedString(@"[Flickr User Empty message]", @"Flickr user has no photosets message")
                                                                                         delegate:nil
                                                                                cancelButtonTitle:NSLocalizedString(@"[Ok]", @"Ok button title")
                                                                                otherButtonTitles:nil] show];
                                                          }
                                                          DLog(@"got %lld", (long long)self.photosets.count);
                                                      });
                                                  }
                                                  else
                                                  {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.searchingFlickr = NO;
                                                          [self.collectionView reloadData];
                                                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"[Flickr User Not Loaded]", @"Flickr user not loaded title")
                                                                                      message:NSLocalizedString(@"[Flickr User Not Loaded message]", @"Flickr user not loaded message")
                                                                                     delegate:nil
                                                                            cancelButtonTitle:NSLocalizedString(@"[Ok]", @"Ok button title")
                                                                            otherButtonTitles:nil] show];
                                                      });
                                                  }
                                              }];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.searchingFlickr ? 1 : self.photosets.count;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath
{
    VPHMenuSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                          withReuseIdentifier:@"SectionHeader"
                                                                                 forIndexPath:indexPath];
    header.title.text = self.user.name;
    
    return header;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchingFlickr)
    {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"LoadingCell" forIndexPath:indexPath];
    }
    else
    {
        VPHAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell"
                                                                       forIndexPath:indexPath];
        VPHFlickrPhotoset *photoset = self.photosets[indexPath.item];
        if ((photoset.title.length) && (photoset.details.length))
        {
            cell.title.text = [NSString stringWithFormat:@"%@ (%@)", photoset.title, photoset.details];
        }
        else if (photoset.title.length)
        {
            cell.title.text = photoset.title;
        }
        
        UIImage *image = [self.imageCache objectForKey:indexPath];
        if (image)
        {
            cell.coverImage.image = image;
        }
        else
        {
            cell.coverImage.image = [UIImage imageNamed:@"lamp"];
            
            cell.tag = indexPath.row;
            
            [photoset.photo loadPhotoWithFormat:VPHFlickrPhotoFormatSquare completion:^(UIImage *photo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (photo)
                    {
                        [self.imageCache setObject:photo forKey:indexPath];
                    }
                    
                    if (cell.tag == indexPath.row)
                    {
                        cell.coverImage.image = photo;
                    }
                });
            }];
        }
        
        return cell;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPhotosetSlideshow"])
    {
        VPHFlickrPhotoset *photoset = self.photosets[[self.collectionView indexPathForCell:sender].item];
        VPHSlideshowViewController *vc = segue.destinationViewController;
        vc.dataSource = self;
        NSArray *lampNumbers = [NSUserDefaults standardUserDefaults].lampNumbers;
        NSMutableArray *lamps = [NSMutableArray arrayWithCapacity:lampNumbers.count];
        self.selectedFlickrIndex = 0;
        for (DPHueLight *light in self.hue.lights)
        {
            if ([lampNumbers containsObject:light.number])
            {
                [lamps addObject:light];
            }
        }
        vc.dataSource = self;
        vc.lamps = lamps;
        [[VPHFlickrFetcher sharedFetcher] getPhotosInPhotoset:photoset completion:^(NSArray *photos) {
            self.flickrPhotos = photos;
            DLog(@"got %lu photos", (unsigned long)photos.count);
            [[self.flickrPhotos firstObject] loadPhotoWithFormat:VPHFlickrPhotoFormatOriginal
                                                      completion:^(UIImage *photo) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (photo)
                                                              {
                                                                  self.currentFlickrImage = photo;
                                                              }
                                                              else
                                                              {
                                                                  self.selectedFlickrIndex = -1;
                                                              }
                                                          });
                                                      }];
            self.selectedFlickrIndex++;
        }];
    }
}

-(BOOL)isNextImageAvailableForSlideshowController:(VPHSlideshowViewController *)slideshow
{
    return ((self.selectedFlickrIndex >= 0) &&
            ((self.selectedFlickrIndex == 0) ||
             (self.selectedFlickrIndex < self.flickrPhotos.count)));
}

-(BOOL)isNextImageReadyForSlideshowController:(VPHSlideshowViewController*)slideshow
{
    return self.currentFlickrImage != nil;
}

//-(NSUInteger)numberOfImagesForSlideshowController:(VPHSlideshowViewController *)slideshow
//{
//    if (self.showingFlickr)
//    {
//        return self.flickrPhotos.count;
//    }
//    else
//    {
//        DLog(@"%lld image(s)", (long long)self.selectedGroup.numberOfAssets);
//        return self.selectedGroup.numberOfAssets;
//    }
//}

-(UIImage *)nextImageForSlideshowController:(VPHSlideshowViewController *)slideshow
{
    UIImage *currentImage = self.currentFlickrImage;
    self.currentFlickrImage = nil;
    VPHFlickrPhoto *photo = self.flickrPhotos[self.selectedFlickrIndex++];
    [photo loadPhotoWithFormat:VPHFlickrPhotoFormatOriginal
                    completion:^(UIImage *photo) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (photo)
                            {
                                self.currentFlickrImage = photo;
                                self.selectedFlickrIndex++;
                            }
                            else
                            {
                                self.currentFlickrImage = nil;
                                self.selectedFlickrIndex = -1;
                            }
                        });
                    }];
    
    return currentImage;
}


@end
