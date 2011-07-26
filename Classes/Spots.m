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
    // TODO it would be nice if adding a spot didn't require a migration of NSUserDefaults data (due to alphabetical sorting of keys)
    spots = [[NSDictionary alloc] initWithObjectsAndKeys:
             @"http://feeds.feedburner.com/surfline-rss-surf-report-santa-cruz", @"Santa Cruz",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-san-francisco-san-mateo-county", @"SF-San Mateo County",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-monterey-california", @"Monterey",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-san-luis-obispo-county", @"San Luis Obispo County",
             nil];
    
    titles = [[spots keysSortedByValueUsingSelector:@selector(compare:)] retain];
    
    return self;
}

- (void)pickSpot:(NSUInteger)index {
    NSLog(@"picked %@", [self spotNameForRow:index]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:index] forKey:@"spotChoice"];
    if (![defaults synchronize]) {
        [NSException raise:@"Error" format:@"NSUserDefaults synchronize failed"];
    }
}

- (NSUInteger)currentChoice {
    // returns nil = 0 = first choice if the UserDefault has not been set yet
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"spotChoice"] intValue];
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
