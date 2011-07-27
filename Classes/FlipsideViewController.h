//
//  FlipsideViewController.h
//  MWFeedParser
//
//  Created by Vladimir Chernis on 7/7/11.
//  Copyright 2011 Michael Waterfall. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Feeds.h"

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    Feeds *feeds;
    UIPickerView *feedPickerView;    
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (readonly, nonatomic) IBOutlet UIPickerView *feedPickerView;

- (IBAction)done:(id)sender;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end