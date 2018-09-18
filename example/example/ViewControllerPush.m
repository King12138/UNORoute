//
//  ViewControllerPush.m
//  example
//
//  Created by intebox on 2018/9/18.
//  Copyright © 2018年 unovo. All rights reserved.
//

#import "ViewControllerPush.h"

@interface ViewControllerPush ()
@property (nonatomic, strong) UIButton *pressPushButton;
@property (nonatomic, strong) UIButton *pressPopButton;
@end

@implementation ViewControllerPush
#pragma mark-
#pragma mark- getter
- (UIButton *)pressPushButton{
    if (!_pressPushButton) {
        _pressPushButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pressPushButton setTitle:@"press me to push" forState:UIControlStateNormal];
        [_pressPushButton setTitleColor:[UIColor colorWithWhite:0x42/255.0f alpha:1]
                           forState:UIControlStateNormal];
        [_pressPushButton addTarget:self action:@selector(pressme:) forControlEvents:UIControlEventTouchDown];
        _pressPushButton.center = self.view.center;
        _pressPushButton.bounds = CGRectMake(0, 0, 200,50);
    }
    return _pressPushButton;
}

- (UIButton *)pressPopButton{
    if (!_pressPopButton) {
        _pressPopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pressPopButton setTitle:@"press me to pop" forState:UIControlStateNormal];
        [_pressPopButton setTitleColor:[UIColor colorWithWhite:0x42/255.0f alpha:1]
                           forState:UIControlStateNormal];
        [_pressPopButton addTarget:self action:@selector(pressme:) forControlEvents:UIControlEventTouchDown];
        _pressPopButton.center = CGPointMake(self.view.center.x, self.view.center.y + 50);
        _pressPopButton.bounds = CGRectMake(0, 0, 200,50);
    }
    return _pressPopButton;
}

#pragma mark-
#pragma mark- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pressPopButton];
    [self.view addSubview:self.pressPushButton];
}

#pragma mark-
#pragma mark- private

- (void)pressme:(UIButton *)button{
    if ([button isEqual:self.pressPushButton]) {
        //just push
        //will auto regitst for you with NodeId which must be same with the class
        //fast系列api
        //自动使用NodeId ViewControllerWithParams注册 默认反射到ViewControllerWithParams类型
        [self fast_pushWithNodeId:@"ViewControllerWithParams"
                           params:@{@"test":@"king"}
                         callBack:^(id param) {
                           NSLog(@"call back with %@",param);
                         }
                       completion:^{
                           NSLog(@"push action is completion");
                       }];
    }else{
        [self uno_back];
    }
}


@end
