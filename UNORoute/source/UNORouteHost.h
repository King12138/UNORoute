//
//  UNORouteHost.h
//  UNOBleTest
//
//  Created by intebox on 2017/5/27.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;
@interface UNORouteHost : NSObject

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, weak) UIViewController * rootViewController;


//只有在viewcontroller确认出现才会添加
@property (nonatomic, strong) NSMutableArray *subPathes;
@property (nonatomic, strong) NSMapTable *subResources;

- (UIViewController *)objectForKeyedSubscript:(NSString *)key;

@end


