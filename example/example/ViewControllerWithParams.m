//
//  ViewControllerWithParams.m
//  example
//
//  Created by intebox on 2018/9/18.
//  Copyright © 2018年 unovo. All rights reserved.
//

#import "ViewControllerWithParams.h"

@interface ViewControllerWithParams ()
@property (nonatomic, strong) UIButton *pressPopButton;
@property (nonatomic, strong) UIButton *pressCallbackButton;
@end

@implementation ViewControllerWithParams

#pragma mark-
#pragma mark- getter
- (UIButton *)pressPopButton{
    if (!_pressPopButton) {
        _pressPopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pressPopButton setTitle:@"press me to pop" forState:UIControlStateNormal];
        [_pressPopButton setTitleColor:[UIColor colorWithWhite:0x42/255.0f alpha:1]
                              forState:UIControlStateNormal];
        [_pressPopButton addTarget:self action:@selector(pressme:) forControlEvents:UIControlEventTouchDown];
        _pressPopButton.center = CGPointMake(self.view.center.x, self.view.center.y);
        _pressPopButton.bounds = CGRectMake(0, 0, 200,50);
    }
    return _pressPopButton;
}

- (UIButton *)pressCallbackButton{
    if (!_pressCallbackButton) {
        _pressCallbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pressCallbackButton setTitle:@"press me to invoke callback" forState:UIControlStateNormal];
        [_pressCallbackButton setTitleColor:[UIColor colorWithWhite:0x42/255.0f alpha:1]
                              forState:UIControlStateNormal];
        [_pressCallbackButton addTarget:self action:@selector(pressme:) forControlEvents:UIControlEventTouchDown];
        _pressCallbackButton.center = CGPointMake(self.view.center.x, self.view.center.y + 50);
        _pressCallbackButton.bounds = CGRectMake(0, 0, 250,50);
    }
    return _pressCallbackButton;
}

#pragma mark-
#pragma mark- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pressPopButton];
    [self.view addSubview:self.pressCallbackButton];
}

#pragma mark-
#pragma mark- private

- (void)pressme:(UIButton *)button{
    if ([button isEqual:self.pressPopButton]){
         [self uno_back];
    }else{
        self.uno_request.callBack(@"call back from paramviewcontroller");
    }
}

@end
