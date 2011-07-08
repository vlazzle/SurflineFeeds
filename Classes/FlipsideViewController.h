//
//  FlipsideViewController.h
//  MWFeedParser
//
//  Created by Vladimir Chernis on 7/7/11.
//  Copyright 2011 Michael Waterfall. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Spots.h"

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    Spots *spots;
    UIPickerView *spotPickerView;    
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (readonly, nonatomic) IBOutlet UIPickerView *spotPickerView;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;

- (IBAction)done:(id)sender;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end