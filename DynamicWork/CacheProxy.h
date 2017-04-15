//
//  CacheProxy.h
//  DynamicWork
//
//  Created by junbin on 17/4/15.
//  Copyright © 2017年 junbinchen. All rights reserved.
//

#import <Foundation/Foundation.h>
// 快速转发 ：若是有未知的选择器发送到 CacheProxy，objc_msgSend 都会调用 CacheProxy 的 forwardingTargetForSelector: 方法，如果这个方法返回一个对象，那么 objc_msgSend 会试着将这个未知的选择器发送给返回的那个对象。
@interface CacheProxy : NSProxy
// 初始化方法 ，返回类型为 id 类型，可以避免编译器报错
- (id)initWithObject:(id)anObject properties:(NSArray *)properties;
@end

