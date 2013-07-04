//
//  HotGirl.m
//  HotGirl
//
//  Created by 李云天 on 10-10-19.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "HotGirl.h"


@implementation HotGirl
@synthesize 	girlId, girlName, website, qq;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Girl ID: %i, name: %@, website: %@, qq: %@", girlId, girlName, website, qq];
}

- (void)dealloc
{
    [girlName release];
	[website release];
	[qq release];
	
    [super dealloc];
}
@end
