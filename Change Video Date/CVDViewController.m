//
//  CVDViewController.m
//  Change Video Date
//
//  Created by Joe on 4/3/13.
//  Copyright (c) 2013 relaxedapps. All rights reserved.
//

#import "CVDViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CVDViewController ()
@property (nonatomic, strong) NSDateFormatter *nowDateFormatter;
@property (nonatomic, strong) NSDateFormatter *nowTimeFormatter;
@property (nonatomic, strong) NSDateFormatter *metadataFormatter;

@end
@implementation CVDViewController

- (void)setEverythingEnabled:(BOOL)enabled {
    self.dayField.enabled = enabled;
    self.hourField.enabled = enabled;
    self.minuteField.enabled = enabled;
    self.secondField.enabled = enabled;
    self.directionSegmentedControl.enabled = enabled;
}

- (double)timeShiftInterval {
    double timeShiftInterval = 0;
    timeShiftInterval+=self.dayField.doubleValue*86400;
    timeShiftInterval+=self.hourField.doubleValue*3600;
    timeShiftInterval+=self.minuteField.doubleValue*60;
    timeShiftInterval+=self.secondField.doubleValue;
    if ( self.directionSegmentedControl.selectedSegment == 0 ) {
        timeShiftInterval*=-1;
    }
    return timeShiftInterval;
}

- (void)exportURLs:(NSArray *)urls toURL:(NSURL *)url{
    if ( [urls count] ) {
        [self setEverythingEnabled:NO];
        NSURL *firstURL = [urls objectAtIndex:0];
        NSString *filename = [firstURL lastPathComponent];
        NSURL *outURL = [url URLByAppendingPathComponent:filename isDirectory:NO];
        [self timeShiftMovieAtURL:firstURL toURL:outURL adjustment:[self timeShiftInterval] completion:^(NSError *error) {
            if ( error ) {
                [[NSAlert alertWithError:error] runModal];
            } else {
                NSUInteger countOfURLs = [urls count];
                if ( countOfURLs > 1 ) {
                    NSArray *shortenedURLs = [urls subarrayWithRange:NSMakeRange(1, countOfURLs - 1)];
                    [self exportURLs:shortenedURLs toURL:url];
                } else {
                    [self setEverythingEnabled:YES];
                }
            }
        }];
    } else {
        [self setEverythingEnabled:YES];
    }
}

- (IBAction)doIt:(id)sender {
    NSError *error = nil;
    [self.view.window makeFirstResponder:nil];
    if ( error ) {
        [[NSAlert alertWithError:error] runModal];
    } else {
        
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setAllowedFileTypes:@[@"public.movie"]];
        [panel setDelegate:self];
        [panel setCanChooseFiles:YES];
        [panel setCanCreateDirectories:NO];
        [panel setCanChooseDirectories:NO];
        [panel setAllowsMultipleSelection:YES];
        [panel setResolvesAliases:YES];
        
        [panel beginWithCompletionHandler:^(NSInteger result) {
            if ( [panel.URLs count] ) {
                NSURL *outURL = [[NSFileManager defaultManager] URLForDirectory:NSMoviesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
                outURL = [outURL URLByAppendingPathComponent:@"Change Video Date" isDirectory:YES];
                if ( !self.nowDateFormatter ) {
                    self.nowDateFormatter = [[NSDateFormatter alloc] init];
                    [self.nowDateFormatter setDateStyle:NSDateFormatterLongStyle];
                    [self.nowDateFormatter setTimeStyle:NSDateFormatterNoStyle];
                }
                NSDate *now = [NSDate date];
                NSString *folderName = [self.nowDateFormatter stringFromDate:now];
                outURL = [outURL URLByAppendingPathComponent:folderName isDirectory:YES];
                
                if ( !self.nowTimeFormatter ) {
                    self.nowTimeFormatter = [[NSDateFormatter alloc] init];
                    [self.nowTimeFormatter setDateFormat:@"H.mm.ss a"];
                }
                
                NSString *timeFolderName = [self.nowTimeFormatter stringFromDate:now];
                outURL = [outURL URLByAppendingPathComponent:timeFolderName isDirectory:YES];
                [[NSFileManager defaultManager] createDirectoryAtURL:outURL withIntermediateDirectories:YES attributes:nil error:nil];
                [[NSWorkspace sharedWorkspace] openURL:outURL];
                [self exportURLs:panel.URLs toURL:outURL];
            }
        }];
    }

}




- (void)timeShiftMovieAtURL:(NSURL *)inURL
                      toURL:(NSURL *)outURL
                 adjustment:(NSTimeInterval)interval
                 completion:(void (^) (NSError *error))completion {
    AVAsset *asset = [AVAsset assetWithURL:inURL];
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    session.outputFileType = AVFileTypeQuickTimeMovie;
    session.outputURL = outURL;
    NSArray *existingMetadata = asset.commonMetadata;
    if ( !self.metadataFormatter ) {
        self.metadataFormatter = [[NSDateFormatter alloc] init];
        [self.metadataFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    }
    NSMutableArray *newMetadata = [NSMutableArray arrayWithCapacity:existingMetadata.count];
    for ( AVMetadataItem *item in existingMetadata ) {
        if ( [item.key isEqual:AVMetadataQuickTimeMetadataKeyCreationDate] ) {
            AVMutableMetadataItem *mutableItem = [item mutableCopy];
            id existingDateString = mutableItem.value;
            if ( [existingDateString isKindOfClass:[NSString class]] ) {
                NSDate *existingDate = [self.metadataFormatter dateFromString:existingDateString];
                NSDate *newDate = [existingDate dateByAddingTimeInterval:interval];
                NSString *newDateString = [self.metadataFormatter stringFromDate:newDate];
                mutableItem.value = newDateString;
            }
            [newMetadata addObject:mutableItem];
        } else {
            [newMetadata addObject:item];
        }
    }
    session.metadata = newMetadata;
    [session exportAsynchronouslyWithCompletionHandler:^{
        if ( completion )
            completion(session.error);
    }];
}

@end
