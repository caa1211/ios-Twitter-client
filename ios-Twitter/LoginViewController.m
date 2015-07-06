//
//  LoginViewController.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "TweetsViewController.h"
#import "SlideNavigationController.h"
#import "MenuViewController.h"
@interface LoginViewController () <SlideNavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIcon;
@property (strong, nonatomic) CABasicAnimation *fade;
@end

@implementation LoginViewController

- (IBAction)onLogin:(id)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user != nil) {
            NSLog(@"User %@ loggin", user.name);
            [User setCurrentUser:user];

            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[[TweetsViewController alloc] initWithUser:user]
                                                                     withSlideOutAnimation:NO
                                                                     andCompletion:nil];
        }else {
            // Present error view;
        }
    }];

}

- (UIImage *) loadImageforURLString:(NSString*)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

-(void) loadBackgroundImage{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self loadImageforURLString: @"https://farm3.staticflickr.com/2911/14178966435_abe4f2b16a_b.jpg"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundView.image = image;
            
            [self.twitterIcon.layer addAnimation:self.fade forKey:@"fade"];
            [self.twitterIcon setAlpha:1.0];
            [self.backgroundView.layer addAnimation:self.fade forKey:@"fade"];
        });
    });
}

- (void)rotateImageView:(UIImageView*)imageView angle:(CGFloat)angle
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [imageView setTransform:CGAffineTransformRotate(imageView.transform, angle)];
    }completion:^(BOOL finished){
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    
    self.title = @"";
    
    [[SlideNavigationController sharedInstance] setNavigationBarHidden:YES];
    
    self.twitterIcon.image = [UIImage imageNamed:@"Twitter_logo_blue_48.png" ];

    self.fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    self.fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.fade.fromValue = [NSNumber numberWithFloat:0.0f];
    self.fade.toValue = [NSNumber numberWithFloat:1.0f];
    self.fade.duration = 0.5f;

    [self.twitterIcon setAlpha:0.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


@end
