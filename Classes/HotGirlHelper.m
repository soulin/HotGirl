//
//  BaiduZhidaoHelper.m
//  IKnow
//
//  Created by 李云天 on 10-9-8.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "HotGirlHelper.h"
#import "Constants.h"
#import "HotGirl.h"
#import "SQLiteHelper.h"

// 数据库连接
static sqlite3 *kSQLiteDB;
// SQLite帮助类
static SQLiteHelper *kSqlite;

@implementation HotGirlHelper

// 单例
+ (id) singleton
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if ((self=[super init]) ) {
		if (kSQLiteDB == nil)
		{
			if (kSqlite == nil) 
            {
				kSqlite = [[SQLiteHelper alloc] init];
			}
			[kSqlite createEditableCopyOfDatabaseIfNeeded];
			[kSqlite initializeDatabase];
			
			kSQLiteDB = [kSqlite database];
		}
	}
	
	return self;
}


// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *fetch_girl_statement = nil;
static sqlite3_stmt *fetch_girls_statement = nil;
static sqlite3_stmt *fetch_girlscount_statement = nil;
static sqlite3_stmt *fetch_fotoes_statement = nil;


// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements
{
	if (fetch_girl_statement) sqlite3_finalize(fetch_girl_statement);
	if (fetch_girls_statement) sqlite3_finalize(fetch_girls_statement);
	if (fetch_girlscount_statement) sqlite3_finalize(fetch_girlscount_statement);
	if (fetch_fotoes_statement) sqlite3_finalize(fetch_fotoes_statement);
}

// 获取Girl的数量
+ (NSUInteger)fetchGirlsCount
{
	NSUInteger girlsCount = 0;
	
	// Compile the query for retrieving BaiduZhidao data.
	if (fetch_girlscount_statement == nil) {
		// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT COUNT(*) AS total FROM hotgirl_girls";
		if (sqlite3_prepare_v2(kSQLiteDB, sql, -1, &fetch_girlscount_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(kSQLiteDB));
		}
	}
	
	if (sqlite3_step(fetch_girlscount_statement) == SQLITE_ROW)
	{
		girlsCount = sqlite3_column_int(fetch_girlscount_statement, 0);
	}
	
	// Reset the statement for future reuse.
	sqlite3_reset(fetch_girlscount_statement);
	
	return girlsCount;
}

// 获取所有Girls
+ (NSMutableDictionary *)fetchGirls
{
	NSMutableDictionary *girls = [NSMutableDictionary dictionary];
	
	// Compile the query for retrieving BaiduZhidao data.
	if (fetch_girls_statement == nil) {
		// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT girlId, girlName, IFNULL(website, ''), IFNULL(qq, '') FROM hotgirl_girls ORDER BY girlId";
		if (sqlite3_prepare_v2(kSQLiteDB, sql, -1, &fetch_girls_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(kSQLiteDB));
		}
	}
	
	while (sqlite3_step(fetch_girls_statement) == SQLITE_ROW)
	{
		NSUInteger girlId = sqlite3_column_int(fetch_girls_statement, 0);
		NSString *girlName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girls_statement, 1)];
		
		NSString *website;
		@try {
			website = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girls_statement, 2)];
		}
		@catch (NSException * e) {
			website = @"";
		}
		//NSString *website = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girls_statement, 2)];
		
		NSString *qq;
		@try {
			qq = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girls_statement, 3)];
		}
		@catch (NSException * e) {
			qq = @"";
		}
		//NSString *qq = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girls_statement, 3)];
		
		HotGirl *girl = [[[HotGirl alloc] init] autorelease];
		girl.girlId = girlId;
		girl.girlName = girlName;
		girl.website = website;
		girl.qq = qq;
		
		[girls setObject:girl forKey:[NSString stringWithFormat:@"%d", girlId]];
	}
	
	// Reset the statement for future reuse.
	sqlite3_reset(fetch_girls_statement);
	sqlite3_finalize(fetch_girls_statement);
	
	return girls;
}

