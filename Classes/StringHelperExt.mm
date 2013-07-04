//
//  StringHelper.h
//  IHomeWiki
//
//  Created by 李云天 on 10-8-24.
//  Copyright 2010 iHomeWiki. All rights reserved.
//
#import <Foundation/Foundation.h>

class StringHelperExt { 
	public: 
		StringHelperExt()
		{
		} 

		static NSInteger alphabeticSort(id string1, id string2, void *reverse)
		{
			if ((*(int *) reverse)) {
				return [string2 localizedCaseInsensitiveCompare:string1];
			}
			else {
				return [string1 localizedCaseInsensitiveCompare:string2];
			}
		}

	
	static NSInteger intSort(id string1, id string2, void *reverse)
	{
		int v1 = (int) string1;
		int v2 = (int) string2;
		
		if ((*(int *) reverse))
		{
			return v1 < v2;
		}
		else
		{
			return v2 < v1;
		}
	}
};