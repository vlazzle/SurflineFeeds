//
//  DetailTableViewController.m
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

#import "DetailTableViewController.h"
#import "NSString+HTML.h"
#import "RootViewController.h"

typedef enum { SectionHeader, SectionDetail, SectionTips } Sections;
typedef enum { SectionHeaderTitle, SectionHeaderDate, SectionHeaderURL } HeaderRows;
typedef enum { SectionDetailSummary } DetailRows;

#define SAVE_UNSAVE_DURATION 0.5

@implementation DetailTableViewController

@synthesize item=_item, dateString=_dateString, summaryString=_summaryString;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
	// Super
    [super viewDidLoad];

	// Date
	if (self.item.date) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterMediumStyle];
		self.dateString = [NSString stringWithFormat:@"last updated %@", [formatter stringFromDate:self.item.date]];
		[formatter release];
	}
	
	// Summary
	if (self.item.summary) {
		self.summaryString = [self.item.summary stringByConvertingHTMLToPlainText];
	} else {
		self.summaryString = @"[No Summary]";
	}
    
    // check if current spot is saved and set appropriate navbar button
    
    UIBarButtonItem *saveUnsaveButton;
    if ([self itemIsSaved]) {
        saveUnsaveButton = [[UIBarButtonItem alloc] initWithTitle:@"Unsave" style:UIBarButtonItemStylePlain target:self action:@selector(unsaveSpot:)];
    }
    else {
        saveUnsaveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveSpot:)];
    }
    self.navigationItem.rightBarButtonItem = saveUnsaveButton;
    [saveUnsaveButton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case SectionHeader: return 3;
		default: return 1;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Get cell
	static NSString *CellIdentifier = @"CellA";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	// Display
	cell.textLabel.textColor = [UIColor blackColor];
	cell.textLabel.font = [UIFont systemFontOfSize:15];
	if (self.item) {
		
		// Display
		switch (indexPath.section) {
			case SectionHeader: {
				
				// Header
				switch (indexPath.row) {
					case SectionHeaderTitle:
						cell.textLabel.font = [UIFont systemFontOfSize:15];
						cell.textLabel.text = [self titleForCurrentItem];;
                        cell.textLabel.numberOfLines = 0; // Multiline
						break;
					case SectionHeaderDate:
						cell.textLabel.text = self.dateString ? self.dateString : @"[No Date]";
						break;
					case SectionHeaderURL:
						cell.textLabel.text = self.item.link ? @"open full report in Safari" : @"[No Link]";
						cell.textLabel.textColor = [UIColor blueColor];
						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
						break;
				}
				break;
				
			}
			case SectionDetail: {
				
				// Summary
				cell.textLabel.text = self.summaryString;
				cell.textLabel.numberOfLines = 0; // Multiline
				break;
				
			}
            case SectionTips: {
                cell.textLabel.text = [self tipsForCurrentItem];
                cell.textLabel.numberOfLines = 0; // Multiline
                break;
            }
		}
	}
    
    return cell;
	
}

- (NSString *)titleForCurrentItem {
    NSString *itemTitle = self.item.title ? [self.item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
    return [itemTitle stringByReplacingOccurrencesOfString:@" : " withString:@"\n"];
}

- (NSString *)tipsForCurrentItem {
    if ([self itemIsSaved]) {
        return @"Tip: This spot is saved, so it'll appear near the top of the list. Unsave to restore normal order.";
    } else {
        return @"Tip: Tap the Save button to stash this spot near the top of the list.";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellTextContent;
    
	if (indexPath.section == SectionHeader) {
        if (indexPath.row == SectionHeaderTitle) {
            cellTextContent = [self titleForCurrentItem];
        }
        else {
            // Regular
            return 34;
        }
	}
    else {
		// Get height of summary or notes
        if (indexPath.section == SectionDetail) {
            if (self.summaryString) { 
                cellTextContent = self.summaryString;
            } else {
                 cellTextContent = @"[No Summary]";
            }
        }
        else if (indexPath.section == SectionTips) {
            cellTextContent = [self tipsForCurrentItem];
        }
        else {
            cellTextContent = @"";
        }
	}
    
    CGSize s = [cellTextContent sizeWithFont:[UIFont systemFontOfSize:15] 
                           constrainedToSize:CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT)  // - 40 For cell padding
                               lineBreakMode:UILineBreakModeWordWrap];
    
    return s.height + 16; // Add padding
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// Open URL
	if (indexPath.section == SectionHeader && indexPath.row == SectionHeaderURL) {
		if (self.item.link) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.item.link]];
		}
	}
	
	// Deselect
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[_dateString release];
	[_summaryString release];
	[_item release];
    [super dealloc];
}

# pragma mark -
# pragma mark Saving spots

- (void)saveSpot:(id)target {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedSpots = [defaults valueForKey:@"savedSpots"];
    
    NSLog(@"savedSpots before: %@", savedSpots);
    
    if (!savedSpots) {
        savedSpots = [NSArray arrayWithObject:self.item.link];
    }
    else if (![savedSpots containsObject:self.item.link]) {
        savedSpots = [savedSpots arrayByAddingObject:self.item.link];
    }
    
    [defaults setObject:savedSpots forKey:@"savedSpots"];
    if (![defaults synchronize]) {
        [NSException raise:@"Error" format:@"NSUserDefaults synchronize failed"];
    }
    
    NSLog(@"savedSpots after: %@", savedSpots);
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [UIView animateWithDuration:SAVE_UNSAVE_DURATION animations:^{
        self.navigationItem.rightBarButtonItem.title = @"Unsave";
    } completion:^(BOOL finished) {
        if (finished) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.action = @selector(unsaveSpot:);
        }
    }];

    [self saveUnsaveButtonWasClicked];
}

- (void)unsaveSpot:(id)target {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedSpots = [[defaults valueForKey:@"savedSpots"] mutableCopy];
    
    NSLog(@"savedSpots before: %@", savedSpots);
    
    [savedSpots removeObject:self.item.link];
    [defaults setObject:savedSpots  forKey:@"savedSpots"];
    if (![defaults synchronize]) {
        [NSException raise:@"Error" format:@"NSUserDefaults synchronize failed"];
    }
    
    NSLog(@"savedSpots after: %@", savedSpots);
    [savedSpots release];
    

    self.navigationItem.rightBarButtonItem.enabled = NO;    
    [UIView animateWithDuration:SAVE_UNSAVE_DURATION animations:^{
        self.navigationItem.rightBarButtonItem.title = @"Save";
    } completion:^(BOOL finished){
        if (finished) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.action = @selector(saveSpot:);
        }
    }];
    
    [self saveUnsaveButtonWasClicked];
}

- (void)saveUnsaveButtonWasClicked {
    RootViewController *rootVC = [self.navigationController.viewControllers objectAtIndex:0];
    [rootVC savedSpotsDidChange];
    
    [self.tableView reloadData];
}

- (BOOL)itemIsSaved {
    NSArray *savedSpots = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedSpots"];
    return [savedSpots containsObject:self.item.link];
}

@end

