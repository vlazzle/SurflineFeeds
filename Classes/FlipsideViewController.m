//
//  FlipsideViewController.m
//
//  Created by Vladimir Chernis on 7/7/11.
//

#import "FlipsideViewController.h"

static CGFloat OVERLAY_ON_ALPHA = 0.7;
static CGFloat OVERLAY_OFF_ALPHA = 0;

@implementation FlipsideViewController

@synthesize
    delegate=_delegate,
    feedPickerView=_feedPickerView,
    overlayButton=_overlayButton,
    locationSwitch=_locationSwitch,
    locationView=_locationView,
    locationManager=_locationManager,
    showLocationSwitch=_showLocationSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        feeds = [Feeds sharedFeeds];
        
        // take up the whole window to overlap the navbar
        self.view.frame = CGRectMake(0, 20, 320, 460);
        
        _showLocationSwitch = YES;
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationManager.distanceFilter = 500;
        [_locationManager startUpdatingLocation];
    }
    return self;
}

- (void)dealloc
{
    [_locationManager release];
    
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
    
    originalFeedChoice = [feeds currentChoice];
    [self.feedPickerView selectRow:originalFeedChoice inComponent:0 animated:NO];
    
    self.locationSwitch.enabled = [CLLocationManager locationServicesEnabled] && kCLAuthorizationStatusAuthorized == [CLLocationManager authorizationStatus];
    NSLog(@"locationSwitch.enabled: %d", self.locationSwitch.enabled);
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
    CGRect locationBounds = self.locationView.bounds;
    
    [self fadeOutOverlayWithCompletion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.feedPickerView.bounds = CGRectMake(pickerBounds.origin.x, pickerBounds.origin.y - pickerBounds.size.height,
                                                    pickerBounds.size.width, pickerBounds.size.height);
            
            self.locationView.bounds = CGRectMake(locationBounds.origin.x - locationBounds.size.width, locationBounds.origin.y,
                                                  locationBounds.size.width, locationBounds.size.height);
        }completion:^(BOOL finished) {
            BOOL feedChanged = [feeds currentChoice] != originalFeedChoice;
            [self.delegate flipsideViewControllerDidFinish:self andDidChangeFeed:feedChanged];
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
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayButton.alpha = OVERLAY_ON_ALPHA;
    }];
}

- (void)fadeInOverlayWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayButton.alpha = OVERLAY_ON_ALPHA;
    }completion:completion];
}

- (void)fadeOutOverlay {
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayButton.alpha = OVERLAY_OFF_ALPHA;
    }];
}
     
- (void)fadeOutOverlayWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayButton.alpha = OVERLAY_OFF_ALPHA;
    }completion:completion];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    switch ([error code]) {
        case kCLErrorDenied:
            self.locationSwitch.enabled = NO;
            break;
        default:
            NSLog(@"%@", [error localizedDescription]);
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.locationSwitch.enabled = status == kCLAuthorizationStatusAuthorized;
}

@end
