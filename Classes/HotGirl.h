//
//  HotGirl.h
//  HotGirl
//
//  Created by 李云天 on 10-10-19.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HotGirl : NSObject {
	NSUInteger girlId;
	NSString *girlName;
	NSString *website;
	NSString *qq;
}
@property (nonatomic, assign) NSUInteger girlId;
@property (nonatomic, copy) NSString *girlName;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, copy) NSString *qq;

@end
