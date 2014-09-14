//
//  TableViewController.m
//  CWStackControllerDemo
//
//  Created by Guojiubo on 14-9-14.
//  Copyright (c) 2014年 CocoaWind. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController () <CWStackProtocol>

@property (nonatomic, strong) NSArray *menus;

@end

@implementation TableViewController

static NSString *reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[self tableView] bounds].size.width, 64)];
    [counterLabel setTextColor:[self randomColor]];
    [counterLabel setFont:[UIFont boldSystemFontOfSize:28]];
    [counterLabel setTextAlignment:NSTextAlignmentCenter];
    [[self tableView] setTableHeaderView:counterLabel];
    
    NSUInteger index = [[self.stackController viewControllers] indexOfObject:self];
    [counterLabel setText:[@(index) stringValue]];
    
    [self setMenus:@[@"Push", @"Pop", @"Pop to specific", @"Pop to root"]];
    
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
}

- (UIColor *)randomColor
{
    NSUInteger r, g, b;
    r = arc4random_uniform(256);
    g = arc4random_uniform(256);
    b = arc4random_uniform(256);
    
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

#pragma mark - FSStack

- (UIViewController *)nextViewController
{
    return [[TableViewController alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self menus] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [[cell textLabel] setText:[self menus][[indexPath row]]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch ([indexPath row]) {
        case 0:
        {
            UIViewController *next = [self nextViewController];
            [self.stackController pushViewController:next animated:YES];
        }
            break;
        case 1:
        {
            [self.stackController popViewControllerAnimated:YES];
        }
            break;
        case 2:
        {
            NSUInteger count = [[[self stackController] viewControllers] count];
            NSInteger randomIndex = arc4random_uniform((u_int32_t)count);
            UIViewController *randomViewController = [[self stackController] viewControllers][randomIndex];
            [self.stackController popToViewController:randomViewController animated:YES];
        }
            break;
        case 3:
        {
            [self.stackController popToRootViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

@end
