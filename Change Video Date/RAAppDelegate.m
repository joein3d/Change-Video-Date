//
//  RAAppDelegate.m
//  Change Video Date
//
//  Created by Joe on 4/3/13.
//  Copyright (c) 2013 relaxedapps. All rights reserved.
//

#import "RAAppDelegate.h"

@implementation RAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.window.delegate = self;
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] terminate:self];
}


@end
