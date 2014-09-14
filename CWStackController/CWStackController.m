//
//  CWStackController.m
//  CWStackControllerDemo
//
//  Created by Guojiubo on 14-9-14.
//  Copyright (c) 2014年 CocoaWind. All rights reserved.
//

#import "CWStackController.h"

typedef NS_ENUM(NSUInteger, CWPanGestureType) {
    CWPanGestureTypeNone,
    CWPanGestureTypePush,
    CWPanGestureTypePop
};

@interface CWStackController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController *previousViewController;
@property (nonatomic, strong) UIViewController *nextViewController;
@property (nonatomic, assign) CWPanGestureType panGestureType;
@property (nonatomic, strong) UIViewController *tabBarHolder;

@end

@implementation CWStackController

- (id)init
{
    self = [super init];
    if (self) {
        // Default customization values
        _threshold = 0.15f;
        _durationForAnimations = 0.2f;
        _shadowColor = [UIColor lightGrayColor];
        _shadowOffset = CGSizeMake(-2.0f, 0.0f);
        _shadowOpacity = 0.5f;
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [self init];
    if (self) {
        [self addChildViewController:rootViewController];
        [rootViewController.view setFrame:[self contentBounds]];
        [self.view addSubview:rootViewController.view];
        [rootViewController didMoveToParentViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
}

#pragma mark - Stack

- (UIViewController *)topViewController
{
    return [self.childViewControllers lastObject];
}

- (NSArray *)viewControllers
{
    return self.childViewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [self pushViewController:[viewControllers lastObject] animated:animated];
    
    for (UIViewController *oldChild in self.childViewControllers) {
        [oldChild willMoveToParentViewController:nil];
        [oldChild removeFromParentViewController];
    }
    
    for (UIViewController *newChild in viewControllers) {
        [self addChildViewController:newChild];
        [newChild didMoveToParentViewController:self];
    }
}

- (void)pushViewController:(UIViewController *)to animated:(BOOL)animated
{
    if ([self.viewControllers containsObject:to]) {
        NSLog(@"The view controller is already in the stack, nothing to be done");
        return;
    }
    
    UIViewController *from = self.topViewController;
    
    [self addChildViewController:to];
    
    CGRect originalFrame = [self contentBounds];
    [from.view setFrame:originalFrame];
    originalFrame.origin.x = originalFrame.size.width;
    [[to view] setFrame:originalFrame];
    [self.view insertSubview:to.view aboveSubview:[from view]];
    
    // Move tabBar away with previous view
    if (self.tabBarController && ![from hidesBottomBarWhenPushed] && to.hidesBottomBarWhenPushed) {
        self.tabBarHolder = from;
        UITabBar *tabBar = [self.tabBarController tabBar];
        [[self.tabBarHolder view] addSubview:tabBar];
    }
    
    void (^animationBlock)(void) = ^(void){
        CGRect finalFrame = [self contentBounds];
        [[to view] setFrame:finalFrame];
        
        finalFrame.origin.x = -finalFrame.size.width/3;
        [[from view] setFrame:finalFrame];
    };
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        [[from view] removeFromSuperview];
        
        [to didMoveToParentViewController:self];
        
        [self addShadowToView:to.view];
    };
    
    if (animated) {
        [UIView animateWithDuration:self.durationForAnimations animations:animationBlock completion:completionBlock];
        return;
    }
    
    animationBlock();
    completionBlock(YES);
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *popedViewController = self.topViewController;
    
    NSUInteger topIndex = [self.childViewControllers indexOfObject:self.topViewController];
    if (topIndex == 0) {
        return nil;
    }
    
    UIViewController *previous = self.childViewControllers[topIndex - 1];
    
    CGRect originalFrame = [self contentBounds];
    originalFrame.origin.x = -originalFrame.size.width/3;
    [[previous view] setFrame:originalFrame];
    
    [self.view insertSubview:[previous view] belowSubview:[self.topViewController view]];
    
    void (^animationBlock)(void) = ^(void){
        CGRect finalFrame = [self contentBounds];
        finalFrame.origin.x = finalFrame.size.width;
        [[self.topViewController view] setFrame:finalFrame];
        
        finalFrame.origin.x = 0;
        [[previous view] setFrame:finalFrame];
    };
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        // Put tabBar back
        if (self.tabBarController && [previous isEqual:self.tabBarHolder]) {
            UITabBar *tabBar = [self.tabBarController tabBar];
            [[self.tabBarController view] addSubview:tabBar];
            self.tabBarHolder = nil;
        }
        
        [self.topViewController willMoveToParentViewController:nil];
        [[self.topViewController view] removeFromSuperview];
        [self.topViewController removeFromParentViewController];
    };
    
    if (animated) {
        [UIView animateWithDuration:self.durationForAnimations animations:animationBlock completion:completionBlock];
        return popedViewController;
    }
    
    animationBlock();
    completionBlock(YES);
    
    return popedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == [self topViewController]) {
        return nil;
    }
    
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    NSUInteger count = [self.viewControllers count];
    NSArray *popedViewControllers = [self.viewControllers subarrayWithRange:NSMakeRange(index + 1, count - index - 1)];
    
    UIViewController *previous = viewController;
    
    CGRect originalFrame = [self contentBounds];
    originalFrame.origin.x = -originalFrame.size.width/3;
    [[previous view] setFrame:originalFrame];
    
    [self.view insertSubview:[previous view] belowSubview:[self.topViewController view]];
    
    void (^animationBlock)(void) = ^(void){
        CGRect finalFrame = [self contentBounds];
        finalFrame.origin.x = finalFrame.size.width;
        [[self.topViewController view] setFrame:finalFrame];
        
        finalFrame.origin.x = 0;
        [[previous view] setFrame:finalFrame];
    };
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        // Put tabBar back
        if (self.tabBarController && [previous isEqual:self.tabBarHolder]) {
            UITabBar *tabBar = [self.tabBarController tabBar];
            [[self.tabBarController view] addSubview:tabBar];
            self.tabBarHolder = nil;
        }
        
        [self.topViewController willMoveToParentViewController:nil];
        [[self.topViewController view] removeFromSuperview];
        [self.topViewController removeFromParentViewController];
        
        for (UIViewController *popedViewController in popedViewControllers) {
            [popedViewController willMoveToParentViewController:nil];
            [popedViewController removeFromParentViewController];
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:self.durationForAnimations animations:animationBlock completion:completionBlock];
        return popedViewControllers;
    }
    
    animationBlock();
    completionBlock(YES);
    
    return popedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:[self.viewControllers firstObject] animated:animated];
}

