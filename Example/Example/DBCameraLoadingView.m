//
//  DBCameraLoadingView.m
//  DBCamera
//
//  Created by Marco De Nadai on 23/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraLoadingView.h"

@implementation DBCameraLoadingView

#define RGBColor(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:10];
        [self setBackgroundColor:RGBColor(0x000000, .7)];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
            
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity setCenter:(CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) }];
        [self addSubview:activity];
        [activity startAnimating];
    }
    return self;
}


@end
