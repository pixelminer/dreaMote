//
//  BouquetListController.m
//  dreaMote
//
//  Created by Moritz Venn on 02.01.09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BouquetListController.h"

#import "ServiceListController.h"

#import "RemoteConnectorObject.h"
#import "Objects/ServiceProtocol.h"

#import "ServiceTableViewCell.h"

@implementation BouquetListController

/* initialize */
- (id)init
{
	self = [super init];
	if (self) {
		self.title = NSLocalizedString(@"Bouquets", @"Title of BouquetListController");
		_bouquets = [[NSMutableArray array] retain];
		_refreshBouquets = YES;
		_serviceListController = nil;
	}
	return self;
}

/* dealloc */
- (void)dealloc
{
	[_bouquets release];
	[_serviceListController release];
	[_bouquetXMLDoc release];

	[super dealloc];
}

/* memory warning */
- (void)didReceiveMemoryWarning
{
	[_serviceListController release];
	_serviceListController = nil;

	[super didReceiveMemoryWarning];
}

/* layout */
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

/* about to display */
- (void)viewWillAppear:(BOOL)animated
{
	// Refresh cache if we have a cleared one
	if(_refreshBouquets)
	{
		[_bouquets removeAllObjects];

		[(UITableView *)self.view reloadData];
		[_bouquetXMLDoc release];
		_bouquetXMLDoc = nil;

		// Spawn a thread to fetch the service data so that the UI is not blocked while the
		// application parses the XML file.
		[NSThread detachNewThreadSelector:@selector(fetchBouquets) toTarget:self withObject:nil];
	}

	_refreshBouquets = YES;

	[super viewWillAppear: animated];
}

/* did hide */
- (void)viewDidDisappear:(BOOL)animated
{
	// Clean caches if supposed to
	if(_refreshBouquets)
	{
		[_bouquets removeAllObjects];

		[_serviceListController release];
		_serviceListController = nil;
		[_bouquetXMLDoc release];
		_bouquetXMLDoc = nil;
	}
}

/* fetch contents */
- (void)fetchBouquets
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[_bouquetXMLDoc release];
	_bouquetXMLDoc = [[[RemoteConnectorObject sharedRemoteConnector] fetchBouquets:self action:@selector(addService:)] retain];
	[pool release];
}

/* add service to list */
- (void)addService:(id)bouquet
{
	if(bouquet != nil)
	{
		[_bouquets addObject: bouquet];
#ifdef ENABLE_LAGGY_ANIMATIONS
		[(UITableView*)self.view insertRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow:[_bouquets count]-1 inSection:0]]
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

/* create cell for given row */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ServiceTableViewCell *cell = (ServiceTableViewCell*)[tableView dequeueReusableCellWithIdentifier: kServiceCell_ID];
	if(cell == nil)
		cell = [[[ServiceTableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: kServiceCell_ID] autorelease];

	cell.service = [_bouquets objectAtIndex:indexPath.row];

	return cell;
}

/* select row */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// See if we have a valid bouquet
	NSObject<ServiceProtocol> *bouquet = [_bouquets objectAtIndex: indexPath.row];
	if(!bouquet.valid)
		return nil;

	// Check for cached ServiceListController instance
	if(_serviceListController == nil)
		_serviceListController = [[ServiceListController alloc] init];

	// Redirect callback if we have one
	if(_selectTarget != nil && _selectCallback != nil)
		[_serviceListController setTarget: _selectTarget action: _selectCallback];
	_serviceListController.bouquet = bouquet;

	// We do not want to refresh bouquet list when we return
	_refreshBouquets = NO;

	[self.navigationController pushViewController: _serviceListController animated:YES];

	// Do not actually select row
	return nil;
}

/* number of sections */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

/* number of rows */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [_bouquets count];
}

/* set callback */
- (void)setTarget: (id)target action: (SEL)action
{
	/*!
	 @note We do not retain the target, this theoretically could be a problem but
	 is not in this case.
	 */
	_selectTarget = target;
	_selectCallback = action;
}

/* support rotation */
- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
