//
//  CustomSubscribersTableView.m
//  MasterAPI
//
//  Created by sim on 01.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomSubscribersTableView.h"

@implementation CustomSubscribersTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(NSMenu*)menuForEvent:(NSEvent*)theEvent
{
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    _row = [self rowAtPoint:mousePoint];
    
    if (theEvent.type==NSRightMouseDown) {
        
        NSMenu *menu=[[NSMenu alloc] initWithTitle:@"List of dialogs menu"];
        NSString *userInfoInBrowserText = @"Visit user page";
        NSString *userBanAndDeleteDialogText = @"Ban this user and delete dialog";
        NSMenuItem *userInfoInBrowserItem = [[NSMenuItem alloc] initWithTitle:userInfoInBrowserText action:@selector(openUserInfoInBrowser:) keyEquivalent:@""];
        NSMenuItem *userBanAndDeleteDialogItem = [[NSMenuItem alloc] initWithTitle:userBanAndDeleteDialogText action:@selector(userBanAndDeleteDialog) keyEquivalent:@""];
        [menu addItem:userInfoInBrowserItem];
        //        [menu addItem:userBanAndDeleteDialogItem];
        return menu;
    }
    return nil;
}

-(void)userBanAndDeleteDialog{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userBanAndDeleteDialog" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
- (IBAction)openUserInfoInBrowser:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitUserPageFromSubscribers" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
@end
