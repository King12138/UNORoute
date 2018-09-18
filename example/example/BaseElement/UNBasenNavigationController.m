//
//  basenNavigationController.m
//  UnovoApartmentGuest
//
//  Created by intebox on 15/7/26.
//  Copyright (c) 2015年 KevinZhang. All rights reserved.
//

#import "UNBasenNavigationController.h"

@interface UNBasenNavigationController ()
<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, getter = isDuringPushAnimation) BOOL duringPushAnimation;

@property (weak, nonatomic) id<UINavigationControllerDelegate> realDelegate;


@end

@implementation UNBasenNavigationController

#pragma mark - NSObject

- (void)dealloc
{
    self.delegate = nil;
    self.interactivePopGestureRecognizer.delegate = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.delegate) {
        self.delegate = self;
    }
    
    self.interactivePopGestureRecognizer.delegate = self;
}

#pragma mark - UINavigationController

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    [super setDelegate:delegate ? self : nil];
    self.realDelegate = delegate != self ? delegate : nil;
}



- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.duringPushAnimation = YES;
    if (self.viewControllers.count != 0) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_navi_back"] 
                                                                                           style:UIBarButtonItemStyleDone
                                                                                          target:self
                                                                                          action:@selector(back)];
        
        self.interactivePopGestureRecognizer.delegate = self;
    }
    if (self.childViewControllers.count==1)
    {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}


- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return [super popViewControllerAnimated:animated];
}

- (void)back
{
    [self popViewControllerAnimated:YES];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    self.duringPushAnimation = NO;
    if ([self.realDelegate respondsToSelector:_cmd]) {
        [self.realDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController*)fromVC toViewController:(UIViewController*)toVC
{
    if ([self.realDelegate respondsToSelector:_cmd]) {
        return [self.realDelegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    }
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController*)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    if ([self.realDelegate respondsToSelector:_cmd]) {
        return [self.realDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return [self.viewControllers count] > 1 && !self.isDuringPushAnimation;
    } else {
        return YES;
    }
}

#pragma mark - Delegate Forwarder

- (BOOL)respondsToSelector:(SEL)s{
    return [super respondsToSelector:s] || [self.realDelegate respondsToSelector:s];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)s{
    return [super methodSignatureForSelector:s] ?: [(id)self.realDelegate methodSignatureForSelector:s];
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    id delegate = self.realDelegate;
    if ([delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:delegate];
    }
}

@end
