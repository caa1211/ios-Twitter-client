//
//  ProfileViewController2.h
//  ios-Twitter
//
//  Created by Carter Chang on 7/11/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"

@interface ProfileViewController2 : UIViewController
-(id) initWithUser:(User*)user;
-(id) initWithUser:(User*)user andLoginUser:(User*)user;

@end
