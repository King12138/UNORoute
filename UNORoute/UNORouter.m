                                   //
//  UNORoute.m
//  UNOBleTest
//
//  Created by intebox on 2017/5/27.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import "UNORouter.h"

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#define UNORouterInstant [__UNORouterPrivate shareInstant]

#ifdef DEBUG
#define UN_Route_Action(...)  __VA_ARGS__
#else
#define UN_Route_Action(...)
#endif

@interface __UNORouterPrivate : NSObject

@property (nonatomic, strong) NSMutableArray *schemeTable;
@property (nonatomic, strong) NSMutableArray <UNORouteHost *>* hostsTable;
@property (nonatomic, strong) NSMapTable <NSString *, UNORouteHandler *>* handlerMap;
@property (nonatomic, strong) NSMapTable <NSString *, id>*observerMap;

@end

@implementation __UNORouterPrivate

+ (instancetype)shareInstant{
    static __UNORouterPrivate *instant;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instant = [[__UNORouterPrivate alloc] init];
    });
    return instant;
}


- (BOOL)validScheme:(NSString *)scheme{
    return [self.schemeTable containsObject:scheme];
}

- (BOOL)validHost:(NSString *)host{
    return host&&[[self.hostsTable mutableArrayValueForKeyPath:@"host"] containsObject:host];
}

- (UNORouteHost *)routeHostWith:(NSString *)hostName{
    for (UNORouteHost *host in self.hostsTable) {
        if ([host.host isEqualToString:hostName]) {
            return host;
        }
    }
    return nil;
}

#pragma mark-
#pragma mark- getter

- (NSMutableArray *)schemeTable{
    if (!_schemeTable) {
        _schemeTable = [NSMutableArray array];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        if ([infoDictionary.allKeys containsObject:@"CFBundleURLTypes"]) {
            for (NSDictionary *type in infoDictionary[@"CFBundleURLTypes"]) {
                if ([type.allKeys containsObject:@"CFBundleURLSchemes"]) {
                    for (NSString *scheme in  type[@"CFBundleURLSchemes"]) {
                        [_schemeTable addObject:scheme];
                    }
                }
            }
        }
    }
    return _schemeTable;
}

- (NSMutableArray <UNORouteHost *> *)hostsTable{
    if (!_hostsTable) {
        _hostsTable = [NSMutableArray array];
    }
    return _hostsTable;
}

