//
//  ViewController.m
//  DynamicWork
//
//  Created by junbin on 17/4/11.
//  Copyright © 2017年 junbinchen. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Person *person = [[Person alloc] init];
    [person setFirstName:@"AAAA"];
    [person setLastName:@"BBBB"];
    NSLog(@"firstName-->%@,  lastName--->%@",person.firstName,person.lastName);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
