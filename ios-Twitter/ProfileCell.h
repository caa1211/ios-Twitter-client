//
//  ProfileCell.h
//  ios-Twitter
//
//  Created by Carter Chang on 7/11/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"

@interface ProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileBackground;
-(void) setUser:(User *)user;
@end
