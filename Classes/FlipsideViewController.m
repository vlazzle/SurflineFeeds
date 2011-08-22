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

@implementation FlipsideViewController

@synthesize
    delegate=_delegate,
    feedPickerView=_feedPickerView,
    overlayButton=_overlayButton,
    locationSwitch=_locationSwitch,
    locationView=_locationView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        feeds = [Feeds sharedFeeds];
        
        // initialize translation table to be a direct mapping
        feedRowTranslationTable = [[NSMutableArray alloc] initWithCapacity:[feeds count]];
        for (int i = 0; i < [feeds count]; i++) {
            [feedRowTranslationTable addObject:[NSNumber numberWithInt:i]];
        }
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.distanceFilter = 500;
        [locationManager startUpdatingLocation];
        
        // take up the whole window to overlap the navbar
        self.view.frame = CGRectMake(0, 20, 320, 460);
    }
    return self;
}

- (void)dealloc
{
    [locationManager release];
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
    
    [locationManager startUpdatingLocation];
    
    self.locationSwitch.enabled = ([CLLocationManager locationServicesEnabled] &&
                                   kCLAuthorizationStatusAuthorized == [CLLocationManager authorizationStatus]);
    self.locationSwitch.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"locationSwitchOn"] boolValue];
    
    originalFeedChoice = [feeds currentChoice];
    [self restoreFeedChoice];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [locationManager stopUpdatingLocation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [locationManager stopUpdatingLocation];
    
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
            NSLog(@"originalFeedChoice: %d", originalFeedChoice);
            NSLog(@"[feeds currentChoice]: %d", [feeds currentChoice]);
            [self.delegate flipsideViewControllerDidFinish:self andDidChangeFeed:feedChanged];
        }];
    }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (IBAction)locationSwitchValueChanged:(UISwitch *)sender
{
    [self.feedPickerView reloadAllComponents];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:self.locationSwitch.on] forKey:@"locationSwitchOn"];
    [defaults synchronize];
    
    [self restoreFeedChoice];
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [feeds count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [feeds feedNameForRow:[self translateRow:row back:NO]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSInteger translatedRow = [self translateRow:row back:NO];
    [feeds pickFeed:translatedRow];
}

- (NSInteger)translateRow:(NSInteger)row back:(BOOL)back {
    NSInteger translatedRow;
    if (self.locationSwitch.on) {
        if (back) {
            translatedRow = [feedRowTranslationTable indexOfObject:[NSNumber numberWithInteger:row]];
        }
        else {
            translatedRow = [(NSNumber *)[feedRowTranslationTable objectAtIndex:row] intValue];
        }
    }
    else {
        translatedRow = row;
    }
    
    return translatedRow;
}

- (void)restoreFeedChoice {
    NSInteger translatedFeedChoice = [self translateRow:[feeds currentChoice] back:YES];
    [self.feedPickerView selectRow:translatedFeedChoice inComponent:0 animated:NO];
}

#pragma mark -
#pragma mark Overlay Toggling

- (void)fadeInOverlay {
    [UIView animateWithDuration:0.1 animations:^{
        self.overlayButton.alpha = OVERLAY_ON_ALPHA;
    }];
}

- (void)fadeInOverlayWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.1 animations:^{
        self.overlayButton.alpha = OVERLAY_ON_ALPHA;
    }completion:completion];
}

- (void)fadeOutOverlay {
    [UIView animateWithDuration:0.1 animations:^{
        self.overlayButton.alpha = OVERLAY_OFF_ALPHA;
    }];
}
     
- (void)fadeOutOverlayWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.1 animations:^{
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
            [self.feedPickerView reloadAllComponents];
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
    if (!self.locationSwitch.enabled) {
        self.locationSwitch.on = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.locationSwitch.enabled = YES;
    
    if (newLocation == oldLocation) return;
    
    // set up feed location translation table by proximity
    NSMutableArray *feedsByProximity = [NSMutableArray arrayWithCapacity:[feeds count]];
    for (int i = 0; i < [feeds count]; i++) {
        CLLocation *location = [feeds feedLocationForRow:i];
        CLLocationDistance distance = [newLocation distanceFromLocation:location];
        [feedsByProximity addObject:[NSArray arrayWithObjects:
                                     [NSNumber numberWithDouble:distance],
                                     [feeds feedNameForRow:i],
                                     nil]];
    }
    
    // TODO maybe it would be better to use NSSortDescriptor and sortDescriptorWithKey:ascending
    [feedsByProximity sortUsingComparator:^(id obj1, id obj2) {
        NSNumber *lhs = [((NSArray *) obj1) objectAtIndex:FEED_DISTANCE];
        NSNumber *rhs = [((NSArray *) obj2) objectAtIndex:FEED_DISTANCE];
        return [lhs compare:rhs];
    }];
    
    [feedRowTranslationTable removeAllObjects];
    for (NSArray *pair in feedsByProximity) {
        NSString *feedName = [pair objectAtIndex:FEED_NAME];
        NSNumber *feedIndex = [NSNumber numberWithInteger:[feeds rowForName:feedName]];
        [feedRowTranslationTable addObject:feedIndex];
    }
    
    [self.feedPickerView reloadAllComponents];
    [self restoreFeedChoice];
}

@end
