//
//  ViewController.m
//  example
//
//  Created by intebox on 2018/9/18.
//  Copyright © 2018年 unovo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *pressButton;

@end

@implementation ViewController

#pragma mark-
#pragma mark- getter
- (UIButton *)pressButton{
    if (!_pressButton) {
        _pressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pressButton setTitle:@"press me to push" forState:UIControlStateNormal];
        [_pressButton setTitleColor:[UIColor colorWithWhite:0x42/255.0f alpha:1]
                           forState:UIControlStateNormal];
        [_pressButton addTarget:self action:@selector(pressme) forControlEvents:UIControlEventTouchDown];
        _pressButton.center = self.view.center;
        _pressButton.bounds = CGRectMake(0, 0, 200,50);
    }
    return _pressButton;
}

#pragma mark-
#pragma mark- lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);
    [self.view addSubview:self.pressButton];
    
    //register handler yourself
    Class PushVcHandler = NSClassFromString(@"PushVcHandler");
    [UNORouter regitserHandler:[[PushVcHandler alloc] init]
                      withPath:UNORoute_PathMaker(@"MTKToute",@"example",@"ppppppp")];
}

#pragma mark-
#pragma mark- private
- (void)pressme{
    [self pushWithNodeId:@"ppppppp"];
}

@end
