//
//  InstagramMediaPostsTableView.m
//  MasterAPI
//
//  Created by sim on 16.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "InstagramMediaPostsTableView.h"

@implementation InstagramMediaPostsTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(NSMenu*)menuForEvent:(NSEvent*)theEvent
{
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    _row = [self rowAtPoint:mousePoint];
    
    if (theEvent.type==NSRightMouseDown) {
        
        NSMenu *menu=[[NSMenu alloc] initWithTitle:@"Media posts context menu"];
    
        NSMenuItem *copyThisImageItem = [[NSMenuItem alloc] initWithTitle:@"Copy image url" action:@selector(copyImageURL:) keyEquivalent:@""];
        //        NSMenuItem *userBanAndDeleteDialogItem = [[NSMenuItem alloc] initWithTitle:userBanAndDeleteDialogText action:@selector(userBanAndDeleteDialog) keyEquivalent:@""];
        [menu addItem:copyThisImageItem];
        //        [menu addItem:userBanAndDeleteDialogItem];
        return menu;
    }
    return nil;
}
-(void)copyImageURL:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Copy instagram image URL" object:nil userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
@end
