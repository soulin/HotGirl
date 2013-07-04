//
//  BaiduZhidaoHelper.h
//  IKnow
//
//  Created by 李云天 on 10-9-8.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HotGirl;

@interface HotGirlHelper : NSObject {

}

// 释放链接
+ (void)finalizeStatements;

// 单例
+ (id) singleton;

// 获取Girl的数量
+ (NSUInteger)fetchGirlsCount;

// 获取所有Girls
+ (NSMutableDictionary *)fetchGirls;
// 获取所有Girls，只取ID和姓名
+ (NSMutableDictionary *)fetchGirlsLite;
// 获取所有Girls，只取ID
+ (NSMutableArray *)fetchGirlIds;

// 获取某个Girl
+ (HotGirl *)fetchGirl:(NSUInteger)girlId;

// 获取某个Girl的图片
+ (NSMutableArray *) fetchGirlFotoes:(NSUInteger)girlId;


@end
