//
//  FlipsideViewController.m
//
//  Created by Vladimir Chernis on 7/7/11.
//

#import "FlipsideViewController.h"

static CGFloat OVERLAY_ON_ALPHA = 0.7;
static CGFloat OVERLAY_OFF_ALPHA = 0;

static NSUInteger FEED_DISTANCE = 0;
static NSUInteger FEED_NAME = 1;

@interface FlipsideViewController ()
@property (readwrite, nonatomic, retain) CLLocationManager *locationManager;
@end

@implementation FlipsideViewController

@synthesize
    delegate=_delegate,
    feedPickerView=_feedPickerView,
    overlayButton=_overlayButton,
    locationSwitch=_locationSwitch,
    locationView=_locationView,
    locationManager=_locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        feeds = [Feeds sharedFeeds];
        
        // take up the whole window to overlap the navbar
        self.view.frame = CGRectMake(0, 20, 320, 460);
        
        // initialize translation table to be a direct mapping
        feedRowTranslationTable = [[NSMutableArray alloc] initWithCapacity:[feeds count]];
        for (int i = 0; i < [feeds count]; i++) {
            [feedRowTranslationTable addObject:[NSNumber numberWithInt:i]];
        }
    }
    return self;
}

- (void)dealloc
{
    [_locationManager release];
    [feedRowTranslationTable release];
    
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
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter = 500;
    [self.locationManager startUpdatingLocation];
    
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

- (IBAction)locationSwitchValueChanged:(UISwitch *)sender
{
    NSLog(@"new location switch value: %d", sender.on);
    if (sender.on) {        
        [self.feedPickerView reloadAllComponents];
    }
    
    reorderFeedsByLocation = self.locationSwitch.enabled && self.locationSwitch.on;
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [feeds count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSUInteger translatedRow;
    if (reorderFeedsByLocation) {
        translatedRow = [(NSNumber *)[feedRowTranslationTable objectAtIndex:row] intValue];
    }
    else {
        translatedRow = row;
    }
    return [feeds feedNameForRow:translatedRow];
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
        case kCLErrorLocationUnknown:
        case kCLErrorDenied:
        case kCLErrorNetwork:
            self.locationSwitch.on = NO;
            self.locationSwitch.enabled = NO;
            reorderFeedsByLocation = NO;
            break;

        // not using heading or region functionality
        case kCLErrorHeadingFailure:
        case kCLErrorRegionMonitoringDenied:
        case kCLErrorRegionMonitoringFailure:
        case kCLErrorRegionMonitoringSetupDelayed:
            break;
        
        default:
            NSLog(@"%@", [error localizedDescription]);
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.locationSwitch.enabled = [CLLocationManager locationServicesEnabled] && kCLAuthorizationStatusAuthorized == status;
    reorderFeedsByLocation = self.locationSwitch.enabled && self.locationSwitch.on;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // set up feed location translation table by proximity
    NSMutableArray *feedsByProximity = [NSMutableArray arrayWithCapacity:[feeds count]];
    for (int i = 0; i < [feeds count]; i++) {
        CLLocation *location = [feeds feedLocationForRow:i];
        CLLocationDistance distance = [self.locationManager.location distanceFromLocation:location];
        [feedsByProximity addObject:[NSArray arrayWithObjects:
                                     [NSNumber numberWithDouble:distance],
                                     [feeds feedNameForRow:i],
                                     nil]];
    }
    
    // TODO maybe it would be better to use NSSortDescriptor and sortDescriptorWithKey:ascending
    [feedsByProximity sortUsingComparator:^(id obj1, id obj2) {
        NSNumber *lhs = [((NSArray *) obj1) objectAtIndex:FEED_DISTANCE];
        NSNumber *rhs = [((NSArray *) obj2) objectAtIndex:FEED_DISTANCE];
        NSLog(@"comparing %@ to %@", lhs, rhs);
        return [lhs compare:rhs];
    }];
    
    [feedRowTranslationTable removeAllObjects];
    
    for (NSArray *pair in feedsByProximity) {
        NSString *feedName = [pair objectAtIndex:FEED_NAME];
        NSNumber *feedIndex = [NSNumber numberWithInteger:[feeds.feedNames indexOfObject:feedName]];
        [feedRowTranslationTable addObject:feedIndex];
    }
}

@end
