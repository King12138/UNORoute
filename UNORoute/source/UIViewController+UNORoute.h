//
//  UIViewController+UNORoute.h
//  UNOBleTest
//
//  Created by intebox on 2017/6/1.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UNORouter.h"

@interface UIViewController (UNORoute)

@property (nonatomic, strong) UNORouteRequest *uno_request;

- (NSString *)fullPath;
- (void)uno_back;
- (void)uno_back:(BOOL)animation;

@end

@interface UIViewController (UNORoute_Push)

- (BOOL)pushWithNodeId:(NSString *)nodeId;
- (BOOL)pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params;
- (BOOL)pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack;
- (BOOL)pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params completion:(dispatch_block_t)completion;
- (BOOL)pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion;

- (BOOL)fast_pushWithNodeId:(NSString *)nodeId;
- (BOOL)fast_pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params;
- (BOOL)fast_pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack;
- (BOOL)fast_pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params completion:(dispatch_block_t)completion;
- (BOOL)fast_pushWithNodeId:(NSString *)nodeId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion;

#pragma mark-
#pragma mark- SB
- (BOOL)fast_SB_pushWithSbName:(NSString *)sbName sbId:(NSString *)sbId;
- (BOOL)fast_SB_pushWithSbName:(NSString *)sbName sbId:(NSString *)sbId params:(NSDictionary<NSString *,id> *)params;
- (BOOL)fast_SB_pushWithSbName:(NSString *)sbName sbId:(NSString *)sbId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack;
- (BOOL)fast_SB_pushWithSbName:(NSString *)sbName sbId:(NSString *)sbId params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion;
@end

@interface UIViewController (UNORoute_Obser)

- (void)addObserverToNode:(NSString *)node callBack:(void(^)(NSString *node,id params))callback;

@end
