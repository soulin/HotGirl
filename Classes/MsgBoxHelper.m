//
//  MsgBoxHelper.m
//  IKnow
//
//  Created by 李云天 on 10-9-13.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "MsgBoxHelper.h"


@implementation MsgBoxHelper

+ (void) showMsgBoxOK:(NSString *)msg fromDeleate:(id)delegate
{
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:appName
						  message:msg								
						  delegate:delegate
						  cancelButtonTitle:NSLocalizedString(@"ButtonOK", nil)
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

+ (void) showMsgBoxOKCancel:(NSString *)msg fromDeleate:(id)delegate
{
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:appName
						  message:msg								
						  delegate:delegate
						  cancelButtonTitle:NSLocalizedString(@"ButtonCancel", nil)
						  otherButtonTitles:NSLocalizedString(@"ButtonOK", nil), nil];
	[alert show];
	[alert release];
}

@end
