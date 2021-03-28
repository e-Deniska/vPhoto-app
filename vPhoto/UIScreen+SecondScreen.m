//
//  UIScreen+SecondScreen.m
//  vPhoto
//
//  Created by Danis Tazetdinov on 22.12.13.
//  Copyright (c) 2013 Danis Tazetdinov. All rights reserved.
//

#import "UIScreen+SecondScreen.h"

@implementation UIScreen (SecondScreen)

+(instancetype)secondScreen
{
    if ([UIScreen screens].count > 1)
    {
        return [[UIScreen screens] lastObject];
    }
    else
    {
        return nil;
    }
}

@end
