//
//  FlipsideViewController.m
//
//  Created by Vladimir Chernis on 7/7/11.
//

#import "FlipsideViewController.h"

static CGFloat OVERLAY_ON_ALPHA = 0.7;
static CGFloat OVERLAY_OFF_ALPHA = 0;
static NSTimeInterval OVERLAY_ON_DURATION = 0.2;
static NSTimeInterval OVERLAY_OFF_DURATION = 0.2;

@interface FlipsideViewController ()
@property (readwrite, nonatomic, retain) IBOutlet UIButton *overlayButton;
@end

@implementation FlipsideViewController

@synthesize delegate=_delegate, feedPickerView=_feedPickerView, overlayButton=_overlayButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // TODO dependency injection?
        feeds = [[Feeds alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [feeds release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.feedPickerView selectRow:[feeds currentChoice] inComponent:0 animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    CGRect pickerBounds = self.feedPickerView.bounds; 
    [self fadeOutOverlayWithCompletion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.feedPickerView.bounds = CGRectMake(
                                                    pickerBounds.origin.x, pickerBounds.origin.y - pickerBounds.size.height,
                                                    pickerBounds.size.width, pickerBounds.size.height);
        }completion:^(BOOL finished) {
            [self.delegate flipsideViewControllerDidFinish:self];
        }];
    }];
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [feeds count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [feeds feedNameForRow:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [feeds pickFeed:row];
}

#pragma mark -
#pragma mark Overlay Toggling

- (void)fadeInOverlay {
    [UIView animateWithDuration:OVERLAY_ON_DURATION animations:^{
        self.overlayButton.alpha = OVERLAY_ON_ALPHA;
    }];
}

- (void)fadeInOverlayWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:OVERLAY_ON_DURATION animations:^{
        self.overlayButton.alpha = OVERLAY_ON_ALPHA;
    }completion:completion];
}

- (void)fadeOutOverlay {
    [UIView animateWithDuration:OVERLAY_OFF_DURATION animations:^{
        self.overlayButton.alpha = OVERLAY_OFF_ALPHA;
    }];
}
     
- (void)fadeOutOverlayWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:OVERLAY_OFF_DURATION animations:^{
        self.overlayButton.alpha = OVERLAY_OFF_ALPHA;
    }completion:completion];
}

@end
