//
//  Feeds.h
//
//  Created by Vladimir Chernis on 7/7/11.

#import <Foundation/Foundation.h>


@interface Feeds : NSObject {
    NSDictionary *feeds;
    NSDictionary *locations;
}

- (void)pickFeed:(NSUInteger)index;
- (NSUInteger)currentChoice;
- (BOOL)hasSavedChoice;
- (NSString *)feedNameForRow:(NSUInteger)index;
- (NSString *)feedUrlForRow:(NSUInteger)index;
- (CLLocation *)feedLocationForRow:(NSUInteger)index;
- (NSUInteger)rowForName:(NSString *)feedName;
- (NSUInteger)count;

// returns a shared singleton object.
// use this instead of alloc/init.
+ (Feeds *)sharedFeeds;

@end
