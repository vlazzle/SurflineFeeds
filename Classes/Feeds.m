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

- (void)dealloc
{
    [feeds release];
    [_feedNames release];
    [super dealloc];
}

- (Feeds *)init
{
    self = [super init];
    if (self) {
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
        
        CLLocation *santaCruz = [[[CLLocation alloc] initWithLatitude:36.97411710 longitude:-122.03079630] autorelease];
        CLLocation *sf = [[[CLLocation alloc] initWithLatitude:37.75937490 longitude:-122.51080570] autorelease];
        CLLocation *monterey = [[[CLLocation alloc] initWithLatitude:36.60023780 longitude:-121.89467610] autorelease];
        CLLocation *sanLuisObispo = [[[CLLocation alloc] initWithLatitude:35.16694110 longitude:-120.71775090] autorelease];
        CLLocation *northShore = [[[CLLocation alloc] initWithLatitude:21.56165750 longitude:-158.07159830] autorelease];
        CLLocation *westSideOahu = [[[CLLocation alloc] initWithLatitude:21.4682740 longitude:-158.2150620] autorelease];
        CLLocation *southShore = [[[CLLocation alloc] initWithLatitude:21.2833380 longitude:-157.8427490] autorelease];
        CLLocation *windwardSideOahu = [[[CLLocation alloc] initWithLatitude:21.39737750 longitude:-157.72866560] autorelease];
        CLLocation *tonga = [[[CLLocation alloc] initWithLatitude:-21.06666670 longitude:-175.33333330] autorelease];
        
        locations = [[NSDictionary alloc] initWithObjectsAndKeys:
                     santaCruz, @"CA: Santa Cruz",
                     sf, @"CA: SF-San Mateo County",
                     monterey, @"CA: Monterey",
                     sanLuisObispo, @"CA: San Luis Obispo County",
                     northShore, @"HI: Oʻahu: North Shore",
                     westSideOahu, @"HI: Oʻahu: West Side",
                     southShore, @"HI: Oʻahu: South Shore",
                     windwardSideOahu, @"HI: Oʻahu: Windward Side",
                     tonga, @"Tonga",
                     nil];
    }
    
    return self;
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

- (CLLocation *)feedLocationForRow:(NSUInteger)index;
{
    NSString *key = [self.feedNames objectAtIndex:index];
    return [locations objectForKey:key];
}

- (NSUInteger)rowForName:(NSString *)feedName
{
    return [self.feedNames indexOfObject:feedName];
}

- (NSUInteger)count
{
    return [feeds count];
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

@end
