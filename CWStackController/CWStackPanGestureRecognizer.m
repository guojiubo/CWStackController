//
//  CWScrollViewEndDetectGestureRecognizer.m
//  CWStackControllerDemo
//
//  Created by Guojiubo on 14-10-1.
//  Copyright (c) 2014年 CocoaWind. All rights reserved.
//

#import "CWStackPanGestureRecognizer.h"

@interface CWStackPanGestureRecognizer ()

@property (nonatomic, strong, getter=isFailed) NSNumber *failed;
@property (nonatomic, readwrite) CWStackPanGestureRecognizerDirection direction;

@end

@implementation CWStackPanGestureRecognizer

- (void)reset
{
    [super reset];
    self.failed = nil;
    self.direction = CWStackPanGestureRecognizerDirectionNone;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    if (self.isFailed) {
        if ([self.isFailed boolValue]) {
            self.state = UIGestureRecognizerStateFailed;
        }
        return;
    }
    
    CGPoint currentLocation = [touches.anyObject locationInView:self.view];
    CGPoint previousLocation = [touches.anyObject previousLocationInView:self.view];
    
    // Only analyze horizontal pan gesture
    CGPoint translation = CGPointMake(currentLocation.x - previousLocation.x, currentLocation.y - previousLocation.y);
    if (fabs(translation.y) > fabs(translation.x)) {
        self.state = UIGestureRecognizerStateFailed;
        self.failed = @YES;
    }
    else {
        self.failed = @NO;
    }
    
    // Determine direction
    if (currentLocation.x > previousLocation.x) {
        self.direction = CWStackPanGestureRecognizerDirectionPop;
    }
    else if (currentLocation.x < previousLocation.x) {
        self.direction = CWStackPanGestureRecognizerDirectionPush;
    }
    else {
        self.direction = CWStackPanGestureRecognizerDirectionNone;
    }

    // Deal with scroll view
    if (!self.scrollView) {
        return;
    }
    
    if (self.direction == CWStackPanGestureRecognizerDirectionPop) {
        CGFloat fixedOffsetX = [self.scrollView contentOffset].x + [self.scrollView contentInset].left;
        if (fixedOffsetX <= 0) {
            self.failed = @NO;
        } else {
            self.state = UIGestureRecognizerStateFailed;
            self.failed = @YES;
        }
        return;
    }
    
    if (self.direction == CWStackPanGestureRecognizerDirectionPush) {
        CGFloat fixedOffsetX = [self.scrollView contentOffset].x - [self.scrollView contentInset].right;
        
        if (fixedOffsetX + self.scrollView.bounds.size.width >= self.scrollView.contentSize.width) {
            self.failed = @NO;
        } else {
            self.state = UIGestureRecognizerStateFailed;
            self.failed = @YES;
        }
    }
}

@end
