//
//  ViewController.m
//  DynamicWork
//
//  Created by junbin on 17/4/11.
//  Copyright © 2017年 junbinchen. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "CachePerson.h"
#import "CacheProxy.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Person *person = [[Person alloc] init];
    [person setFirstName:@"AAAA"];
    [person setLastName:@"BBBB"];
    NSLog(@"Person  : firstName-->%@,  lastName--->%@",person.firstName,person.lastName);
    
    // 说明 CacheProxy 如何缓存其他对象的 setter 和 getter 方法
    NSLog(@"------------------------------------------");
    id cachePerson = [[CachePerson alloc] init];
    id cacheProxy = [[CacheProxy alloc] initWithObject:cachePerson properties:@[@"firstName",@"lastName"]];
    // 设置 CacheProxy 对象的属性， cachePerson 这个被代理对象的属性也有值
    [cacheProxy setFirstName:@"CCCC"];
    [cacheProxy setLastName:@"DDDD"];
    NSLog(@"CacheProxy : firstName-->%@,  lastName--->%@",[cacheProxy firstName],[cacheProxy lastName]);
    NSLog(@"CachePerson : firstName-->%@,  lastName--->%@",[cachePerson firstName],[cachePerson lastName]);
    
    // 说明快速转发
    NSLog(@"------------------------------------------");
    // 只设置被代理对象 CachePerson 的属性，利用快速转发的特性 CacheProxy 也能拿到 CachePerson 的属性
    id cachePerson2 = [[CachePerson alloc] init];
    [cachePerson2 setFirstName:@"EEEE"];
    [cachePerson2 setLastName:@"FFFF"];

    id cacheProxy2 = [[CacheProxy alloc] initWithObject:cachePerson2 properties:@[@"firstName"]];
    NSLog(@"CacheProxy2 : firstName-->%@,  lastName--->%@",[cacheProxy2 firstName],[cacheProxy2 lastName]);
    NSLog(@"CachePerson2 : firstName-->%@,  lastName--->%@",[cachePerson2 firstName],[cachePerson2 lastName]);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
