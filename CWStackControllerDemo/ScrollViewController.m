//
//  ScrollViewController.m
//  CWStackControllerDemo
//
//  Created by Guojiubo on 14-10-1.
//  Copyright (c) 2014年 CocoaWind. All rights reserved.
//

#import "ScrollViewController.h"
#import "CWStackProtocol.h"

@interface ScrollViewController () <UIScrollViewDelegate>

@end

@implementation ScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView setContentSize:CGSizeMake(1000, 1000)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.stackController setContentScrollView:self.scrollView];
}

- (UIViewController *)nextViewController
{
    return [[[self class] alloc] init];
}

@end