// 获取所有Girls，只取ID和姓名
+ (NSMutableDictionary *)fetchGirlsLite
{
	NSMutableDictionary *girls = [NSMutableDictionary dictionary];
	
	// Compile the query for retrieving BaiduZhidao data.
	if (fetch_girls_statement == nil) {
		// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT girlId, girlName, IFNULL(website, ''), IFNULL(qq, '') FROM hotgirl_girls ORDER BY girlId";
		if (sqlite3_prepare_v2(kSQLiteDB, sql, -1, &fetch_girls_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(kSQLiteDB));
		}
	}
	
	while (sqlite3_step(fetch_girls_statement) == SQLITE_ROW)
	{
		NSString *girlId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girls_statement, 0)];
		NSString *girlName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girls_statement, 1)];
		
		[girls setObject:girlName forKey:girlId];
	}
	
	// Reset the statement for future reuse.
	sqlite3_reset(fetch_girls_statement);
	sqlite3_finalize(fetch_girls_statement);
	
	return girls;
}

// 获取所有Girls，只取ID
+ (NSMutableArray *)fetchGirlIds
{
	NSMutableArray *girls = [NSMutableArray array];
	
	// Compile the query for retrieving BaiduZhidao data.
	if (fetch_girls_statement == nil) {
		// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT girlId, girlName, IFNULL(website, ''), IFNULL(qq, '') FROM hotgirl_girls ORDER BY girlId";
		if (sqlite3_prepare_v2(kSQLiteDB, sql, -1, &fetch_girls_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(kSQLiteDB));
		}
	}
	
	while (sqlite3_step(fetch_girls_statement) == SQLITE_ROW)
	{
		NSString *girlId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girls_statement, 0)];
		
		[girls addObject:girlId];
	}
	
	// Reset the statement for future reuse.
	sqlite3_reset(fetch_girls_statement);
	sqlite3_finalize(fetch_girls_statement);
	
	return girls;
}

// 获取某个Girl
+ (HotGirl *)fetchGirl:(NSUInteger)girlId
{
	HotGirl *girl = [[[HotGirl alloc] init] autorelease];
	
	// Compile the query for retrieving BaiduZhidao data.
	if (fetch_girl_statement == nil) {
		// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT girlId, girlName, IFNULL(website, ''), IFNULL(qq, '') FROM hotgirl_girls WHERE girlId = ?";
		if (sqlite3_prepare_v2(kSQLiteDB, sql, -1, &fetch_girl_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(kSQLiteDB));
		}
	}
	// For this query, we bind the primary key to the first (and only) placeholder in the statement.
	// Note that the parameters are numbered from 1, not from 0.
	sqlite3_bind_int(fetch_girl_statement, 1, girlId);
	
	if (sqlite3_step(fetch_girl_statement) == SQLITE_ROW)
	{
		NSUInteger girlId = sqlite3_column_int(fetch_girl_statement, 0);
		NSString *girlName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girl_statement, 1)];
		
		NSString *website;
		@try {
			website = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girl_statement, 2)];
		}
		@catch (NSException * e) {
			website = @"";
		}
		//NSString *website = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girl_statement, 2)];
		
		NSString *qq;
		@try {
			qq = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girl_statement, 3)];
		}
		@catch (NSException * e) {
			qq = @"";
		}
		//NSString *qq = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_girl_statement, 3)];		
		
		girl.girlId = girlId;
		girl.girlName = girlName;
		girl.website = website;
		girl.qq = qq;
	}
	else
	{
		girl.girlId = 0;
		girl.girlName = nil;
		girl.website = nil;
		girl.qq = nil;
	}
	// Reset the statement for future reuse.
	sqlite3_reset(fetch_girl_statement);
	
	return girl;
}

// 获取某个Girl的图片
+ (NSMutableArray *) fetchGirlFotoes:(NSUInteger)girlId
{
	NSMutableArray *fotoes = [NSMutableArray array];
	
	// Compile the query for retrieving BaiduZhidao data.
	if (fetch_fotoes_statement == nil) {
		// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT foto FROM hotgirl_fotoes WHERE girlId = ? ORDER BY foto";
		if (sqlite3_prepare_v2(kSQLiteDB, sql, -1, &fetch_fotoes_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(kSQLiteDB));
		}
	}
	
	// For this query, we bind the primary key to the first (and only) placeholder in the statement.
	// Note that the parameters are numbered from 1, not from 0.
	sqlite3_bind_int(fetch_fotoes_statement, 1, girlId);
	
	while (sqlite3_step(fetch_fotoes_statement) == SQLITE_ROW)
	{
		NSString *foto = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_fotoes_statement, 0)];
		
		[fotoes addObject:foto];
	}
	
	// Reset the statement for future reuse.
	sqlite3_reset(fetch_fotoes_statement);
	
	return fotoes;
}

@end
