//
//  TweetsViewController.h
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Define.h"


typedef NS_ENUM(NSInteger, TIMELINE_TYPE) {
    TIMELINE_TYPE_HOME = 0,
    TIMELINE_TYPE_MENTIONS
};


@interface TweetsViewController : UIViewController
- (id) initWithUser:(User*)user;
- (id) initWithUser: (User *)user andTimelineType:(TIMELINE_TYPE)type;
@end
