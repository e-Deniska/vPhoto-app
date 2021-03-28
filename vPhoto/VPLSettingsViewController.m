//
//  VPLSettingsViewController.m
//  vPlaces
//
//  Created by Danis Tazetdinov on 16.11.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPLSettingsViewController.h"
#import "VPLLampSelectViewController.h"

@interface VPLSettingsViewController() <VPLLampSelectViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *chooseLightsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *photoFitCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *photoFillCell;
@property (weak, nonatomic) IBOutlet UISlider *durationSlider;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

- (IBAction)durationSliderChanged:(UISlider *)sender;

@end

@implementation VPLSettingsViewController

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.durationSlider.value = [NSUserDefaults standardUserDefaults].slideDuration;
    [self updateDurationLabel];
    [self updatePhotoCellsSelection];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    unsigned long numberOfLamps = [NSUserDefaults standardUserDefaults].lampNumbers.count;
    self.chooseLightsCell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"[%ld lamps]",
                                                                                              @"N lamps"),
                                                  numberOfLamps];
//    if (numberOfLamps)
//    {
//        self.chooseLightsCell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"[%ld lamps]",
//                                                                                                  @"N lamps"),
//                                                      numberOfLamps];
//    }
//    else
//    {
//        self.chooseLightsCell.detailTextLabel.text = NSLocalizedString(@"[no lamps]", @"No lamps are selected");
//    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"ChooseLamps"])
    {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        return (self.hue != nil);
    }
    else
    {
        return YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChooseLamps"])
    {
        VPLLampSelectViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.hue = self.hue;
        
    }
}

-(void)lampSelectViewControllerDidSave:(VPLLampSelectViewController *)sender
{
    [self.navigationController popToViewController:self animated:YES];
}

- (IBAction)durationSliderChanged:(UISlider *)sender
{
    [NSUserDefaults standardUserDefaults].slideDuration = sender.value;
    [self updateDurationLabel];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [NSUserDefaults standardUserDefaults].photoFillsScreen = (indexPath.row == 1);
        [self updatePhotoCellsSelection];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)updateDurationLabel
{
    self.durationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"[%d sec]", @"Photo duration seconds label"),
                               (int16_t)[NSUserDefaults standardUserDefaults].slideDuration];
}

-(void)updatePhotoCellsSelection
{
    BOOL fills = [NSUserDefaults standardUserDefaults].photoFillsScreen;
    self.photoFillCell.accessoryType = fills ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.photoFitCell.accessoryType = fills ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
}

@end
