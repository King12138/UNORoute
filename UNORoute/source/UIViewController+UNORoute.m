//
//  UIViewController+UNORoute.m
//  UNOBleTest
//
//  Created by intebox on 2017/6/1.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import "UIViewController+UNORoute.h"
#import <objc/runtime.h>

//#import "UNHorizontalStripeViewController.h"

@implementation UIViewController (UNORoute)

+ (void)load{
    
    Method viewDidAppear = class_getInstanceMethod(self, @selector(viewDidAppear:));
    Method swizzleViewDidAppear = class_getInstanceMethod(self, @selector(route_swizzleViewDidAppear:));
    
    if (viewDidAppear && swizzleViewDidAppear) {
        method_exchangeImplementations(viewDidAppear, swizzleViewDidAppear);
    }
    
    Method dealloc = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
    Method swizzleDealloc = class_getInstanceMethod(self, @selector(route_swizzledealloc));
    if (dealloc&&swizzleDealloc) {
        method_exchangeImplementations(dealloc, swizzleDealloc);
    }
    
    Method viewWillAppear = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method swizzleViewWillAppear = class_getInstanceMethod(self, @selector(route_swizzleViewWillAppear:));
    if (viewWillAppear&&swizzleViewWillAppear) {
        method_exchangeImplementations(viewWillAppear, swizzleViewWillAppear);
    }
    
    Method viewDidDisappear = class_getInstanceMethod(self, @selector(viewDidDisappear:));
    Method swizzleViewDidDisappear = class_getInstanceMethod(self, @selector(route_swizzleViewDidDisappear:));
    if (viewDidDisappear&&swizzleViewDidDisappear) {
        method_exchangeImplementations(viewDidDisappear, swizzleViewDidDisappear);
    }
}

- (void)route_swizzledealloc{
    if (self.uno_request) {
        [self.uno_request.host.subPathes removeObject:self.uno_request.path];
        [self.uno_request.host.subResources removeObjectForKey:self.uno_request.path];
    }
    self.uno_request.completion = nil;
    self.uno_request.callBack = nil;
    self.uno_request = nil;
    [self route_swizzledealloc];
}

- (UNORouteRequest *)requestFromParentViewController:(UIViewController *)parentViewController{
    if (parentViewController == nil) {
        return nil;
    }else{
        return parentViewController.uno_request == nil ? [parentViewController requestFromParentViewController:parentViewController.parentViewController] : parentViewController.uno_request;
    }
}

- (void)route_swizzleViewWillAppear:(BOOL)animation{
    if (self.uno_request) {
        [self.uno_request.host.subPathes addObject:self.uno_request.path];
        [self.uno_request.host.subResources setObject:self forKey:self.uno_request.path];
    }
    
    [self route_swizzleViewWillAppear:animation];
}

- (void)route_swizzleViewDidAppear:(BOOL)animation{
    if (self.uno_request) {
        !self.uno_request.completion?:self.uno_request.completion();
        self.uno_request.completion = nil;
    }
    
    [self route_swizzleViewDidAppear:animation];
}


- (void)route_swizzleViewDidDisappear:(BOOL)animated{
    if (self.uno_request) {
        [self.uno_request.host.subPathes removeObject:self.uno_request.path];
        [self.uno_request.host.subResources removeObjectForKey:self.uno_request.path];
    }
    
    [self route_swizzleViewDidDisappear:animated];
}


#pragma mark-
#pragma mark-
static NSString *UNO_Request_Associateobject_Key = @"UNOROUTE_UNO_REQUEST";
-(UNORouteRequest *)uno_request{
    return objc_getAssociatedObject(self, &UNO_Request_Associateobject_Key);
}

- (void)setUno_request:(UNORouteRequest *)uno_request{
    objc_setAssociatedObject(self, &UNO_Request_Associateobject_Key, uno_request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)fullPath{
    NSMutableString *temp = [NSMutableString stringWithFormat:@"%@://%@",self.uno_request.host.scheme,self.uno_request.host.host];
    for (NSString *path in self.uno_request.host.subPathes) {
        [temp appendString:@"/"];
        [temp appendString:path];
    }

    return temp;
}

- (void)uno_back{
    [self uno_back:YES];
}

- (void)uno_back:(BOOL)animation{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:animation];
    } else if (self.parentViewController.navigationController) {
        [self.parentViewController.navigationController popViewControllerAnimated:animation];
    } else if (self.presentedViewController){
        [self dismissViewControllerAnimated:animation completion:nil];
    } else {
        NSLog(@"uno_back unvalid");
    }
}
@end

@implementation UIViewController (UNORoute_Push)

