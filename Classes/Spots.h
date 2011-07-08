//
//  Spots.h
//  MWFeedParser
//
//  Created by Vladimir Chernis on 7/7/11.
//  Copyright 2011 Michael Waterfall. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Spots : NSObject {
    NSDictionary *spots;
    NSArray *titles;
}

- (void)pickSpot:(NSUInteger)index;
- (NSString *)spotNameForRow:(NSUInteger)index;
- (NSString *)spotUrlForRow:(NSUInteger)index;
- (NSUInteger)count;


@end