- (CGRect)contentBounds
{
    return [self.view bounds];
}

#pragma mark - Gesture

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (self.panGestureType == CWPanGestureTypePush) {
        [self handlePushGesture:recognizer];
    }
    else if (self.panGestureType == CWPanGestureTypePop) {
        [self handlePopGesture:recognizer];
    }
}

- (void)handlePushGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self addChildViewController:self.nextViewController];
        
        CGRect originalFrame = [self contentBounds];
        originalFrame.origin.x = originalFrame.size.width;
        [[self.nextViewController view] setFrame:originalFrame];
        [self addShadowToView:[self.nextViewController view]];
        
        [self.view insertSubview:[self.nextViewController view] aboveSubview:[self.previousViewController view]];
        
        if (!self.tabBarController || [self.previousViewController hidesBottomBarWhenPushed] || ![self.nextViewController hidesBottomBarWhenPushed]) {
            return;
        }
        
        self.tabBarHolder = self.previousViewController;
        UITabBar *tabBar = [self.tabBarController tabBar];
        [[self.previousViewController view] addSubview:tabBar];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];
        
        CGRect frame = [[self.nextViewController view] frame];
        frame.origin.x = fminf([self contentBounds].size.width, [self contentBounds].size.width + translation.x);
        [[self.nextViewController view] setFrame:frame];
        
        frame = [[self.previousViewController view] frame];
        frame.origin.x = fminf(0, [self contentBounds].size.width/3 * translation.x/[self contentBounds].size.width);
        [[self.previousViewController view] setFrame:frame];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGRect nextFrame = [[self.nextViewController view] frame];
        CGFloat percentage = (CGRectGetWidth([self contentBounds]) - nextFrame.origin.x)/CGRectGetWidth([self contentBounds]);
        
        // Push
        if (percentage >= self.threshold) {
            [UIView animateWithDuration:self.durationForAnimations animations:^{
                CGRect finalFrame = [self contentBounds];
                [[self.nextViewController view] setFrame:finalFrame];
                
                finalFrame.origin.x = -finalFrame.size.width/3;
                [[self.previousViewController view] setFrame:finalFrame];
            } completion:^(BOOL finished) {
                [[self.previousViewController view] removeFromSuperview];
                
                [self.nextViewController didMoveToParentViewController:self];
                
                [self resetPreviousAndNext];
            }];
            
            return;
        }
        
        // Cancel push
        [UIView animateWithDuration:self.durationForAnimations animations:^{
            CGRect finalFrame = [self contentBounds];
            [[self.previousViewController view] setFrame:finalFrame];
            
            finalFrame.origin.x = finalFrame.size.width;
            [[self.nextViewController view] setFrame:finalFrame];
        } completion:^(BOOL finished) {
            [self.nextViewController willMoveToParentViewController:nil];
            [[self.nextViewController view] removeFromSuperview];
            [self.nextViewController removeFromParentViewController];
            
            if (self.tabBarController && [self.previousViewController isEqual:self.tabBarHolder] && ![self.previousViewController hidesBottomBarWhenPushed]) {
                // Put tabBar back
                UITabBar *tabBar = [self.tabBarController tabBar];
                [[self.tabBarController view] addSubview:tabBar];
                self.tabBarHolder = nil;
            }
            
            [self resetPreviousAndNext];
        }];
    }
}

