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
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (readonly, nonatomic) IBOutlet UIPickerView *feedPickerView;
@property (readonly, nonatomic, retain) IBOutlet UIButton *overlayButton;

- (IBAction)done:(id)sender;
- (void)fadeInOverlay;
- (void)fadeOutOverlay;
- (void)fadeOutOverlayWithCompletion:(void (^)(BOOL finished))completion;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end