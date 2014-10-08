//
//  CWStackController.h
//  CWStackControllerDemo
//
//  Created by Guojiubo on 14-9-14.
//  Copyright (c) 2014年 CocoaWind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStackProtocol.h"

@interface CWStackController : UIViewController

// Convenience method pushes the root view controller without animation.
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

// Uses a horizontal slide transition. Has no effect if the view controller is already in the stack.
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

// Returns the popped controller.
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
// Pops view controllers until the one specified is on top. Returns the popped controllers.
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
// Pops until there's only a single view controller left on the stack. Returns the popped controllers.
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

// The current view controller stack.
@property (nonatomic) NSArray *viewControllers;
// If animated is YES, then simulate a push or pop depending on whether the new top view controller was previously in the stack.
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

// The top view controller on the stack.
@property (nonatomic, readonly) UIViewController *topViewController;

// Customizations
//
// The threshold to trigger a push or pop through pan gesture.
// Default is 0.15, valid range: 0.0 to 1.0.
@property (nonatomic, assign) CGFloat threshold;
// Horizontal slide transition duration, default is 0.2
@property (nonatomic, assign) NSTimeInterval durationForAnimations;
// Shadow
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) CGFloat shadowOpacity;

- (void)setContentScrollView:(UIScrollView *)scrollView;

@end

@interface UIViewController (CWStackController)

// If this view controller has been pushed onto a stack controller, return it.
@property (nonatomic, readonly) CWStackController *stackController;

@end
