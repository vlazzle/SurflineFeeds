//
//  Feeds.h
//
//  Created by Vladimir Chernis on 7/7/11.

#import <Foundation/Foundation.h>


@interface Feeds : NSObject {
    NSDictionary *feeds;
    NSMutableArray *titles;
}

- (void)pickFeed:(NSUInteger)index;
- (NSUInteger)currentChoice;
- (NSString *)feedNameForRow:(NSUInteger)index;
- (NSString *)feedUrlForRow:(NSUInteger)index;
- (NSUInteger)count;


@end
