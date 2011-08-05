//
//  FlipsideViewController.h
//  MWFeedParser
//
//  Created by Vladimir Chernis on 7/7/11.
//  Copyright 2011 Michael Waterfall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Feeds.h"

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate> {
    Feeds *feeds;
    NSUInteger originalFeedChoice;
}

@property (nonatomic, assign) id<FlipsideViewControllerDelegate> delegate;
@property (readonly, nonatomic) IBOutlet UIPickerView *feedPickerView;
@property (readonly, nonatomic) IBOutlet UIButton *overlayButton;
@property (readonly, nonatomic) IBOutlet UISwitch *locationSwitch;
@property (readonly, nonatomic) IBOutlet UIView *locationView;
@property (readonly, nonatomic) CLLocationManager *locationManager;
@property (readonly, nonatomic) BOOL showLocationSwitch;

- (IBAction)done:(id)sender;
- (void)fadeInOverlay;
- (void)fadeOutOverlay;
- (void)fadeOutOverlayWithCompletion:(void (^)(BOOL finished))completion;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller andDidChangeFeed:(BOOL)feedChanged;
@end