//
//  SignalViewController.m
//  dreaMote
//
//  Created by Moritz Venn on 15.06.09.
//  Copyright 2009-2011 Moritz Venn. All rights reserved.
//

#import "SignalViewController.h"

#import "RemoteConnectorObject.h"
#import "Constants.h"
#import "UITableViewCell+EasyInit.h"

#import "Signal.h"

#import "DisplayCell.h"

@interface SignalViewController()
/*!
 @brief spawn a new thread to fetch signal data
 This selector is called on a regular basis through the timer that is active
 when the view is in forgeground.
 It simply spawns a new thread to fetch the signal data in background rather
 than in foreground.
 */
- (void)fetchSignalDefer;

/*!
 @brief entry point of thread which fetches signal data
 */
- (void)fetchSignal;

/*!
 @brief Start new refresh timer.
 */
- (void)startTimer;

/*!
 @brief Refresh interval was changed.
 @param sender ui element
 */
- (void)intervalChanged:(id)sender;

/*!
 @brief Refresh interval accepted.
 @param sender ui element
 */
- (void)intervalSet:(id)sender;
@end

@implementation SignalViewController

- (id)init
{
	if((self = [super init]))
	{
		self.title = NSLocalizedString(@"Signal", @"Title of SignalViewController");
	}
	return self;
}

- (void)dealloc
{
	[_snr release];
	[_agc release];
	[_snrdBCell release];
	[_berCell release];

	[_timer invalidate];
	_timer = nil;

	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	_refreshInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kSatFinderInterval];
	[self startTimer];

	[super viewWillAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_timer invalidate];
	_timer = nil;

	[super viewWillDisappear: animated];
}

- (void)fetchSignalDefer
{
	// Spawn a thread to fetch the signal data so that the UI is not blocked while the 
	// application parses the XML file.
	[NSThread detachNewThreadSelector:@selector(fetchSignal) toTarget:self withObject:nil];
}

- (void)fetchSignal
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[[RemoteConnectorObject sharedRemoteConnector] getSignal: self];

	[pool release];
}

