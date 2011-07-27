//
//  Feeds.m
//
//  Created by Vladimir Chernis on 7/7/11.

#import "Feeds.h"


@implementation Feeds

- (Feeds *)init {
    [super init];
    
    // TODO put this data in a config file or DB or something
    feeds = [[NSDictionary alloc] initWithObjectsAndKeys:
             @"http://feeds.feedburner.com/surfline-rss-surf-report-santa-cruz", @"CA: Santa Cruz",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-san-francisco-san-mateo-county", @"CA: SF-San Mateo County",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-monterey-california", @"CA: Monterey",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-san-luis-obispo-county", @"CA: San Luis Obispo County",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-oahu-north-shore", @"HI: Oʻahu: North Shore",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-oahu-west-side", @"HI: Oʻahu: West Side",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-oahu-south-shore", @"HI: Oʻahu: South Shore",
             @"http://feeds.feedburner.com/surfline-rss-surf-report-oahu-windward-side", @"HI: Oʻahu: Windward Side",
             nil];
    
    titles = [[NSMutableArray alloc] init];
    [feeds enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [titles addObject:key];
    }];
    [titles sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    return self;
}

- (void)pickFeed:(NSUInteger)index {
    NSString *feedName = [self feedNameForRow:index];
    NSLog(@"picked %@", feedName);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:feedName forKey:@"feedChoice"];
    if (![defaults synchronize]) {
        [NSException raise:@"Error" format:@"NSUserDefaults synchronize failed"];
    }
}

- (NSUInteger)currentChoice {    
    NSString *feedName = [[NSUserDefaults standardUserDefaults] objectForKey:@"feedChoice"];
    if (feedName) {
        NSUInteger choiceNum = [titles indexOfObject:feedName];
        if (NSNotFound != choiceNum) {
            return choiceNum;
        }
    }
    
    return 0;
}

- (NSString *)feedNameForRow:(NSUInteger)index {
    return [titles objectAtIndex:index];
}

- (NSString *)feedUrlForRow:(NSUInteger)index {
    NSString *title = [titles objectAtIndex:index];
    return [feeds objectForKey:title];
}

- (NSUInteger)count {
    return [feeds count];
}

- (void)dealloc {
    [feeds release];
    [titles release];
    [super dealloc];
}

@end
