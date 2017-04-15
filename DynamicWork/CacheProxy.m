//
//  CacheProxy.m
//  DynamicWork
//
//  Created by junbin on 17/4/15.
//  Copyright © 2017年 junbinchen. All rights reserved.
//

#import "CacheProxy.h"
#import <objc/runtime.h>

@interface CacheProxy ()

@property (nonatomic,strong) id object;
@property (nonatomic,strong) NSMutableDictionary *valueForProperty;

@end

@implementation CacheProxy

// setFoo: -> foo
// 通过 selector 得到属性名
static NSString *propertyNameForSelector(SEL selector){
    NSMutableString *name = [NSStringFromSelector(selector) mutableCopy];
    [name deleteCharactersInRange:NSMakeRange(0, 3)];
    [name deleteCharactersInRange:NSMakeRange([name length] - 1, 1)];
    NSString *firstC = [name substringToIndex:1];
    [name replaceCharactersInRange:NSMakeRange(0, 1) withString:[firstC lowercaseString]];
    return name;
}

// foo -> setFoo:
// 通过属性名得到 selector
static SEL setterForPropertyName(NSString *property){
    NSMutableString *name = [property mutableCopy];
    NSString *FirstC = [name substringToIndex:1];
    [name replaceCharactersInRange:NSMakeRange(0, 1) withString:[FirstC uppercaseString]];
    [name insertString:@"set" atIndex:0];
    [name appendString:@":"];
    return NSSelectorFromString(name);
}

// getter 方法实现
static id propertyIMP(id self, SEL _cmd){
    NSString *propertyName = NSStringFromSelector(_cmd);
    id value = [[self valueForProperty] valueForKey:propertyName];
    // NSMutableDictionary 不能存储 nil，所以使用 NSNull 来处理 nil
    if (value == [NSNull null]) {
        return nil;
    }
    
    if (value) {
        return value;
    }
    
    // 从缓存对象取不到属性值的话，那么从原对象取属性值
    value = [[self object] valueForKey:propertyName];
    // 从原对象取属性值之后，将属性值缓存到缓存对象
    [[self valueForProperty] setValue:value forKey:propertyName];
    
    return value;
}

// setter 方法实现
static void setPropertyIMP(id self, SEL _cmd, id aValue){
    id value = [aValue copy];
    NSString *propertyName = propertyNameForSelector(_cmd);
    // 先将属性值设置到缓存对象，再将属性值设置到原对象
    [[self valueForProperty] setValue:(value != nil ? value : [NSNull null]) forKey:propertyName];
    [[self object] setValue:value forKey:propertyName];
}


- (id)initWithObject:(id)anObject properties:(NSArray *)properties{
    _object = anObject;
    _valueForProperty = [NSMutableDictionary new];
    // 缓存对象为 anObject 的所有属性生成 setter 和 getter 方法
    for(NSString *property in properties){
        // 添加 getter 方法
        class_addMethod([self class], NSSelectorFromString(property), (IMP)propertyIMP, "@@:");
        // 添加 setter 方法
        class_addMethod([self class], setterForPropertyName(property), (IMP)setPropertyIMP, "v@:@");
    }
    return self;
}

// 覆写以下方法，CacheProxy 缓存对象对外可以被识别为 object 对象
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ (%@)",[super description],self.object];
}

- (BOOL)isEqual:(id)object{
    return [self.object isEqual:object];
}

- (NSUInteger)hash{
    return [self.object hash];
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    return [self.object respondsToSelector:aSelector];
}

- (BOOL)isKindOfClass:(Class)aClass{
    return [self.object isKindOfClass:aClass];
}


// 如果有未知的选择器发送到 CacheProxy 缓存对象，在这里把所有的未知选择器都发送给代理对象。
// 快速转发
- (id)forwardingTargetForSelector:(SEL)aSelector{
    return self.object;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    return [self.object methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    [invocation setTarget:self.object];
    [invocation invoke];
}

@end