- (void)handlePopGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGRect originalFrame = [self contentBounds];
        originalFrame.origin.x = -originalFrame.size.width/3;
        [[self.previousViewController view] setFrame:originalFrame];
        
        [self.view insertSubview:[self.previousViewController view] belowSubview:[self.topViewController view]];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];

        CGRect frame = [[self.previousViewController view] frame];
        frame.origin.x = -[self contentBounds].size.width/3 + [self contentBounds].size.width/3 * translation.x/[self contentBounds].size.width;
        [[self.previousViewController view] setFrame:frame];
        
        frame = [[self.topViewController view] frame];
        frame.origin.x = fmaxf(0, translation.x);
        [[self.topViewController view] setFrame:frame];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGRect topFrame = [[self.topViewController view] frame];
        CGFloat percentage = topFrame.origin.x/CGRectGetWidth([self contentBounds]);

        // Pop
        if (percentage >= self.threshold) {
            [UIView animateWithDuration:self.durationForAnimations animations:^{
                CGRect finalFrame = [self contentBounds];
                finalFrame.origin.x = finalFrame.size.width;
                [[self.topViewController view] setFrame:finalFrame];
                
                finalFrame.origin.x = 0;
                [[self.previousViewController view] setFrame:finalFrame];
            } completion:^(BOOL finished) {
                if (self.tabBarController && [self.previousViewController isEqual:self.tabBarHolder] && ![self.previousViewController hidesBottomBarWhenPushed]) {
                    UITabBar *tabBar = [self.tabBarController tabBar];
                    [[self.tabBarController view] addSubview:tabBar];
                    self.tabBarHolder = nil;
                }
                
                [self.topViewController willMoveToParentViewController:nil];
                [[self.topViewController view] removeFromSuperview];
                [self.topViewController removeFromParentViewController];
                
                [self resetPreviousAndNext];
            }];
            
            return;
        }
        
        // Cancel pop
        [UIView animateWithDuration:self.durationForAnimations animations:^{
            CGRect finalFrame = [self contentBounds];
            [[self.topViewController view] setFrame:finalFrame];
            
            finalFrame.origin.x = -finalFrame.size.width/3;
            [[self.previousViewController view] setFrame:finalFrame];
        } completion:^(BOOL finished) {
            [[self.previousViewController view] removeFromSuperview];
            
            [self resetPreviousAndNext];
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer;
{
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    
    self.panGestureType = velocity.x > 0 ? CWPanGestureTypePop : CWPanGestureTypePush;
    
    self.previousViewController = nil;
    self.nextViewController = nil;
    
    if (self.panGestureType == CWPanGestureTypePush) {
        if (![self.topViewController respondsToSelector:@selector(nextViewController)]) {
            return NO;
        }
        
        self.nextViewController = [self.topViewController performSelector:@selector(nextViewController) withObject:nil];
        if (!self.nextViewController) {
            return NO;
        }
        
        self.previousViewController = self.topViewController;
    }
    else if (self.panGestureType == CWPanGestureTypePop) {
        NSUInteger topIndex = [self.childViewControllers indexOfObject:self.topViewController];
        if (topIndex == 0) {
            return NO;
        }
        
        self.previousViewController = self.childViewControllers[topIndex - 1];
    }
    
    return YES;
}

- (void)resetPreviousAndNext
{
    self.previousViewController = nil;
    self.nextViewController = nil;
}

#pragma mark - Shadow

- (void)addShadowToView:(UIView *)view
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    CALayer *layer = view.layer;
    layer.masksToBounds = NO;
    layer.shadowColor = [self.shadowColor CGColor];
    layer.shadowOffset = self.shadowOffset;
    layer.shadowOpacity = self.shadowOpacity;
    layer.shadowPath = shadowPath.CGPath;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = [self contentBounds];
        [[self.topViewController view] setFrame:frame];
    }];
}

@end

@implementation UIViewController (CWStackController)

- (CWStackController *)stackController
{
    UIViewController *parent = self.parentViewController;
    while (parent) {
        if ([parent isKindOfClass:[CWStackController class]]) {
            return (CWStackController *)parent;
        }
        else if (parent.parentViewController && parent.parentViewController != parent) {
            parent = parent.parentViewController;
        }
        else {
            parent = nil;
        }
    }
    return nil;
}

@end
