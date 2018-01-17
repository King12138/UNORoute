//
//  UNORouteRequest.m
//  UNOBleTest
//
//  Created by intebox on 2017/5/27.
//  Copyright © 2017年 KIng. All rights reserved.
//

#import "UNORouteRequest.h"

@implementation UNORouteRequest
@synthesize paramsWithoutNUllValue = _paramsWithoutNUllValue;

- (void)dealloc{
    self.callBack = nil;
    self.completion = nil;
}


- (NSDictionary *)paramsWithoutNUllValue{
    if (_paramsWithoutNUllValue == nil && self.params != nil) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        for (id key in self.params) {
            id value = self.params[key];
            if ([value isKindOfClass:[NSNull class]]) {
                continue;
            }
            [temp setValue:value forKey:key];
        }
        _paramsWithoutNUllValue = temp.copy;
    }
    
    return _paramsWithoutNUllValue;
}

- (void)setParams:(NSDictionary *)params{
    if (params != _params) {
        _params = params;
        _paramsWithoutNUllValue = nil;
    }
}

- (id)objectForKeyedSubscript:(NSString *)key{
    if (!key) {
        return nil;
    }
    return self.params[key];
}

@end
