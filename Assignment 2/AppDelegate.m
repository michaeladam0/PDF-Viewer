//
//  AppDelegate.m
//  Assignment 2
//
//  Created by Michael Adam on 1/10/13.
//  Copyright (c) 2013 Michael Adam. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification{
    [self.window setCollectionBehavior: NSWindowCollectionBehaviorFullScreenPrimary];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(setWindowTitle:)
                                                 name: @"PDFViewChangedPage"
                                               object: self.pdfViewItem];

    //Add splash screen window
    [self.window addChildWindow:self.splash ordered:NSWindowAbove];
    
    //Position main window
    CGFloat xPos2 = NSWidth([[self.window screen] frame])/2 - NSWidth([self.window frame])/2;
    CGFloat yPos2 = NSHeight([[self.window screen] frame])/2 - NSHeight([self.window frame])/2;
    [self.window setFrame:NSMakeRect(xPos2, yPos2, NSWidth([self.window frame]), NSHeight([self.window frame])) display:YES];
    
    //Position splash screen
    CGFloat xPos = NSWidth([[self.splash screen] frame])/2 - NSWidth([self.splash frame])/2;
    CGFloat yPos = NSHeight([[self.splash screen] frame])/2 - NSHeight([self.splash frame])/2;
    [self.splash setFrame:NSMakeRect(xPos, yPos, NSWidth([self.splash frame]), NSHeight([self.splash frame])) display:YES];
    
    //Hide search controls, hide splash screen after 1.5 sec and bring up the open file dialogue
    [self.searchControls setHidden:YES];
    [self performSelector:@selector(openDialogue:) withObject:self afterDelay:1.5];
    [self performSelector:@selector(hideSplash:) withObject:self afterDelay:1.5];
}

//Closes the splash screen window
-(void) hideSplash:(id)sender{
    [self.splash close];
}

//Opens a PDF file at the given URL, setting up initial values
-(void) windowWithURL:(NSURL *) urlIn{
    PDFDocument *document;
    document = [[PDFDocument alloc] initWithURL: urlIn];
    [self.pdfViewItem setDocument: document];
    [self.pdfViewItem allowsDragging];
    [self.pdfViewItem setAutoScales:YES];
    [self.pdfViewItem setDisplayMode:kPDFDisplaySinglePage];
    self.numPages = [document pageCount];
    self.fileName = [[document documentURL] lastPathComponent];
    
    [self.window setTitle:[NSString stringWithFormat:@"%@ (Page 1 of %li)", self.fileName, self.numPages]];
}

//Creates an NSOpenPanel object and sends the selected file url to the windowWithURL method
- (IBAction) openDialogue:(id)sender{
    NSOpenPanel *openPDF = [NSOpenPanel openPanel];
    [openPDF setMessage:@"Select a PDF to Open:"];
    [openPDF setAllowedFileTypes:[[NSArray alloc] initWithObjects:@"pdf", @"PDF", nil]];
    
    //Multi-Window
    [openPDF beginWithCompletionHandler:^ (NSInteger result){
        if (result == NSOKButton){
            [self windowWithURL:[openPDF URL]];
        }
    }];
}

//Receives a PDFViewChanged page notification and sets the title to a custom string containing the page number contained by the notification
-(void) setWindowTitle:(NSNotification *)notification{
    
    [self.window setTitle:[NSString stringWithFormat:@"%@ (Page %@ of %li)", self.fileName, [[(PDFView *)notification.object currentPage] label], self.numPages]];
    [self.pageSelectField setStringValue:[[(PDFView *)notification.object currentPage] label]];
}

//Secondary toggle for fullscreen so that the menu item works
-(IBAction) goFullScreen:(id)sender{
    [self.window toggleFullScreen:sender];
}

//Gets the search results for a given string, sets up document selection/focus, and stores the results in a local array. Removes data when no search is active
-(IBAction) search:(id)sender{
    NSString *searchString = [sender stringValue];
    if ([searchString compare:@""] != NSOrderedSame){
        PDFDocument *searchDoc = [self.pdfViewItem document];
        [self setSearchResults:[searchDoc findString:[sender stringValue] withOptions:NSCaseInsensitiveSearch]];
        [self setSearchSelectionIndex: 0];
        
        if([self.searchResults count] > 0){
            [self.searchControls setHidden:NO];
            [self.pdfViewItem goToSelection:[self.searchResults objectAtIndex:0]];
            [self.pdfViewItem setCurrentSelection:[self.searchResults objectAtIndex:0] animate:YES];
        }
    } else {
        [self.searchControls setHidden:YES];
        self.searchResults = [[NSArray alloc] init];
    }
}

//Shifts document focus accross search results as commanded by the popup controls
-(IBAction) manageSearch:(id)sender{
    if ([sender selectedSegment] == 0){
        if (self.searchSelectionIndex > 0){
            self.searchSelectionIndex--;
            [self.pdfViewItem goToSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex]];
            [self.pdfViewItem setCurrentSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex] animate:YES];

        } else{
            [self setSearchSelectionIndex: [self.searchResults count]-1];
            [self.pdfViewItem goToSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex]];
            [self.pdfViewItem setCurrentSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex] animate:YES];
        }
    } else if ([sender selectedSegment] == 1){
        if (self.searchSelectionIndex < [self.searchResults count]-1){
            self.searchSelectionIndex++;
            [self.pdfViewItem goToSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex]];
            [self.pdfViewItem setCurrentSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex] animate:YES];
        } else {
            [self setSearchSelectionIndex:0];
            [self.pdfViewItem goToSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex]];
            [self.pdfViewItem setCurrentSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex] animate:YES];
        }
    } else if ([sender selectedSegment] == 2){
        [self.searchControls setHidden:YES];
    }
}

