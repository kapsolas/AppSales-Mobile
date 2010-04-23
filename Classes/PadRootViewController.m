    //
//  PadRootViewController.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 05.04.10.
//  Copyright 2010 omz:software. All rights reserved.
//

#import "PadRootViewController.h"
#import "DashboardView.h"
#import "DashboardGraphView.h"
#import "SettingsViewController.h"
#import "ImportExportViewController.h"
#import "DaysController.h"
#import "WeeksController.h"
#import "ReportManager.h"
#import "ReviewsPane.h"
#import "App.h"
#import "HelpBrowser.h"

@implementation PadRootViewController

@synthesize toolbar, statusLabel, activityIndicator, settingsPopover, dailyDashboardView, weeklyDashboardView, reviewsPane, importExportPopover, graphTypeSheet, filterSheet, filterItem, aboutPopover;

- (void)loadView 
{
	[super loadView];
	CGRect bounds = self.view.bounds;
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
	
	UIBarButtonItem *refreshItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(downloadReports:)] autorelease];
	UIBarButtonItem *settingsItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TB_Settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)] autorelease];
	UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	UIBarButtonItem *aboutItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TB_About.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showAbout:)] autorelease];
	self.statusLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 32)] autorelease];
	statusLabel.textColor = [UIColor darkGrayColor];
	statusLabel.shadowColor = [UIColor whiteColor];
	
	statusLabel.shadowOffset = CGSizeMake(0, 1);
	statusLabel.font = [UIFont systemFontOfSize:12.0];
	statusLabel.numberOfLines = 2;
	statusLabel.lineBreakMode = UILineBreakModeWordWrap;
	statusLabel.backgroundColor = [UIColor clearColor];
	statusLabel.textAlignment = UITextAlignmentCenter;
	statusLabel.text = @"";
	UIBarButtonItem *statusItem = [[[UIBarButtonItem alloc] initWithCustomView:statusLabel] autorelease];
	
	self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	UIBarButtonItem *activityIndicatorItem = [[[UIBarButtonItem alloc] initWithCustomView:activityIndicator] autorelease];
	UIBarButtonItem *importExportItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TB_ImportExport.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showImportExport:)] autorelease];
	UIBarButtonItem *spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	spaceItem.width = 32.0;
	
	UIBarButtonItem *graphTypeItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TB_Graphs.png"] style:UIBarButtonItemStylePlain target:self action:@selector(selectGraphType:)] autorelease];
	self.filterItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TB_Filter.png"] style:UIBarButtonItemStylePlain target:self action:@selector(selectFilter:)] autorelease];
	self.toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 44)] autorelease];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	toolbar.items = [NSArray arrayWithObjects:refreshItem, flexItem, activityIndicatorItem, statusItem, flexItem, graphTypeItem, spaceItem, filterItem, spaceItem, spaceItem, spaceItem, importExportItem, spaceItem, settingsItem, spaceItem, aboutItem, nil];
	[self.view addSubview:toolbar];
	
	self.dailyDashboardView = [[[DashboardView alloc] initWithFrame:CGRectMake(0, 47, 748, 320)] autorelease];
	dailyDashboardView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[dailyDashboardView reloadData];
	//[dailyDashboardView resetDatePicker];
	
	DaysController *daysViewController = [[[DaysController alloc] init] autorelease];
	UINavigationController *daysNavigationController = [[[UINavigationController alloc] initWithRootViewController:daysViewController] autorelease];
	daysViewController.contentSizeForViewInPopover = CGSizeMake(320, 480);
	UIPopoverController *daysPopover = [[[NSClassFromString(@"UIPopoverController") alloc] initWithContentViewController:daysNavigationController] autorelease];
	dailyDashboardView.reportsPopover = daysPopover;
	dailyDashboardView.showsWeeklyReports = NO;
	[self.view addSubview:dailyDashboardView];
	
	self.weeklyDashboardView = [[[DashboardView alloc] initWithFrame:CGRectMake(0, 365, 748, 320)] autorelease];
	weeklyDashboardView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	weeklyDashboardView.showsWeeklyReports = YES;
	[weeklyDashboardView reloadData];
	//[weeklyDashboardView resetDatePicker];
	
	WeeksController *weeksViewController = [[[WeeksController alloc] init] autorelease];
	UINavigationController *weeksNavigationController = [[[UINavigationController alloc] initWithRootViewController:weeksViewController] autorelease];
	weeksViewController.contentSizeForViewInPopover = CGSizeMake(320, 480);
	UIPopoverController *weeksPopover = [[[NSClassFromString(@"UIPopoverController") alloc] initWithContentViewController:weeksNavigationController] autorelease];
	weeklyDashboardView.reportsPopover = weeksPopover;
	[self.view addSubview:weeklyDashboardView];
	
	SettingsViewController *settingsViewController = [[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil] autorelease];
	settingsViewController.contentSizeForViewInPopover = CGSizeMake(320, 440);
	self.settingsPopover = [[[NSClassFromString(@"UIPopoverController") alloc] initWithContentViewController:settingsViewController] autorelease];
	
	self.reviewsPane = [[[ReviewsPane alloc] initWithFrame:CGRectMake(0, 683, 768, 320)] autorelease];
	reviewsPane.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view insertSubview:reviewsPane belowSubview:weeklyDashboardView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress) name:ReportManagerUpdatedDownloadProgressNotification object:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		CGRect dailyFrame = dailyDashboardView.frame;
		dailyFrame.origin.y = 47;
		dailyDashboardView.frame = dailyFrame;
		CGRect weeklyFrame = dailyDashboardView.frame;
		weeklyFrame.origin.y = 365;
		weeklyDashboardView.frame = weeklyFrame;
		
		reviewsPane.frame = CGRectMake(0, 683, 768, 320);
		
	} else {
		CGRect dailyFrame = dailyDashboardView.frame;
		dailyFrame.origin.y = 47 + 19;
		dailyDashboardView.frame = dailyFrame;
		CGRect weeklyFrame = dailyDashboardView.frame;
		weeklyFrame.origin.y = 365 + 38;
		weeklyDashboardView.frame = weeklyFrame;
		
		reviewsPane.frame = CGRectMake(0, 683+320, 768, 320);
	}
}

