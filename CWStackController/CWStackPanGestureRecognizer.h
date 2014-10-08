//
//  CWScrollViewEndDetectGestureRecognizer.h
//  CWStackControllerDemo
//
//  Created by Guojiubo on 14-10-1.
//  Copyright (c) 2014年 CocoaWind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef NS_ENUM(NSInteger, CWStackPanGestureRecognizerDirection) {
    CWStackPanGestureRecognizerDirectionNone,
    CWStackPanGestureRecognizerDirectionPush,
    CWStackPanGestureRecognizerDirectionPop
};

@interface CWStackPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readonly) CWStackPanGestureRecognizerDirection direction;

@end
