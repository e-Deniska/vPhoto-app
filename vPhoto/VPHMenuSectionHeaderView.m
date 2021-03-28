//
//  VPHMenuSectionHeaderView.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 20.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "VPHMenuSectionHeaderView.h"

@implementation VPHMenuSectionHeaderView

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.masksToBounds = NO;
    //    self.layer.shadowOffset = CGSizeZero;
    //    self.layer.shadowOpacity = 1.0f;
    //    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    //    self.layer.shadowRadius = 5.0f;
    
    self.title.layer.masksToBounds = NO;
    self.title.layer.shadowOffset = CGSizeZero;
    self.title.layer.shadowOpacity = 1.0f;
    self.title.layer.shadowColor = [UIColor blackColor].CGColor;
    self.title.layer.shadowRadius = 3.0f;
    
}


@end