- (void)selectGraphType:(id)sender
{
	if (!self.graphTypeSheet) {
		self.graphTypeSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Graph Type",nil) 
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
											 destructiveButtonTitle:nil 
												  otherButtonTitles:NSLocalizedString(@"Trend – Revenue",nil), NSLocalizedString(@"Trend – Sales",nil), NSLocalizedString(@"Regions – Revenue",nil), NSLocalizedString(@"Regions – Sales",nil), nil] autorelease];
		
	}
	if (graphTypeSheet.visible) {
		[graphTypeSheet dismissWithClickedButtonIndex:[graphTypeSheet cancelButtonIndex] animated:YES];
	} else {
		[graphTypeSheet showFromBarButtonItem:sender animated:YES];
	}
}

- (void)selectFilter:(id)sender
{
	if (filterSheet.visible) {
		[filterSheet dismissWithClickedButtonIndex:[graphTypeSheet cancelButtonIndex] animated:YES];
	} else {
		self.filterSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Filter",nil) 
														delegate:self 
											   cancelButtonTitle:nil 
										  destructiveButtonTitle:nil 
											   otherButtonTitles:NSLocalizedString(@"All Apps",nil), nil] autorelease];
		NSArray *allApps = [[ReportManager sharedManager].appsByID allValues];
		NSArray *sortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"appName" ascending:YES] autorelease]];
		NSArray *sortedApps = [allApps sortedArrayUsingDescriptors:sortDescriptors];
		for (App *app in sortedApps) {
			NSString *appName = app.appName;
			[filterSheet addButtonWithTitle:appName];
		}
		[filterSheet showFromBarButtonItem:sender animated:YES];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [actionSheet cancelButtonIndex]) return;
	
	if (actionSheet == self.graphTypeSheet) {
		if (buttonIndex == 0) {
			dailyDashboardView.graphView.showsUnits = NO;
			weeklyDashboardView.graphView.showsUnits = NO;
			dailyDashboardView.graphView.showsRegions = NO;
			weeklyDashboardView.graphView.showsRegions = NO;
			filterItem.enabled = YES;
		} else if (buttonIndex == 1) {
			dailyDashboardView.graphView.showsUnits = YES;
			weeklyDashboardView.graphView.showsUnits = YES;
			dailyDashboardView.graphView.showsRegions = NO;
			weeklyDashboardView.graphView.showsRegions = NO;
			filterItem.enabled = YES;
		} else if (buttonIndex == 2) {
			dailyDashboardView.graphView.showsUnits = NO;
			weeklyDashboardView.graphView.showsUnits = NO;
			dailyDashboardView.graphView.showsRegions = YES;
			weeklyDashboardView.graphView.showsRegions = YES;
			filterItem.enabled = NO;
		} else if (buttonIndex == 3) {
			dailyDashboardView.graphView.showsUnits = YES;
			weeklyDashboardView.graphView.showsUnits = YES;
			dailyDashboardView.graphView.showsRegions = YES;
			weeklyDashboardView.graphView.showsRegions = YES;
			filterItem.enabled = NO;
		}
		[dailyDashboardView.graphView setNeedsDisplay];
		[weeklyDashboardView.graphView setNeedsDisplay];
	} else if (actionSheet = self.filterSheet) {
		if (buttonIndex == 0) {
			dailyDashboardView.graphView.appFilter = nil;
			weeklyDashboardView.graphView.appFilter = nil;
		} else {
			NSString *appName = [actionSheet buttonTitleAtIndex:buttonIndex];
			dailyDashboardView.graphView.appFilter = appName;
			weeklyDashboardView.graphView.appFilter = appName;
		}
		[dailyDashboardView.graphView setNeedsDisplay];
		[weeklyDashboardView.graphView setNeedsDisplay];
	}
}

