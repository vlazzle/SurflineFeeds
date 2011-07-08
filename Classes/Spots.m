//
//  Spots.m
//  MWFeedParser
//
//  Created by Vladimir Chernis on 7/7/11.
//  Copyright 2011 Michael Waterfall. All rights reserved.
//

#import "Spots.h"


@implementation Spots

- (Spots *)init {
    [super init];
    
    // TODO put this data in a config file or DB or something
    spots = [[NSDictionary alloc] initWithObjectsAndKeys:
             @"http://feeds.feedburner.com/surfline-rss-surf-report-santa-cruz", @"Santa Cruz",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-san-francisco-san-mateo-county", @"San Francisco",
             nil];
    
    titles = [[spots keysSortedByValueUsingSelector:@selector(compare:)] retain];
    
    return self;
}

- (void)pickSpot:(NSUInteger)index {
    NSLog(@"picked %@", [self spotNameForRow:index]);
}

- (NSString *)spotNameForRow:(NSUInteger)index {
    return [titles objectAtIndex:index];
}

- (NSString *)spotUrlForRow:(NSUInteger)index {
    NSString *title = [titles objectAtIndex:index];
    return [spots objectForKey:title];
}

- (NSUInteger)count {
    return [spots count];
}

- (void)dealloc {
    [spots release];
    [titles release];
    [super dealloc];
}

@end
