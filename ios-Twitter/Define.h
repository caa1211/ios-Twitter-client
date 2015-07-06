//
//  Define.h
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

#import "SlideNavigationController.h"
#import "MenuViewController.h"
#import "TweetsViewController.h"
#import "ProfileViewController.h"
#import "MentionsController.h"

extern NSString * const PostNewTweetNotification;
extern NSString * const UpdateTweetNotification;
extern NSString * const DestroyTweetNotification;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@interface Define : NSObject
+ (UIImage *) fontImage:(NIKFontAwesomeIcon)icon rgbaValue:(unsigned)rgbaValue;
+ (UIImage *) fontImage:(NIKFontAwesomeIcon)icon;
@end
