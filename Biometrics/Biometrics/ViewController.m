//
//  ViewController.m
//  Biometrics
//
//  Created by xydtech on 17/3/10.
//  Copyright © 2017年 xiaoyudiantech. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define NSLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)touchPayBtn:(UIButton *)btn
{
    __weak typeof(self) ws = self;
    LAContext * context = [LAContext new];
    context.localizedFallbackTitle = @"输入密码";
    NSError * error;
    
    //判断设备是否支持指纹识别
    if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]){
        //验证指纹
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"指纹解锁" reply:^(BOOL success, NSError * _Nullable error) {
            //验证成功
            if (success) {
                //支付请求
                //处理支付流程
                NSLog(@"指纹验证成功");
            }else{
                NSLog(@"%@", error.localizedDescription);
                switch (error.code) {
                    case LAErrorAuthenticationFailed:
                        NSLog(@"验证信息出错，就是说你指纹不对,错误三次");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"弹出输入密码界面");
                        });
                        break;
                        
                    case LAErrorUserFallback:                        NSLog(@"验证失败点击了输入密码按钮");
                        NSLog(@"弹出输入密码界面");
                        break;
                        
                    case LAErrorUserCancel:
                    {
                        NSLog(@"验证失败点击了取消按钮");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否取消指纹验证" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                            }];
                            [alert addAction:sureAction];
                            [ws presentViewController:alert animated:YES completion:^{
                            }];
                        });
                    }
                        break;
                        
                    case LAErrorSystemCancel:
                        NSLog(@"验证失败因为某种设备原因,比如按下HOME键");
                        break;
                        
                    case LAErrorTouchIDLockout://iOS 9.0 后添加的枚举值
                        NSLog(@"指纹认证错误次数太多，现在被锁住了");
                        NSLog(@"弹出输入密码界面");
                        break;
                        
                    case LAErrorAppCancel://iOS 9.0 后添加的枚举值
                        NSLog(@"在验证中被其他app中断,比如来电等");
                        break;
                        
                    case LAErrorInvalidContext://iOS 9.0 后添加的枚举值
                        NSLog(@"请求验证出错");
                        break;
                        
                    default:
                        break;
                }
                
            }
        }];
    }else{//设备不支持
        
        NSLog(@"%@", error.localizedDescription);
        
        switch (error.code) {
            case LAErrorTouchIDNotAvailable:
            {
                NSLog(@"次设备不支持Touch ID");
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"次设备不支持Touch ID" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"马上换手机!!!" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.apple.com/cn/iphone-7/"]];
                    }];
                    [alert addAction:cancelAction];
                    [alert addAction:sureAction];
                    [ws presentViewController:alert animated:YES completion:^{
                    }];
                });
            }
                break;
                
            case LAErrorPasscodeNotSet:
                NSLog(@"您没有设置Touch ID, 请先设置Touch ID");
                break;
                
            case LAErrorTouchIDNotEnrolled:
                NSLog(@"您没有设置手指指纹,请先设置手指指纹");
                break;
                
            case LAErrorTouchIDLockout://iOS 9.0 后添加的枚举值
                NSLog(@"指纹认证错误次数太多，现在被锁住了");
                NSLog(@"切换至输入密码界面");
                break;
                
            default:
                break;
                
        }
    }
}



@end
