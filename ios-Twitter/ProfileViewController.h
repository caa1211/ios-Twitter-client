//
//  ProfileViewController.h
//  ios-Twitter
//
//  Created by Carter Chang on 7/7/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface ProfileViewController : UIViewController
-(id) initWithUser:(User*)user;
-(id) initWithUser:(User*)user andLoginUser:(User*)user;

@end
