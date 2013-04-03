//
//  CVDViewController.h
//  Change Video Date
//
//  Created by Joe on 4/3/13.
//  Copyright (c) 2013 relaxedapps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CVDViewController : NSViewController <NSOpenSavePanelDelegate>
@property (weak) IBOutlet NSTextField *dayField;
@property (weak) IBOutlet NSTextField *hourField;
@property (weak) IBOutlet NSTextField *minuteField;
@property (weak) IBOutlet NSTextField *secondField;
@property (weak) IBOutlet NSSegmentedControl *directionSegmentedControl;
- (IBAction)doIt:(id)sender;

@end
