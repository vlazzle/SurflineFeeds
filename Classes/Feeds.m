//
//  Feeds.m
//
//  Created by Vladimir Chernis on 7/7/11.

#import "Feeds.h"


@implementation Feeds

- (Feeds *)init
{
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
             @"http://feeds.feedburner.com/surfline-rss-surf-report-tonga", @"Tonga",
             nil];
    
    feedNames = [[[feeds allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] retain];
    
    return self;
}

+ (Feeds *)sharedFeeds
{
    static dispatch_once_t onceToken;
    static Feeds *singletonObj;
    dispatch_once(&onceToken, ^{
        singletonObj = [[Feeds alloc] init];
    });
    NSLog(@"returning singleton Feeds object @ %p", singletonObj);
    return singletonObj;
}

- (void)pickFeed:(NSUInteger)index
{
    NSString *feedName = [self feedNameForRow:index];
    NSLog(@"picked %@", feedName);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:feedName forKey:@"feedChoice"];
    if (![defaults synchronize]) {
        [NSException raise:@"Error" format:@"NSUserDefaults synchronize failed"];
    }
}

- (NSUInteger)currentChoice
{    
    NSString *feedName = [[NSUserDefaults standardUserDefaults] objectForKey:@"feedChoice"];
    if (feedName) {
        NSUInteger choiceNum = [feedNames indexOfObject:feedName];
        if (NSNotFound != choiceNum) {
            return choiceNum;
        }
    }
    
    // default to the first option if no valid choice is saved
    return 0;
}

- (BOOL)hasSavedChoice {
    return nil != [[NSUserDefaults standardUserDefaults] objectForKey:@"feedChoice"];
}

- (NSString *)feedNameForRow:(NSUInteger)index
{
    return [feedNames objectAtIndex:index];
}

- (NSString *)feedUrlForRow:(NSUInteger)index
{
    NSString *feedName = [self feedNameForRow:index];
    return [feeds objectForKey:feedName];
}

- (NSUInteger)count
{
    return [feeds count];
}

- (void)dealloc
{
    [feeds release];
    [feedNames release];
    [super dealloc];
}

@end
