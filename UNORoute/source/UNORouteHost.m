//
//  UNORouteHost.m
//  UNOBleTest
//
//  Created by intebox on 2017/5/27.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import "UNORouteHost.h"
#import "UNORouteRequest.h"
#import "UIViewController+UNORoute.h"
@implementation UNORouteHost

- (UIViewController *)objectForKeyedSubscript:(NSString *)key{
    if (key && [self.subResources.keyEnumerator.allObjects containsObject:key]) {
        return [self.subResources objectForKey:key];
    }
    return nil;
}

- (NSMutableArray *)subPathes{
    if (!_subPathes) {
        _subPathes = [NSMutableArray array];
    }
    return _subPathes;
}

- (NSMapTable *)subResources{
    if (!_subResources) {
        _subResources = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                              valueOptions:NSPointerFunctionsWeakMemory];
    }
    return _subResources;
}

- (void)setRootViewController:(UIViewController *)rootViewController{
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        UIViewController *navigationRootController = navigationController.viewControllers.firstObject;
        if (navigationRootController) {
            UNORouteRequest *request = [[UNORouteRequest alloc] init];
            
            request.host = self;
            request.params = nil;
            request.callBack = nil;
            request.completion = nil;
            request.path = NSStringFromClass([navigationRootController class]);
            navigationRootController.uno_request = request;
            [request.host.subPathes addObject:NSStringFromClass([navigationRootController class])];
            [request.host.subResources setObject:navigationRootController forKey:NSStringFromClass([navigationRootController class])];
            
        }
    }
    
    _rootViewController = rootViewController;
}

@end
