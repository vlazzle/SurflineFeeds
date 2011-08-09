//
//  Feeds.m
//
//  Created by Vladimir Chernis on 7/7/11.

#import <CoreLocation/CoreLocation.h>
#import "Feeds.h"

@interface Feeds ()
@property (readwrite, nonatomic, retain) NSArray *feedNames;
@end

@implementation Feeds

@synthesize feedNames=_feedNames;

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
    
    self.feedNames = [[feeds allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    locations = [[NSDictionary alloc] initWithObjectsAndKeys:
                 [[[CLLocation alloc] initWithLatitude:36.974117100000001 longitude:-122.03079630000001] autorelease],
                    @"CA: Santa Cruz",
                 
                 // TODO update with correct coordinates
                 [[[CLLocation alloc] initWithLatitude:37.322997800000003 longitude:-122.0321823] autorelease],
                    @"CA: SF-San Mateo County",
                 [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease],
                    @"CA: Monterey",
                 [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease],
                    @"CA: San Luis Obispo County",
                 [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease],
                    @"HI: Oʻahu: North Shore",
                 [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease],
                    @"HI: Oʻahu: West Side",
                 [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease],
                    @"HI: Oʻahu: South Shore",
                 [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease],
                    @"HI: Oʻahu: Windward Side",
                 [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease],
                    @"Tonga",
                 nil];
    
    
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
        NSUInteger choiceNum = [self.feedNames indexOfObject:feedName];
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
    return [self.feedNames objectAtIndex:index];
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
    [_feedNames release];
    [super dealloc];
}

- (CLLocation *)feedLocationForRow:(NSUInteger)index;
{
    NSString *key = [self.feedNames objectAtIndex:index];
    return [locations objectForKey:key];
}

@end
