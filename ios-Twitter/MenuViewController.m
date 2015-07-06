//
//  MenuViewController.m
//  ios-Twitter
//
//  Created by Carter Chang on 7/6/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()  <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

typedef NS_ENUM(NSInteger, MenuItem) {
    Profile,
    Timeline,
    Mentions,
    Logout
};

@implementation MenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DefaultCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = nil;
    
    switch (indexPath.row) {
        case Profile:
            vc = [[ProfileViewController alloc]init];
            break;
        case Timeline:
            vc = [[TweetsViewController alloc]init];
            break;
        case Mentions:
            vc = [[MentionsController alloc]init];
            break;
        case Logout:
            [User logout];
            return;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid item" userInfo:nil];
    }
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
    cell.backgroundColor = tableView.backgroundColor;
    cell.textLabel.text = [self textForItem:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor colorWithRed:0.335 green:0.632 blue:0.916 alpha:1.000];
    return cell;
}

- (NSString *)textForItem:(MenuItem)item {
    switch (item) {
        case Profile:
            return @"Profile";
        case Timeline:
            return @"Timeline";
        case Mentions:
            return @"Mentions";
        case Logout:
            return @"Sign Out";
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid item" userInfo:nil];
    }
}


@end
