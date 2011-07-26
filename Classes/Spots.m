//
//  Spots.m
//  MWFeedParser
//
//  Created by Vladimir Chernis on 7/7/11.

#import "Spots.h"


@implementation Spots

- (Spots *)init {
    [super init];
    
    // TODO put this data in a config file or DB or something
    spots = [[NSDictionary alloc] initWithObjectsAndKeys:
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
    [spots enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [titles addObject:key];
    }];
    [titles sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    return self;
}

- (void)pickSpot:(NSUInteger)index {
    NSString *spotName = [self spotNameForRow:index];
    NSLog(@"picked %@", spotName);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:spotName forKey:@"spotChoice"];
    if (![defaults synchronize]) {
        [NSException raise:@"Error" format:@"NSUserDefaults synchronize failed"];
    }
}

- (NSUInteger)currentChoice {    
    NSString *spotName = [[NSUserDefaults standardUserDefaults] objectForKey:@"spotChoice"];
    if (spotName) {
        NSUInteger choiceNum = [titles indexOfObject:spotName];
        if (NSNotFound != choiceNum) {
            return choiceNum;
        }
    }
    
    return 0;
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