- (NSMapTable <NSString *, UNORouteHandler *>*)handlerMap{
    if (!_handlerMap) {
        _handlerMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _handlerMap;
}

- (NSMapTable <NSString *, id>*)observerMap{
    if (!_observerMap) {
        _observerMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _observerMap;
}

@end

@implementation UNORouter


@end

@implementation UNORouter (host)

+ (void)regitserHost:(UNORouteHost *)host {
    if (![UNORouterInstant.hostsTable containsObject:host]) {
        [UNORouterInstant.hostsTable addObject:host];
    }
}


+ (void)removeHostWithHostKey:(NSString *)hostKey{
    NSMutableArray *deleteingContainer = [@[] mutableCopy];
    
    for (UNORouteHost *host in UNORouterInstant.hostsTable) {
        ![host.host isEqualToString:hostKey]?:[deleteingContainer addObject:host];
    }
    
    deleteingContainer.count==0?:[UNORouterInstant.hostsTable removeObjectsInArray:deleteingContainer];
}

+ (void)removeAllHost{
    [UNORouterInstant.hostsTable removeAllObjects];
}

@end


@interface NSObject (UNORoute_associatedobject)

- (void)uno_setAssociatedobject:(id)obj;
- (id)uno_associatedobject;

@end

@interface NSURL (UNORoute_add)

- (NSDictionary *)queryParams;

@end

@implementation UNORouter (handlerRegister)

+ (BOOL)regitserHandler:(UNORouteHandler *)handler withPath:(NSURL *)path{
    if (!handler) {
        UN_Route_Action(NSLog(@"handler 不可以是空"));
        return false;
    }
    
    if (![UNORouterInstant validScheme:path.scheme] || ![UNORouterInstant validHost:path.host]) {
        UN_Route_Action(NSLog(@"无效的scehem或者host  %@",path.absoluteString));
        return false;
    }
    
    @synchronized (UNORouterInstant) {
        [UNORouterInstant.handlerMap setObject:handler forKey:path.absoluteString];;
    }
    return YES;
}

+ (void)removeHandlerWithPath:(NSURL *)path{
    if (!path) {
        return;
    }
    @synchronized (UNORouterInstant) {
        [UNORouterInstant.handlerMap removeObjectForKey:path.absoluteString];
    }
}

+ (void)removeAllPath{
    @synchronized (UNORouterInstant) {
        [UNORouterInstant.handlerMap removeAllObjects];
    }
}

@end

@implementation UNORouter (handlerAction)

+ (BOOL)handUrl:(NSURL *)path{
    return [self handUrl:path params:nil callBack:nil completion:nil];
}
+ (BOOL)handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params{
    return [self handUrl:path params:params callBack:nil completion:nil];
}
+ (BOOL)handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack{
    return [self handUrl:path params:params callBack:callBack completion:nil];
}
+ (BOOL)handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params completion:(dispatch_block_t)completion{
    return [self handUrl:path params:params callBack:nil completion:completion];
}

+ (BOOL)handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion{
    if (!path.scheme || !path.host) {
        UN_Route_Action(NSLog(@"无效的URl  %@",path.absoluteString));
        return false;
    }
    if (![UNORouterInstant validScheme:path.scheme] || ![UNORouterInstant validHost:path.host]) {
        UN_Route_Action(NSLog(@"无效的scehem或者host  %@",path.absoluteString));
        return false;
    }
    
    UNORouteHandler *handler = [UNORouterInstant.handlerMap objectForKey:path.absoluteString];
    
    if (!handler) {
        UN_Route_Action(NSLog(@"无效的路径,未注册相应的handler  %@",path.absoluteString));
        return false;
    }
    
    UNORouteHost *host = [UNORouterInstant routeHostWith:path.host];
    UNORouteRequest *request = [[UNORouteRequest alloc] init];
    
    request.host = host;
    request.params = params;
    request.callBack = callBack;
    request.completion = completion;
    request.path = path.absoluteString;
    
    request = [self hook_requestWithOriginReqest:request apiType:UNORoute_Api_TypeDefault];
    
    if ([handler shouldHandleWithRequest:request]) {
        NSError *error = nil;
        BOOL isOK = [handler handleRequest:request error:&error];
        if (!isOK || error){
            UN_Route_Action(NSLog(@"handleRequest error for path %@",path.absoluteString));
        }
        return isOK;
    }else{
        UN_Route_Action(NSLog(@"can not handle the handler %@ for path %@",handler,path.absoluteString));
        return false;
    }
    
}

@end


@implementation UNORouter (fastHandlerAction)

+ (BOOL)fast_handUrl:(NSURL *)path{
    return [self fast_handUrl:path params:nil callBack:nil completion:nil];
}
+ (BOOL)fast_handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params{
    return [self fast_handUrl:path params:params callBack:nil completion:nil];
}
+ (BOOL)fast_handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack{
    return [self fast_handUrl:path params:params callBack:callBack completion:nil];
}
+ (BOOL)fast_handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params completion:(dispatch_block_t)completion{
    return [self fast_handUrl:path params:params callBack:nil completion:completion];
}
+ (BOOL)fast_handUrl:(NSURL *)path params:(NSDictionary<NSString *,id> *)params callBack:(RouteCallBack)callBack completion:(dispatch_block_t)completion{
    if (!path.scheme || !path.host) {
        UN_Route_Action(NSLog(@"无效的URl  %@",path.absoluteString));
        return false;
    }
    
    if (![UNORouterInstant validScheme:path.scheme] || ![UNORouterInstant validHost:path.host]) {
        UN_Route_Action(NSLog(@"无效的scehem或者host  %@",path.absoluteString));
        return false;
    }
    
    UNORouteHandler *handler = [UNORouterInstant.handlerMap objectForKey:path.absoluteString];
    if (!handler) {
        if (path.query != nil) {
            NSDictionary *queryParams = [path queryParams];
            NSString *sbName = [queryParams.allKeys containsObject:UNO_ROUTE_StoryBoard_Name_Key] ?queryParams[UNO_ROUTE_StoryBoard_Name_Key]:nil;
            NSString *sbId = [queryParams.allKeys containsObject:UNO_ROUTE_StoryBoard_ID_Key] ?queryParams[UNO_ROUTE_StoryBoard_ID_Key]:nil;;
            Class cls = [self classWithClassName:sbId storyBoardName:sbName];
            handler = [[cls alloc] init];
        }else if (path.relativePath != nil){
            Class cls = [self classWithClassName:path.lastPathComponent storyBoardName:nil];
            handler = [[cls alloc] init];
        }else{
            return false;
        }
    }
    
    if (!handler) return false;
    
    UNORouteHost *host = [UNORouterInstant routeHostWith:path.host];
    UNORouteRequest *request = [[UNORouteRequest alloc] init];
    NSString * sourceNode = nil;
    if (path.query != nil) {
        NSDictionary *queryParams = [path queryParams];
        sourceNode = [queryParams.allKeys containsObject:UNO_ROUTE_StoryBoard_ID_Key] ?queryParams[UNO_ROUTE_StoryBoard_ID_Key]:nil;;
    }else if (path.relativePath != nil){
        sourceNode = path.lastPathComponent;
    }
    
    void(^wrapCallBack)(id) = ^(id object){
        
        NSMutableDictionary *temp = nil;
        if(!object){
            if (sourceNode) {
                [temp setObject:sourceNode forKey:UNO_ROUTE_SourceNode_Key];
            }
        }else if ([object isKindOfClass:[NSDictionary class]]) {
            temp = [object mutableCopy];
            if (sourceNode) {
                [temp setObject:sourceNode forKey:UNO_ROUTE_SourceNode_Key];
            }
        }else{
            temp = [NSMutableDictionary dictionary];
            if (sourceNode) {
                [temp setObject:sourceNode forKey:UNO_ROUTE_SourceNode_Key];
            }
            [temp setObject:object forKey:@"data"];
        }
        !callBack?:callBack([temp copy]);
        
        if (sourceNode) {
            NSHashTable *table = [UNORouterInstant.observerMap objectForKey:sourceNode];
            if (table && table.count > 0) {
                Class blockClass = NSClassFromString(@"NSBlock");
                for (id object in table) {
                    void(^observeCallback)(NSString *source,id params) = [object uno_associatedobject];
                    if (observeCallback && [observeCallback isKindOfClass:blockClass]) {
                        observeCallback(sourceNode,[temp copy]);
                    }
                }
            }
        }
    };
    
    request.host = host;
    request.params = params;
    request.currenNode = sourceNode;
    request.callBack = wrapCallBack;
    request.completion = completion;
    request.path = path.absoluteString;
    
    request = [self hook_requestWithOriginReqest:request apiType:UNORoute_Api_TypeFast];
    
    NSError *error = nil;
    return [handler handleRequest:request error:&error];
}

+ (Class)classWithClassName:(NSString *)className storyBoardName:(NSString *)storyBoardName{
    if (!className) {
        return NULL;
    }
    
    NSString *newClassName = nil;
    if (storyBoardName) {
        newClassName = [NSString stringWithFormat:@"_%@_at_%@_Handler_Cls",className,storyBoardName];
    }else{
        newClassName = [NSString stringWithFormat:@"_%@_Handler_Cls",className];
    }
    
    Class class = NSClassFromString(newClassName);
    if (class) {
        return class;
    }else{
        Class newCls = objc_allocateClassPair([UNORouteHandler class], newClassName.UTF8String, 0);
        objc_registerClassPair(newCls);
        
        IMP targetVCimp = imp_implementationWithBlock((id)^(UNORouteRequest *request){
            
            if (storyBoardName) {
                UIStoryboard *storyboard = nil;
                @try {
                    storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
                } @catch (NSException *exception) {
                    storyboard = nil;
                    UN_Route_Action([exception raise]);
                    return  (id)nil;
                } @finally {
                    if (storyboard != nil) {
                        return (id)[storyboard instantiateViewControllerWithIdentifier:className];
                    }
                }
            }
            
            Class vcCls = NSClassFromString(className);
            
            if (vcCls) {
                id targetViewController = nil;
                
                @try {
                    targetViewController = [[NSBundle mainBundle] loadNibNamed:className owner:nil options:nil].lastObject;
                    
                    if (![targetViewController isKindOfClass:[UIViewController class]]) {
                        targetViewController = nil;
                    }
                } @catch (NSException *exception) {
                    
                    targetViewController = nil;
                    
                } @finally {
                    if (targetViewController) {
                        return (id)targetViewController;
                    } else {
                        if ([vcCls isSubclassOfClass:[UIViewController class]]) {
                            if ([vcCls isSubclassOfClass:[UITableViewController class]]){
                                UITableViewController *tableViewController = [[vcCls alloc] initWithStyle:UITableViewStyleGrouped];
                                tableViewController.hidesBottomBarWhenPushed = YES;
                                return (id)tableViewController;
                            }
                            UIViewController *viewController = [[vcCls alloc] init];
                            viewController.hidesBottomBarWhenPushed = YES;
                            return (id)viewController;
                        } else {
                            UIViewController *viewController = [[vcCls alloc] init];
                            viewController.hidesBottomBarWhenPushed = YES;
                            return (id)viewController;
                        }
                    }
                }
                
            } else {
                UN_Route_Action(NSLog(@"have not found className == \"%@\"  to push or present",className));
                return (id)nil;
            }
        });
        
        static const char * typeEncoding = NULL;
        if (typeEncoding != NULL) {
            class_addMethod(newCls, @selector(targetViewControllerWithRequest:), targetVCimp, typeEncoding);
        } else {
            Method targetVCMethod = class_getInstanceMethod([UNORouteHandler class], @selector(targetViewControllerWithRequest:));
            typeEncoding = method_getTypeEncoding(targetVCMethod);
            class_addMethod(newCls, @selector(targetViewControllerWithRequest:), targetVCimp, typeEncoding);
        }
        return newCls;
    }
}

@end

@implementation UNORouter (handlerAction_hook)
+ (UNORouteRequest *)hook_requestWithOriginReqest:(UNORouteRequest *)originRequest apiType:(UNORoute_Api_Type)apiType{
    return originRequest;
}
@end


@implementation UNORouter (observing)

+ (void)addObserve:(id)observe toNode:(NSString *)node callBack:(void(^)(NSString *sourceNode, NSDictionary *param))callBack{

    if (!observe || !node || !callBack) return;
    NSHashTable *table = nil;
    if ([UNORouterInstant.observerMap.keyEnumerator.allObjects containsObject:node]) {
        table = [UNORouterInstant.observerMap objectForKey:node];
    }else{
        table = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    
    [observe uno_setAssociatedobject:callBack];
    [table addObject:observe];
    [UNORouterInstant.observerMap setObject:table forKey:node];
    
    NSLog(@"--->%@",UNORouterInstant.observerMap);
}

@end

@implementation NSURL (UNORoute_add)

- (NSDictionary *)queryParams{
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];

    NSArray *components = [self.query componentsSeparatedByString:@"&"];
    for (NSString *component in components) {
        NSRange range = [component rangeOfString:@"="];
        if (range.location == NSNotFound || range.location == 0 || range.location == component.length-1) {
            //当”=“ 不存在或者在头部或者在尾部,无效
            continue;
        }
        NSArray *stringComponents = [component componentsSeparatedByString:@"="];
        if (stringComponents.count == 2) {
            [queryParams setObject:stringComponents[1] forKey:stringComponents[0]];
        }
    }
    
    return [queryParams copy];
}

@end


static NSString *const UNO_AssociatedObject_key;
@implementation NSObject (UNORoute_associatedobject)

- (void)uno_setAssociatedobject:(id)obj{
    objc_setAssociatedObject(self, &UNO_AssociatedObject_key, obj, OBJC_ASSOCIATION_COPY);
}

- (id)uno_associatedobject{
    return objc_getAssociatedObject(self, &UNO_AssociatedObject_key);
}


@end

NSString *const UNO_ROUTE_StoryBoard_Name_Key = @"__UNO_ROUTE_StoryBoard_Name_Key";
NSString *const UNO_ROUTE_StoryBoard_ID_Key = @"_UNO_ROUTE_StoryBoard_ID_Key";

NSString *const UNO_ROUTE_SourceNode_Key = @"SourceNode";
