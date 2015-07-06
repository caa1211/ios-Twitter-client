//
//  MentionsController.m
//  ios-Twitter
//
//  Created by Carter Chang on 7/7/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "MentionsController.h"

@interface MentionsController () <SlideNavigationControllerDelegate>

@end

@implementation MentionsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Mentions";
    
    UIImage *menuImg = [Define fontImage:NIKFontAwesomeIconBars rgbaValue:0xffffff];
    UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithImage:menuImg style:UIBarButtonItemStylePlain target:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu)];
    
    [SlideNavigationController sharedInstance].leftBarButtonItem = menuBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

@end
