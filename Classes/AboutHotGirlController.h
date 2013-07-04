//
//  AboutHotGirlController.h
//  HotGirl
//
//  Created by liyuntian on 10-11-5.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutHotGirlController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
	UITableView *aboutTable;
	
	NSMutableDictionary *apps;
	
	NSMutableDictionary *aboutInfo;
	NSMutableArray *aboutKeys;
	
	NSString *tempUrl;
}

@property(nonatomic,retain) IBOutlet UITableView *aboutTable;

@property(nonatomic,retain) NSMutableDictionary *apps;
@property(nonatomic,retain) NSMutableDictionary *aboutInfo;
@property(nonatomic,retain) NSMutableArray *aboutKeys;
@property(nonatomic,assign) NSString *tempUrl;


@end