- (void)showSettings:(id)sender
{
	if (!settingsPopover.popoverVisible) {
		[settingsPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[settingsPopover dismissPopoverAnimated:YES];
	}
}

- (void)showAbout:(id)sender
{
	if (!aboutPopover) {
		UIViewController *aboutViewController = [[[HelpBrowser alloc] initWithNibName:nil bundle:nil] autorelease];
		aboutViewController.contentSizeForViewInPopover = CGSizeMake(320, 480);
		self.aboutPopover = [[[NSClassFromString(@"UIPopoverController") alloc] initWithContentViewController:aboutViewController] autorelease];
	}
	if (!aboutPopover.popoverVisible) {
		[aboutPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[aboutPopover dismissPopoverAnimated:YES];
	}
}

- (void)showImportExport:(id)sender
{
	if (importExportPopover.popoverVisible) {
		[importExportPopover dismissPopoverAnimated:YES];
	} else {
		ImportExportViewController *vc = [[[ImportExportViewController alloc] initWithNibName:nil bundle:nil] autorelease];
		vc.contentSizeForViewInPopover = CGSizeMake(320, 460);
		self.importExportPopover = [[[NSClassFromString(@"UIPopoverController") alloc] initWithContentViewController:vc] autorelease];
		[importExportPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (void)downloadReports:(id)sender
{
	[[ReportManager sharedManager] downloadReports];
}

- (void)updateProgress
{
	BOOL isDownloading = [[ReportManager sharedManager] isDownloadingReports];
	if (isDownloading) {
		[activityIndicator startAnimating];
	}
	else {
		[activityIndicator stopAnimating];
	}
	statusLabel.text = [ReportManager sharedManager].reportDownloadStatus;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return YES;
}


- (void)dealloc 
{
	[toolbar release];
	[statusLabel release];
	[activityIndicator release];
	[settingsPopover release];
	[importExportPopover release];
	[aboutPopover release];
	[graphTypeSheet release];
	[filterSheet release];
	[filterItem release];
	[dailyDashboardView release];
	[weeklyDashboardView release];
	[reviewsPane release];
    [super dealloc];
}


@end
