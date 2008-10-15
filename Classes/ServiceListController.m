//
//  ServiceListController.m
//  Untitled
//
//  Created by Moritz Venn on 08.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ServiceListController.h"

#import "EventListController.h"

#import "ServiceTableViewCell.h"
#import "RemoteConnectorObject.h"
#import "Service.h"

@implementation ServiceListController

- (id)init
{
	self = [super init];
	if (self) {
		self.title = NSLocalizedString(@"Services", @"Title of ServiceListController");
		_services = [[NSMutableArray array] retain];
		_refreshServices = YES;
	}
	return self;
}

- (void)dealloc
{
	[_services makeObjectsPerformSelector:@selector(release)];
	[_services release];
	[_selectTarget release];
	
	[super dealloc];
}

- (void)loadView
{
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.rowHeight = 38.0;
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.sectionHeaderHeight = 0;

	// setup our content view so that it auto-rotates along with the UViewController
	tableView.autoresizesSubviews = YES;
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	self.view = tableView;
	[tableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
	if(_refreshServices)
	{
		[_services makeObjectsPerformSelector:@selector(release)];
		[_services removeAllObjects];

		[(UITableView *)self.view reloadData];

		// Spawn a thread to fetch the service data so that the UI is not blocked while the
		// application parses the XML file.
		[NSThread detachNewThreadSelector:@selector(fetchServices) toTarget:self withObject:nil];
	}

	_refreshServices = YES;

	[super viewWillAppear: animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if(_refreshServices)
	{
		[_services makeObjectsPerformSelector:@selector(release)];
		[_services removeAllObjects];
	}
}

- (void)fetchServices
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[RemoteConnectorObject sharedRemoteConnector] fetchServices:self action:@selector(addService:)];
	[pool release];
}

- (void)addService:(id)service
{
	if(service != nil)
	{
		[_services addObject: (Service*)service];
#ifdef ENABLE_LAGGY_ANIMATIONS
		[(UITableView*)self.view insertRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow:[_services count]-1 inSection:0]]
						withRowAnimation: UITableViewRowAnimationTop];
	}
	else
#else
	}
#endif
		[(UITableView *)self.view reloadData];
}

#pragma mark	-
#pragma mark		Table View
#pragma mark	-

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kServiceCell_ID = @"ServiceCell_ID";

	ServiceTableViewCell *cell = (ServiceTableViewCell*)[tableView dequeueReusableCellWithIdentifier: kServiceCell_ID];
	if(cell == nil)
		cell = [[[ServiceTableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: kServiceCell_ID] autorelease];

	cell.service = [_services objectAtIndex:indexPath.row];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_selectTarget != nil && _selectCallback != nil)
	{
		Service *service = [_services objectAtIndex: indexPath.row];
		[_selectTarget performSelector:(SEL)_selectCallback withObject: service];

		[self.navigationController popViewControllerAnimated: YES];
	}
	else
	{
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"What to do with the currently selected Service?", @"UIActionSheet when List Item in ServiceListController selected")
																delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Zap", @""), NSLocalizedString(@"Show EPG", @""), nil];
		[actionSheet showInView: tableView];
		[actionSheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex: (NSInteger)buttonIndex
{
	Service *service = [(ServiceTableViewCell *)[(UITableView*)self.view cellForRowAtIndexPath: [(UITableView*)self.view indexPathForSelectedRow]] service];

	if (buttonIndex == 0)
	{
		// Second Button: zap
		[[RemoteConnectorObject sharedRemoteConnector] zapTo: service];
	}
	else if (buttonIndex == 1)
	{
		// Third Button: epg
		EventListController *targetViewController = [EventListController forService: service];

		[self.navigationController pushViewController: targetViewController animated:YES];
		[targetViewController release];

		_refreshServices = NO;
	}

	NSIndexPath *tableSelection = [(UITableView*)self.view indexPathForSelectedRow];
	[(UITableView*)self.view deselectRowAtIndexPath:tableSelection animated: NO]; // XXX: looks buggy if animated...
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	// TODO: handle seperators?
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [_services count];
}

- (void)setTarget: (id)target action: (SEL)action
{
	_selectTarget = target;
	_selectCallback = action;
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
