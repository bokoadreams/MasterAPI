//
//  ProgressViewController.h
//  MasterAPI
//
//  Created by sim on 06/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProgressViewController : NSViewController{
    
    __weak IBOutlet NSTextField *proccessLabel;
}
@property NSInteger total;
@property NSInteger current;
@end