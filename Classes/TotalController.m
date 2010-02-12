//
//  TotalController.m
//  AppSalesMobile
//
//  Created by Kyosuke Takayama on 09/11/20.
//  Copyright 2009 Kyosuke Takayama. All rights reserved.
//

#import "TotalController.h"
#import "CurrencyManager.h"
#import "ReportManager.h"
#import "Day.h"

@implementation TotalController

- (id)init
{
	[super init];
	
	[self reload];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:ReportManagerDownloadedDailyReportsNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:ReportManagerDownloadedWeeklyReportsNotification object:nil];
	self.title = NSLocalizedString(@"Total",nil);
	
	return self;
}

- (void)reload
{
	self.daysByMonth = [NSMutableArray array];
	Day *total = [[Day alloc] initAsAllOfTime];
	if (total) {
		[daysByMonth addObject:[NSMutableArray arrayWithObject:total]];
		[total release];
	}
	
	[self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return NO;
}

@end