- (void)loadView
{
	// create and configure the table view
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];	
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.rowHeight = kUIRowHeight;

	// setup our content view so that it auto-rotates along with the UViewController
	tableView.autoresizesSubviews = YES;
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	self.view = tableView;
	[tableView release];

	// SNR
	_snr = [[UISlider alloc] initWithFrame: CGRectMake(0, 0, 240, kSliderHeight)];

	// in case the parent view draws with a custom color or gradient, use a transparent color
	_snr.backgroundColor = [UIColor clearColor];
	_snr.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	_snr.minimumValue = 0;
	_snr.maximumValue = 100;
	_snr.continuous = NO;
	_snr.enabled = NO;

	// AGC
	_agc = [[UISlider alloc] initWithFrame: CGRectMake(0, 0, 240, kSliderHeight)];

	// in case the parent view draws with a custom color or gradient, use a transparent color
	_agc.backgroundColor = [UIColor clearColor];
	_agc.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	_agc.minimumValue = 0;
	_agc.maximumValue = 100;
	_agc.continuous = NO;
	_agc.enabled = NO;

	// Interval Slider
	_interval = [[UISlider alloc] initWithFrame: CGRectMake(0, 0, (IS_IPAD()) ? 300 : 200, kSliderHeight)];
	_interval.backgroundColor = [UIColor clearColor];
	_interval.autoresizingMask = UIViewAutoresizingNone;
	_interval.minimumValue = 0;
	_interval.maximumValue = 32; // we never reach the maximum, so we use 32 instead of 31 as max value
	_interval.continuous = YES;
	_interval.enabled = YES;
	_interval.value = [[NSUserDefaults standardUserDefaults] floatForKey:kSatFinderInterval];
	[_interval addTarget:self action:@selector(intervalChanged:) forControlEvents:UIControlEventValueChanged];
	[_interval addTarget:self action:@selector(intervalSet:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

	// SNRdB
	UITableViewCell *sourceCell = [UITableViewCell reusableTableViewCellInView:tableView withIdentifier:kVanilla_ID];

	TABLEVIEWCELL_ALIGN(sourceCell) = UITextAlignmentCenter;
	TABLEVIEWCELL_COLOR(sourceCell) = [UIColor blackColor];
	TABLEVIEWCELL_FONT(sourceCell) = [UIFont systemFontOfSize:kTextViewFontSize];
	sourceCell.selectionStyle = UITableViewCellSelectionStyleNone;
	sourceCell.indentationLevel = 1;
	_snrdBCell = [sourceCell retain];

	// BER
	sourceCell = [UITableViewCell reusableTableViewCellInView:tableView withIdentifier:kVanilla_ID];

	TABLEVIEWCELL_ALIGN(sourceCell) = UITextAlignmentCenter;
	TABLEVIEWCELL_COLOR(sourceCell) = [UIColor blackColor];
	TABLEVIEWCELL_FONT(sourceCell) = [UIFont systemFontOfSize:kTextViewFontSize];
	sourceCell.selectionStyle = UITableViewCellSelectionStyleNone;
	sourceCell.indentationLevel = 1;
	_berCell = [sourceCell retain];
}

/* rotate with device */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (NSString *)getIntervalTitle:(double)interval
{
	if(interval <= 0)
	{
		return NSLocalizedString(@"instant", @"instant sat finder refresh");
	}
	else if(interval >= 31)
	{
		return NSLocalizedString(@"never", @"don't refresh sat finder");
	}
	return [NSString stringWithFormat:NSLocalizedString(@"%.0f sec", @"sat finder refresh interval"), interval];
}

- (void)startTimer
{
	[_timer invalidate];
	_timer = nil;
	if(_refreshInterval <= 0) // handle instant refresh differently
	{
		[self fetchSignalDefer];
	}
	else if(_refreshInterval < 31) // 31 == "never"
	{
		_timer = [NSTimer scheduledTimerWithTimeInterval:_refreshInterval
												  target:self selector:@selector(fetchSignalDefer)
												userInfo:nil   repeats:YES];
		[_timer fire];
	}
}

- (void)intervalSet:(id)sender
{
	_refreshInterval = (double)(int)_interval.value;
	[[NSUserDefaults standardUserDefaults] setDouble:_refreshInterval forKey:kSatFinderInterval];
	[(UITableView *)self.view reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];

	// start new timer
	[self startTimer];
}

- (void)intervalChanged:(id)sender
{
	UITableViewCell *cell = [(UITableView *)self.view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
	cell.textLabel.text = [self getIntervalTitle:(double)(int)_interval.value];
}

#pragma mark - UITableView delegates

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch(section)
	{
		case 0:	
			return NSLocalizedString(@"Percentage", @"Title of percentage section of SatFinder");
		case 1:
			return NSLocalizedString(@"Exact", @"Title of exact section of SatFinder");
		case 2:
			return NSLocalizedString(@"Interval", @"Title of refresh Interval section of SatFinder");
		default:
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch(section)
	{
		case 0:
			return 2;
		case 1:
			return (_hasSnrdB) ? 2 : 1;
		case 2:
			return 1;
		default:
			return 0;
	}
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *sourceCell = nil;

	// we are creating a new cell, setup its attributes
	switch (indexPath.section) {
		case 0:
			sourceCell = [DisplayCell reusableTableViewCellInView:tableView withIdentifier:kDisplayCell_ID];

			sourceCell.selectionStyle = UITableViewCellSelectionStyleNone;
			if(indexPath.row == 0)
			{
				((DisplayCell *)sourceCell).nameLabel.text = NSLocalizedString(@"SNR", @"");
				((DisplayCell *)sourceCell).view = _snr;
			}
			else
			{
				((DisplayCell *)sourceCell).nameLabel.text = NSLocalizedString(@"AGC", @"");
				((DisplayCell *)sourceCell).view = _agc;
			}
			break;
		case 1:
			if(_hasSnrdB && indexPath.row == 0)
				sourceCell = _snrdBCell;
			else
				sourceCell = _berCell;
			break;
		case 2:
			sourceCell = [DisplayCell reusableTableViewCellInView:tableView withIdentifier:kDisplayCell_ID];

			sourceCell.selectionStyle = UITableViewCellSelectionStyleNone;
			((DisplayCell *)sourceCell).nameLabel.text = [self getIntervalTitle:[[NSUserDefaults standardUserDefaults] doubleForKey:kSatFinderInterval]];
			((DisplayCell *)sourceCell).view = _interval;
			break;
		default:
			break;
	}
	
	return sourceCell;
}

#pragma mark -
#pragma mark DataSourceDelegate
#pragma mark -

- (void)dataSourceDelegate:(BaseXMLReader *)dataSource errorParsingDocument:(CXMLDocument *)document error:(NSError *)error
{
	// Alert user
	const UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to retrieve data", @"")
														  message:[error localizedDescription]
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
	[alert show];
	[alert release];

	// stop timer
	[_timer invalidate];
	_timer = nil;
}

- (void)dataSourceDelegate:(BaseXMLReader *)dataSource finishedParsingDocument:(CXMLDocument *)document
{
	[(UITableView *)self.view reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

	if(_refreshInterval <= 0)
		[self fetchSignalDefer];
}

#pragma mark -
#pragma mark SignalSourceDelegate
#pragma mark -

- (void)addSignal: (GenericSignal *)signal
{
	if(signal == nil)
		return;
	
	_snr.value = (float)(signal.snr);
	_agc.value = (float)(signal.agc);

	const BOOL oldSnrdB =_hasSnrdB;
	_hasSnrdB = signal.snrdb > -1;
	TABLEVIEWCELL_TEXT(_snrdBCell) = [NSString stringWithFormat: @"SNR %.2f dB", signal.snrdb];
	TABLEVIEWCELL_TEXT(_berCell) = [NSString stringWithFormat: @"%i BER", signal.ber];

	// there is a weird glitch that prevents the second row from being shown unless we do a full reload, so do it here
	// while we still know that we need to do one.
	if(oldSnrdB != _hasSnrdB)
		[(UITableView *)self.view reloadData];
}

@end