- (BOOL)pushWithNodeId:(NSString *)nodeId{
    return [self pushWithNodeId:nodeId params:nil];
}
- (BOOL)pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params{
    return [self pushWithNodeId:nodeId params:params callBack:nil];
}
- (BOOL)pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack{
    return [self pushWithNodeId:nodeId params:params callBack:callBack completion:nil];
}
- (BOOL)pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params completion:(dispatch_block_t)completion{
    return [self pushWithNodeId:nodeId params:params callBack:nil completion:completion];
}
- (BOOL)pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion{
    if (nodeId) {
        NSMutableString *temp = [NSMutableString stringWithFormat:@"%@://%@/%@",self.uno_request.host.scheme,self.uno_request.host.host,nodeId];
        return [UNORouter handUrl:[NSURL URLWithString:temp] params:params callBack:callBack completion:completion];
    }else{
        return NO;
    }
}

- (BOOL)fast_pushWithNodeId:(NSString *)nodeId{
    return [self fast_pushWithNodeId:nodeId params:nil];
}
- (BOOL)fast_pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params{
    return [self fast_pushWithNodeId:nodeId params:params callBack:nil];
}
- (BOOL)fast_pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack{
    return [self fast_pushWithNodeId:nodeId params:params callBack:callBack completion:nil];
}
- (BOOL)fast_pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params completion:(dispatch_block_t)completion{
    return [self fast_pushWithNodeId:nodeId params:params callBack:nil completion:completion];
}
- (BOOL)fast_pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion{
    if (nodeId) {
        if (self.uno_request == nil) {
            //当是ChildViewController的时候需要获取parentViewController的request
            self.uno_request = [self requestFromParentViewController:self.parentViewController];
        }
        if (self.uno_request == nil) {
            return NO;
        }
        NSMutableString *temp = [NSMutableString stringWithFormat:@"%@://%@/%@",self.uno_request.host.scheme,self.uno_request.host.host,nodeId];
        return [UNORouter  fast_handUrl:[NSURL URLWithString:temp] params:params callBack:callBack completion:completion];
    }else{
        return NO;
    }
}

- (BOOL)fast_SB_pushWithSbName:(NSString *)sbName sbId:(NSString *)sbId
{
    return [self fast_SB_pushWithSbName:sbName sbId:sbId params:nil callBack:nil completion:nil];
}

- (BOOL)fast_SB_pushWithSbName:(NSString *)sbName sbId:(NSString *)sbId params:(NSDictionary<NSString *,id> *)params
{
    return [self fast_SB_pushWithSbName:sbName sbId:sbId params:params callBack:nil completion:nil];
}

- (BOOL)fast_SB_pushWithSbName:(NSString *)sbName sbId:(NSString *)sbId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack
{
    return [self fast_SB_pushWithSbName:sbName sbId:sbId params:params callBack:callBack completion:nil];
}

- (BOOL)fast_SB_pushWithSbName:(NSString *)sbName sbId:(NSString *)sbId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion
{
    if (sbId && sbName)
    {
        if (self.uno_request == nil) {
            //当是ChildViewController的时候需要获取parentViewController的request
            self.uno_request = [self requestFromParentViewController:self.parentViewController];
        }
        if (self.uno_request == nil) {
            return NO;
        }
        NSURL *url = UNORoute_SBPathMaker(self.uno_request.host.scheme, self.uno_request.host.host, sbName, sbId);
        return [UNORouter fast_handUrl:url params:params callBack:callBack completion:completion];
    }
    else
    {
        return NO;
    }
}


@end


@implementation UIViewController (UNORoute_Obser)

- (void)addObserverToNode:(NSString *)node callBack:(void(^)(NSString *node,id params))callback{
    [UNORouter addObserve:self toNode:node callBack:callback];
}

@end

//@class UNHorizontalStripeViewController;
//@implementation UNHorizontalStripeViewController (UNORoute_Request)
//
//+ (void)load{
//    Method viewDidload = class_getInstanceMethod(self, @selector(viewDidLoad));
//    Method swizzleViewDidload = class_getInstanceMethod(self, @selector(route_swizzleViewDidLoad));
//    if (viewDidload&&swizzleViewDidload) {
//        method_exchangeImplementations(viewDidload, swizzleViewDidload);
//    }
//}
//
//- (void)route_swizzleViewDidLoad{
//    
//    [self route_swizzleViewDidLoad];
//    
//    //当是pageviewController这种容器的话需要给子控制器赋值
//    if ([self isKindOfClass:[UNHorizontalStripeViewController class]]){
//        
//        if (self.uno_request == nil) {
//            self.uno_request = [self requestFromParentViewController:self.parentViewController];
//        }
//        
//        if (self.uno_request != nil) {
//            for (UIViewController *viewController in ((UNHorizontalStripeViewController *)self).viewControllers) {
//                viewController.uno_request = self.uno_request;
//            }
//        }
//    }
//}

//@end