//Shifts to next search result. This method is for the menu item
-(IBAction) searchNext:(id)sender{
    if([self.searchResults count] > 0){
        if (self.searchSelectionIndex < [self.searchResults count]-1){
            self.searchSelectionIndex++;
            [self.pdfViewItem goToSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex]];
            [self.pdfViewItem setCurrentSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex] animate:YES];
        } else {
            [self setSearchSelectionIndex:0];
            [self.pdfViewItem goToSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex]];
            [self.pdfViewItem setCurrentSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex] animate:YES];
        }
    }
}

//Shifts to previous search result. This method is for the menu item
-(IBAction) searchPrevious:(id)sender{
    if([self.searchResults count] > 0){
        if (self.searchSelectionIndex > 0){
            self.searchSelectionIndex--;
            [self.pdfViewItem goToSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex]];
            [self.pdfViewItem setCurrentSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex] animate:YES];
            
        } else{
            [self setSearchSelectionIndex: [self.searchResults count]-1];
            [self.pdfViewItem goToSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex]];
            [self.pdfViewItem setCurrentSelection:[self.searchResults objectAtIndex:self.searchSelectionIndex] animate:YES];
        }
    }
}


//Page navigation functions
-(IBAction) firstPage:(id)sender{
    [self.pdfViewItem goToFirstPage:(self)];
}

-(IBAction) lastPage:(id)sender{
    [self.pdfViewItem goToLastPage:(self)];
}

-(IBAction) nextPage:(id)sender{
    [self.pdfViewItem goToNextPage:(self)];
}

-(IBAction) prevPage:(id)sender{
    [self.pdfViewItem goToPreviousPage:(self)];
}

//Page navigation via the segmented control
-(IBAction) multiPage:(id)sender{
    if ([sender selectedSegment] == 0){
        [self.pdfViewItem goToFirstPage:(self)];
    } else if ([sender selectedSegment] == 1){
        [self.pdfViewItem goToPreviousPage:(self)];
    } else if ([sender selectedSegment] == 2){
        [self.pdfViewItem goToNextPage:(self)];
    } else if ([sender selectedSegment] == 3){
        [self.pdfViewItem goToLastPage:(self)];
    }
    
}

//Jump to page navigation via the text field on the toolbar
-(IBAction) pageSelect:(id)sender{
    if([sender intValue] <= self.numPages){
        [self.pdfViewItem goToPage:([[self.pdfViewItem document] pageAtIndex:[sender intValue]-1])];
    }
}

//Zoom functions
-(IBAction) zoomIn:(id)sender{
    [self.pdfViewItem zoomIn:(self)];
}

-(IBAction) zoomOut:(id)sender{
    [self.pdfViewItem zoomOut:(self)];
}

-(IBAction) autoZoom:(id)sender{
    [self.pdfViewItem setAutoScales:YES];
}

//Zoom functionality via the toolbar segmented control
-(IBAction) multiZoom:(id)sender{
    if ([sender selectedSegment] == 0){
        [self.pdfViewItem zoomOut:(self)];
    } else if ([sender selectedSegment] == 1){
        [self.pdfViewItem setAutoScales:YES];
    } else if ([sender selectedSegment] == 2){
        [self.pdfViewItem zoomIn:(self)];        
    }

}

//History navigation
-(IBAction) nextHistPage:(id)sender{
    [self.pdfViewItem goForward:(self)];
}

-(IBAction) prevHistPage:(id)sender{
    [self.pdfViewItem goBack:(self)];
}

//Display mode selector via the toolbar segmented control
-(IBAction) displayMode:(id)sender{
    if ([sender selectedTag] == 0){
        [self.pdfViewItem setDisplayMode:kPDFDisplaySinglePage];
        [self.pdfViewItem setAutoScales:YES];
    } else if ([sender selectedTag] == 1){
        [self.pdfViewItem setDisplayMode:kPDFDisplaySinglePageContinuous];
        [self.pdfViewItem setAutoScales:YES];
    } else if ([sender selectedTag] == 2){
        [self.pdfViewItem setDisplayMode:kPDFDisplayTwoUp];
        [self.pdfViewItem setAutoScales:YES];
    } else if ([sender selectedTag] == 3){
        [self.pdfViewItem setDisplayMode:kPDFDisplayTwoUpContinuous];
        [self.pdfViewItem setAutoScales:YES];
    }
}

//Display mode selector for the menubar display mode items
-(IBAction) displayModeMenu:(id)sender{
    if ([sender tag] == 0){
        [self.pdfViewItem setDisplayMode:kPDFDisplaySinglePage];
    } else if ([sender tag] == 1){
        [self.pdfViewItem setDisplayMode:kPDFDisplaySinglePageContinuous];
    } else if ([sender tag] == 2){
        [self.pdfViewItem setDisplayMode:kPDFDisplayTwoUp];
    } else if ([sender tag] == 3){
        [self.pdfViewItem setDisplayMode:kPDFDisplayTwoUpContinuous];
    }
}

//Presentation options for fullscreen mode
-(NSApplicationPresentationOptions) window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions{
    return (NSApplicationPresentationFullScreen |
            NSApplicationPresentationHideDock |
            NSApplicationPresentationAutoHideMenuBar |
            NSApplicationPresentationAutoHideToolbar);
}

@end
