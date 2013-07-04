/*
 *  Constants.h
 *  IHomeWiki
 *
 *  Created by mantou on 10-8-5.
 *  Copyright 2010 iHomeWiki. All rights reserved.
 *
 */

// 是否是调试模式
#define kDEBUGMODE					YES

// 美空网址
#define kMokoWebsite				@"http://moko.cc";

// 关于信息
#define kIHomeWikiVersion			@"1.0.0"
#define kIHomeWikiWebsite			@"http://www.ihomewiki.com/"
#define kIHomeWikiCopyright			@"(C) 2010 iHomeWiki"

#define kIHomeWikiCopyrightOfTopGirl		@"(C) 2010 iHomeWiki"
#define kIHomeWikiWebsiteOfTopGirl			@"http://www.ihomewiki.com/topgirl"

// 是否显示Girl Name
#define kSHOWGIRLNAME				NO

// 数据库文件名
#define kSQLiteFileName			@"hotgirl.dat"

// iPhone 屏幕的尺寸
#define kScrenRect [[UIScreen mainScreen] bounds]
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

// 相册的宽高，横屏
#define kFotoAlbumThumbWidthLandscape		(kScreenHeight - 9) / 9
#define kFotoAlbumThumbHeightLandscape		kScreenWidth

// 每行3个
#define kFotoAlbumThumbHorizontalNumber 3
// 每列3个
#define kFotoAlbumThumbVerticalNumber 3
// 相册的宽高，竖屏
#define kFotoAlbumThumbWidth		(kScreenWidth - kFotoAlbumThumbHorizontalNumber) / kFotoAlbumThumbHorizontalNumber
#define kFotoAlbumThumbHeight	(kScreenHeight - kFotoAlbumThumbVerticalNumber) / kFotoAlbumThumbVerticalNumber

// 每页显示的相册数量
#define kFotoAlbumThumbPerPage 9 //kFotoAlbumThumbHorizontalNumber * kFotoAlbumThumbVerticalNumber

// 相册的顶部高度
#define kFotoAlbumThumbTop		1.0f
#define kFotoAlbumThumbLeft		1.0f

// 提交信息到服务器
#define kReportBugURL @"http://ihomewiki.com/reportbug/bug.php?do=hotgirlbug&id=%d"

// 提交邮件
#define kReportEmail @"ihomewiki@me.com"