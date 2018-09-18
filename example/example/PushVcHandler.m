//
//  PushVcHandler.m
//  example
//
//  Created by intebox on 2018/9/18.
//  Copyright © 2018年 unovo. All rights reserved.
//

#import "PushVcHandler.h"
#import "ViewControllerPush.h"
@implementation PushVcHandler
- (UIViewController *)targetViewControllerWithRequest:(UNORouteRequest *)request{
    return [[ViewControllerPush alloc] init];
}

@end
