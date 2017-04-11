//
//  Person.m
//  DynamicWork
//
//  Created by junbin on 17/4/11.
//  Copyright © 2017年 junbinchen. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

@interface Person ()
@property (nonatomic,strong) NSMutableDictionary *properties;
@end

@implementation Person
// @dynamic, 其实这个是在向编译器保证，虽然现在这个属性找不到 setter 和 getter 方法，
// 但是在运行时会有可用的实现，你编译器不要自动帮我合成 ivar 了
@dynamic firstName,lastName;

- (id)init{
    if (self = [super init]) {
        _properties = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// getter 方法
static id propertyIMP(id self, SEL _cmd){
    return [[self properties] valueForKey:NSStringFromSelector(_cmd)];
}

// setter 方法
static void setPropertyIMP(id self,SEL _cmd, id aValue){
    id value = [aValue copy];
    // 使用 mutableCopy 而不是 copy
    NSMutableString *key = [NSStringFromSelector(_cmd) mutableCopy];
    // 删除 “set”
    [key deleteCharactersInRange:NSMakeRange(0, 3)];
    // 删除 “：”
    [key deleteCharactersInRange:NSMakeRange([key length] -1, 1)];
    // 将第一个字母变为小写
    NSString *firstC = [key substringToIndex:1];
    [key replaceCharactersInRange:NSMakeRange(0, 1) withString:[firstC lowercaseString]];
    // 保存对应属性的值
    [[self properties] setValue:value forKey:key];
}

// 这里假设所有不能识别的方法都是 setter 方法或者 getter 方法
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if ([NSStringFromSelector(sel) hasPrefix:@"set"]) {
        // 第一个字符 v 表明返回值是一个 void。
        // 接下来的二个字符 @： 表明该方法接受一个 id 和一个 SEL
        // 最后一个字符是方法的显式参数 @ 表示是一个 id
        class_addMethod([self class], sel, (IMP)setPropertyIMP, "v@:@");
    }else{
        // 第一个字符 @ 表明返回值是一个 id。
        // 对于消息传递系统来说，所以的 Objective-C 对象都是 id 类型。
        // 接下来的二个字符 @： 表明该方法接受一个 id 和一个 SEL
        class_addMethod([self class], sel, (IMP)propertyIMP, "@:@");
    }
    return YES;
}

@end
