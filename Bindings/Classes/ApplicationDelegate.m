/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2015 Jean-David Gadina - www-xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

#import "ApplicationDelegate.h"
#import "MainWindowController.h"
#import "Group.h"
#import "Note.h"

@interface ApplicationDelegate()

@property( atomic, readwrite, strong ) MainWindowController * mainWindowController;

- ( void )load;
- ( void )save;

@end

@implementation ApplicationDelegate

- ( void )applicationDidFinishLaunching: ( NSNotification * )notification
{
    ( void )notification;
    
    self.mainWindowController = [ MainWindowController new ];
    
    [ self load ];
    [ self.mainWindowController.window center ];
    [ self.mainWindowController showWindow: nil ];
}

- ( BOOL )applicationShouldTerminateAfterLastWindowClosed: ( NSApplication * )sender
{
    ( void )sender;
    
    return YES;
}

- ( void )applicationWillTerminate: ( NSNotification * )notification
{
    ( void )notification;
    
    [ self save ];
}

- ( void )load
{
    NSMutableArray * groups;
    NSMutableArray * notes;
    NSDictionary   * groupDict;
    NSDictionary   * noteDict;
    Group          * group;
    Note           * note;
    
    groups = [ NSMutableArray new ];
    
    for( groupDict in [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"Groups" ] )
    {
        if( groupDict[ @"Name" ] == nil || groupDict[ @"Notes" ] == nil )
        {
            continue;
        }
        
        if
        (
               [ groupDict[ @"Name"  ] isKindOfClass: [ NSString class ] ] == NO
            || [ groupDict[ @"Notes" ] isKindOfClass: [ NSArray class  ] ] == NO
        )
        {
            continue;
        }
        
        notes = [ NSMutableArray new ];
        
        for( noteDict in groupDict[ @"Notes" ] )
        {
            if( noteDict[ @"Title" ] == nil || noteDict[ @"Date" ] == nil || noteDict[ @"Text" ] == nil )
            {
                continue;
            }
            
            if
            (
                   [ noteDict[ @"Title" ] isKindOfClass: [ NSString class ] ] == NO
                || [ noteDict[ @"Date"  ] isKindOfClass: [ NSDate class   ] ] == NO
                || [ noteDict[ @"Text"  ] isKindOfClass: [ NSString class ] ] == NO
            )
            {
                continue;
            }
            
            note       = [ Note new ];
            note.title = ( NSString * )noteDict[ @"Title" ];
            note.date  = ( NSDate   * )noteDict[ @"Date" ];
            note.text  = [ [ NSAttributedString alloc ] initWithString: ( NSString * )noteDict[ @"Text" ] ];
            
            [ notes addObject: note ];
        }
        
        group       = [ Group new ];
        group.name  = ( NSString * )( groupDict[ @"Name" ] );
        group.notes = notes;
        
        [ groups addObject: group ];
    }
    
    self.mainWindowController.groups = groups;
}

- ( void )save
{
    Group          * group;
    Note           * note;
    NSMutableArray * groups;
    NSMutableArray * notes;
    
    groups = [ NSMutableArray new ];
    
    for( group in self.mainWindowController.groups )
    {
        notes = [ NSMutableArray new ];
        
        for( note in group.notes )
        {
            [ notes addObject: @{ @"Title" : note.title, @"Date" : note.date, @"Text" : note.text.string } ];
        }
        
        [ groups addObject: @{ @"Name" : group.name, @"Notes" : notes } ];
    }
    
    [ [ NSUserDefaults standardUserDefaults ] setObject: groups forKey: @"Groups" ];
    [ [ NSUserDefaults standardUserDefaults ] synchronize ];
}

@end
