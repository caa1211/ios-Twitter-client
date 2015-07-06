//
//  Define.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "Define.h"

NSString * const PostNewTweetNotification = @"PostNewTweetNotification";
NSString * const UpdateTweetNotification = @"UpdateTweetNotification";
NSString * const DestroyTweetNotification = @"DestroyTweetNotification";



@implementation Define

+ (UIImage *) fontImage:(NIKFontAwesomeIcon)icon rgbaValue:(unsigned)rgbaValue {

    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    [factory setColors:@[ UIColorFromRGB(rgbaValue)]];
    UIImage *image =  [factory createImageForIcon:icon];
    return image;
}

+ (UIImage *) fontImage:(NIKFontAwesomeIcon)icon{
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    UIImage *image =  [factory createImageForIcon:icon];
    return image;
}


@end
