//
//  UNORouteHandler.m
//  UNOBleTest
//
//  Created by intebox on 2017/5/27.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import "UNORouteHandler.h"
#import "UNORouteRequest.h"
#import "UIViewController+UNORoute.h"

@implementation UNORouteHandler

-(BOOL)shouldHandleWithRequest:(UNORouteRequest *)request{
    return YES;
}
-(UIViewController *)targetViewControllerWithRequest:(UNORouteRequest *)request{
    return [[UIViewController alloc] init];
}
-(UIViewController *)sourceViewControllerForTransitionWithRequest:(UNORouteRequest *)request{
    return request.host.rootViewController ?: [UIApplication sharedApplication].windows[0].rootViewController;
}
-(BOOL)handleRequest:(UNORouteRequest *)request error:(NSError *__autoreleasing *)error{
    UIViewController * sourceViewController = [self sourceViewControllerForTransitionWithRequest:request];
    UIViewController * targetViewController = [self targetViewControllerWithRequest:request];
    if ((![sourceViewController isKindOfClass:[UIViewController class]])||(![targetViewController isKindOfClass:[UIViewController class]])) {
        *error = [NSError errorWithDomain:@"UNORouteError" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"sourceViewController or targetViewController invalid"}];
        return NO;
    }
    if (targetViewController != nil) {
        targetViewController.uno_request = request;
    }
    BOOL isPreferModal = [self preferModalPresentationWithRequest:request];
    BOOL isAnimation = [self preferAnimationWithRequest:request];
    
    return [self transitionWithWithRequest:request sourceViewController:sourceViewController targetViewController:targetViewController isPreferModal:isPreferModal isAnimation:isAnimation error:error];
}

-(BOOL)transitionWithWithRequest:(UNORouteRequest *)request sourceViewController:(UIViewController *)sourceViewController targetViewController:(UIViewController *)targetViewController isPreferModal:(BOOL)isPreferModal isAnimation:(BOOL)isAnimation error:(NSError *__autoreleasing *)error{
    if (isPreferModal||![sourceViewController isKindOfClass:[UINavigationController class]]) {
        
        if (targetViewController == sourceViewController.presentedViewController) {
            [sourceViewController dismissViewControllerAnimated:isAnimation completion:nil];
        } else {
            [sourceViewController presentViewController:targetViewController animated:isAnimation completion:nil];
            request.fromViewController = targetViewController.presentedViewController;
            request.fromNode = targetViewController.presentedViewController.uno_request.currenNode;
        }
        
    }else if ([sourceViewController isKindOfClass:[UINavigationController class]]){
        UINavigationController * nav = (UINavigationController *)sourceViewController;
        if ([nav.viewControllers containsObject:targetViewController]) {
            [nav popToViewController:targetViewController animated:isAnimation];
        } else {
            UINavigationController *sourceNaviViewController = (UINavigationController *)sourceViewController;
            request.fromViewController = sourceNaviViewController.topViewController;
            request.fromNode = sourceNaviViewController.uno_request.currenNode;
            
            [nav pushViewController:targetViewController animated:isAnimation];
        }
    }
    return YES;
}

- (BOOL)preferModalPresentationWithRequest:(UNORouteRequest *)request{
    return NO;
}

- (BOOL)preferAnimationWithRequest:(UNORouteRequest *)request{
    return YES;
}

@end
