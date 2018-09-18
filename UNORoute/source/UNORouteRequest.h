//
//  UNORouteRequest.h
//  UNOBleTest
//
//  Created by intebox on 2017/5/27.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UNORouteHost.h"


@interface UNORouteRequest : NSObject

@property (nonatomic, strong) UNORouteHost *host;
@property (nonatomic, strong) NSString *path;

@property (nonatomic, strong) NSString *currenNode;
@property (nonatomic, strong) NSString *fromNode;
@property (nonatomic, strong) UIViewController *fromViewController;

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong,readonly) NSDictionary *paramsWithoutNUllValue;

@property (nonatomic, copy) void(^callBack)(id);
@property (nonatomic, copy) dispatch_block_t completion;


- (id)objectForKeyedSubscript:(NSString *)key;

@end
