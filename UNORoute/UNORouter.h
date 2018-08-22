//
//  UNORoute.h
//  UNOBleTest
//
//  Created by intebox on 2017/5/27.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UNORouteHost.h"
#import "UNORouteHandler.h"
#import "UNORouteRequest.h"

typedef void(^RouteCallBack)(id);

@interface UNORouter : NSObject

//一个简易的路由 没有完全按照路由的思想实现,为了业务实现做了一些取舍
//验证 URL 主要通过 验证 scheme  host
//scheme == plist文件中的urlTypes  必须配置 不支持设置
//host  通过 regitserHosts 注册  一般是一个Navi一个host  比较好管理
//所有的参数通过params传递 不支持通过path传递

@end


@interface UNORouter (host)

+ (void)regitserHost:(UNORouteHost *)host;
+ (void)removeHostWithHostKey:(NSString *)hostKey;
+ (void)removeAllHost;

@end



@interface UNORouter (handlerRegister)

+ (BOOL)regitserHandler:(UNORouteHandler *)handler withPath:(NSURL *)path;
+ (void)removeHandlerWithPath:(NSURL *)path;
+ (void)removeAllPath;

@end

@interface UNORouter (handlerAction)

+ (BOOL)handUrl:(NSURL *)path;
+ (BOOL)handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params;
+ (BOOL)handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack;
+ (BOOL)handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params completion:(dispatch_block_t)completion;
+ (BOOL)handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion;

@end



//调用这个方法 会自动创建handler  但是不会自动创建host和scheme
//规定path.relativePath 部分只有一个component 多个component 只根据lastPathComponent校验
//这个component必须是某个控制器的class对象  用于确定 targetViewController
//自动生成的handler类 规则为 __(component)__Handler_Cls
//如果VC是nib的，那么nib文件的名字需要和path的lastPathComponent一样
//暂时未支持StoryBoard
@interface UNORouter (fastHandlerAction)

+ (BOOL)fast_handUrl:(NSURL *)path;
+ (BOOL)fast_handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params;
+ (BOOL)fast_handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack;
+ (BOOL)fast_handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params completion:(dispatch_block_t)completion;
+ (BOOL)fast_handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion;

@end

// 这个方法支持hook,默认返回originRequest
// 可以重写这个方法 给request做一些标记,然后配合自定义的handler,可以完成大部分你希望的需求
typedef NS_ENUM(NSInteger,UNORoute_Api_Type) {
    UNORoute_Api_TypeDefault,
    UNORoute_Api_TypeFast
};
@interface UNORouter (handlerAction_hook)
+ (UNORouteRequest *)hook_requestWithOriginReqest:(UNORouteRequest *)originRequest apiType:(UNORoute_Api_Type)apiType;
@end

@interface UNORouter (observing)

+ (void)addObserve:(id)observe toNode:(NSString *)node callBack:(void(^)(NSString *sourceNode, NSDictionary *param))callBack;

@end


//如果需要通过fast系列的api获取sb中创建的viewControler 需在path中传入对应的sbName和sbId
//详情看 UNORoute_SBPathMaker
FOUNDATION_EXPORT NSString *const UNO_ROUTE_StoryBoard_Name_Key;
FOUNDATION_EXPORT NSString *const UNO_ROUTE_StoryBoard_ID_Key;

static inline NSURL * UNORoute_PathMaker(NSString *scheme, NSString *host,NSString *node){
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@",scheme,host,node]];
}

static inline NSURL *UNORoute_SBPathMaker(NSString *scheme, NSString *host,NSString *sbName,NSString *sbId){
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@?%@=%@&%@=%@",scheme,host,UNO_ROUTE_StoryBoard_Name_Key,sbName,UNO_ROUTE_StoryBoard_ID_Key,sbId]];
}


FOUNDATION_EXPORT NSString *const UNO_ROUTE_SourceNode_Key;
