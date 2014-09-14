# FSStackController

FSStackController is a UINavigationController like custom container view controller which provides fullscreen pan gesture support to POP and PUSH , inspired by [Netease News](https://itunes.apple.com/cn/app/id425349261) and used in my recent appp [cnBeta Reader](https://itunes.apple.com/cn/app/id885800972).

![demo gif](/demo.gif)

## Installation

There are two options:

1. FSStackController is availabel as `FSStackController` in CocoaPods.
2. Drag "FSStackController.h" from demo project into your Xcode project.

## Requirement

* iOS 6.0 or higher
* ARC

## Usage

FSStackController's APIs are pretty much like UINavigationController's which make it very easy to use:

	// Init
	- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

	// Push
	- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

	// Pop
	- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
	- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
	- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

	// Accessing
	@property (nonatomic, strong) NSArray *viewControllers;
	- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
	@property (nonatomic, readonly) UIViewController *topViewController;

**Enable to push new controller through pan gesture**:

Assume you have a view controller A is in the FSStackController stack, you want push a new view controller B to stack through pan gesture, all you need to do is let A confirms to `FSStackProtocol` and implements `- (UIViewController *)nextViewController`:

	// A.m
	- (UIViewController *)nextViewController
	{
		return B;
	}

See *Demo* project for more details.

## License

FSStackController is available under the MIT license. See the LICENSE file for more info.


	


