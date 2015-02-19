//
//  AppDelegate.h
//  Assignment 2
//
//  Created by Michael Adam on 1/10/13.
//  Copyright (c) 2013 Michael Adam. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *splash;
@property (assign) IBOutlet PDFView *pdfViewItem;
@property (assign) IBOutlet NSTextFieldCell *pageSelectField;

@property NSWindowController *splashScreenController;

@property (assign) IBOutlet NSSearchFieldCell *searchField;
@property (assign) IBOutlet NSSegmentedControl *searchControls;
@property NSArray *searchResults;
@property NSInteger searchSelectionIndex;

@property NSInteger numPages;
@property NSString *fileName;


-(IBAction) openDialogue:(id)sender;
-(IBAction) manageSearch:(id)sender;
-(IBAction) searchNext:(id)sender;
-(IBAction) searchPrevious:(id)sender;

-(IBAction) zoomIn:(id)sender;
-(IBAction) zoomOut:(id)sender;
-(IBAction) autoZoom:(id)sender;
-(IBAction) multiZoom:(id)sender;

-(IBAction) multiPage:(id)sender;
-(IBAction) firstPage:(id)sender;
-(IBAction) lastPage:(id)sender;
-(IBAction) nextPage:(id)sender;
-(IBAction) prevPage:(id)sender;
-(IBAction) nextHistPage:(id)sender;
-(IBAction) prevHistPage:(id)sender;
-(IBAction) pageSelect:(id)sender;

-(IBAction) displayMode:(id)sender;
-(IBAction) displayModeMenu:(id)sender;

-(IBAction) goFullScreen:(id)sender;

@end
