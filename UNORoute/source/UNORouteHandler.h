//
//  UNORouteHandler.h
//  UNOBleTest
//
//  Created by intebox on 2017/5/27.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNORouteRequest,UIViewController;
@interface UNORouteHandler : NSObject

- (BOOL)shouldHandleWithRequest:(UNORouteRequest *)request;
-(UIViewController *)targetViewControllerWithRequest:(UNORouteRequest *)request;
-(UIViewController *)sourceViewControllerForTransitionWithRequest:(UNORouteRequest *)request;
-(BOOL)handleRequest:(UNORouteRequest *)request error:(NSError *__autoreleasing *)error;
-(BOOL)transitionWithWithRequest:(UNORouteRequest *)request sourceViewController:(UIViewController *)sourceViewController targetViewController:(UIViewController *)targetViewController isPreferModal:(BOOL)isPreferModal isAnimation:(BOOL)isAnimation error:(NSError *__autoreleasing *)error;
- (BOOL)preferModalPresentationWithRequest:(UNORouteRequest *)request;
- (BOOL)preferAnimationWithRequest:(UNORouteRequest *)request;

@end
