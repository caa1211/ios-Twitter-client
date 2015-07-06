//
//  MenuViewController.h
//  ios-Twitter
//
//  Created by Carter Chang on 7/6/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "User.h"
#import "TweetsViewController.h"

@interface MenuViewController : UIViewController 
    -(id) initWithUser:(User*)user;
@end
