//
//  RootViewController.m
//  MWFeedParser
//
//  Copyright (c) 2010 Michael Waterfall
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  1. The above copyright notice and this permission notice shall be included
//     in all copies or substantial portions of the Software.
//  
//  2. This Software cannot be used to archive or collect data such as (but not
//     limited to) that of events, news, experiences and activities, for the 
//     purpose of any concept relating to diary/journal keeping.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RootViewController.h"
#import "NSString+HTML.h"
#import "MWFeedParser.h"
#import "DetailTableViewController.h"

@implementation RootViewController

@synthesize itemsToDisplay;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
		
	// Super
	[super viewDidLoad];
	
	// Setup
	self.title = @"Loading...";
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	parsedItems = [[NSMutableArray alloc] init];
	self.itemsToDisplay = [NSArray array];
	
	// Refresh button
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																							target:self 
																							action:@selector(refresh)] autorelease];
    
    // Edit settings button
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                           target:self
                                                                                           action:@selector(showInfo:)] autorelease];
    
    spots = [[Spots alloc] init];   // TODO dependency injection?
    
    // Parse
    [self initParser];
    [feedParser parse];
}

- (void)initParser {
    // Get user's spot choice
    // returns nil = 0 = first choice if the UserDefault has not been set yet
    NSInteger spotChoiceNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"spotChoice"] intValue];
    NSString *spotChoice = [spots spotUrlForRow:spotChoiceNum];
    
    NSURL *feedUrl = [NSURL URLWithString:spotChoice];
	feedParser = [[MWFeedParser alloc] initWithFeedURL:feedUrl];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	feedParser.connectionType = ConnectionTypeAsynchronously;
}

#pragma mark -
#pragma mark Parsing

// Reset and reparse
- (void)refresh {
	self.title = @"Refreshing...";
	[parsedItems removeAllObjects];
	[feedParser stopParsing];
    
    // PERF OPT no need to re-init if spot choice didn't change and no spots were saved or unsaved
    [feedParser release];
    [self initParser];
    
	[feedParser parse];
	self.tableView.userInteractionEnabled = NO;
	self.tableView.alpha = 0.3;
}

- (void)savedSpotsDidChange {
	self.tableView.userInteractionEnabled = NO;
	self.tableView.alpha = 0.3;

    [self feedParserDidFinish:feedParser];
}

#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
	NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
	NSLog(@"Parsed Feed Info: “%@”", info.title);
    
    NSString *trimmedTitle = [info.title stringByReplacingOccurrencesOfString:@"Surfline RSS Break Report for "
                                                                   withString:@""];
	self.title = trimmedTitle;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	NSLog(@"Parsed Feed Item: “%@”", item.title);
	if (item) [parsedItems addObject:item];	
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    
    NSArray *savedSpots = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedSpots"];
    NSPredicate *isSaved = [NSPredicate predicateWithFormat:@"link IN %@", savedSpots];
    NSMutableArray *savedItems = [[NSMutableArray alloc] init];
    NSMutableArray *unsavedItems = [[NSMutableArray alloc] init];
    
    // partition into saved and unsaved items
    NSEnumerator *it = [parsedItems objectEnumerator];
    id currentItem;
    while ((currentItem = [it nextObject])) {
        if ([isSaved evaluateWithObject:currentItem]) {
            [savedItems addObject:currentItem];
        }
        else {
            [unsavedItems addObject:currentItem];
        }
    }
    
    NSArray *sortedSavedItems = [savedItems sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                                      ascending:NO] autorelease]]];
    NSArray *sortedUnsavedItems = [unsavedItems sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                                      ascending:NO] autorelease]]];
    
    self.itemsToDisplay = [sortedSavedItems arrayByAddingObjectsFromArray:sortedUnsavedItems];
    
    [savedItems autorelease];
    [unsavedItems autorelease];
    
    self.tableView.userInteractionEnabled = YES;
	self.tableView.alpha = 1;
	[self.tableView reloadData];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
	self.title = @"Failed";
	self.itemsToDisplay = [NSArray array];
	[parsedItems removeAllObjects];
	self.tableView.userInteractionEnabled = YES;
	self.tableView.alpha = 1;
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return itemsToDisplay.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell.
	MWFeedItem *item = [itemsToDisplay objectAtIndex:indexPath.row];
	if (item) {
		
		// Process
		NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
		NSString *itemSummary = item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
		
		// Set
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
		cell.textLabel.text = itemTitle;
		NSMutableString *subtitle = [NSMutableString string];
		if (item.date) [subtitle appendFormat:@"%@: ", [formatter stringFromDate:item.date]];
		[subtitle appendString:itemSummary];
		cell.detailTextLabel.text = subtitle;
		
	}
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// Show detail
	DetailTableViewController *detail = [[DetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	detail.item = (MWFeedItem *)[itemsToDisplay objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:detail animated:YES];
	[detail release];
	
	// Deselect
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[formatter release];
	[parsedItems release];
	[itemsToDisplay release];
	[feedParser release];
    [spots release];
    [super dealloc];
}

#pragma mark -
#pragma mark FlipsideViewControllerDelegate

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
    [self refresh];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
