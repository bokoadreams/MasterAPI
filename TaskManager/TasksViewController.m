//
//  TasksViewController.m
//  MasterAPI
//
//  Created by sim on 16.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TasksViewController.h"
#import <EventKit/EventKit.h>
#import "TasksCellView.h"
@interface TasksViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tasksData = [[NSMutableArray alloc]init];
    tasksList.delegate=self;
    tasksList.dataSource=self;
    runLoop = [[NSRunLoop alloc]init];
//    NSLog(@"dddd %@", [runLoop currentMode]);
    
    

}
- (IBAction)stopResume:(id)sender {
    NSView *view=[sender superview];
    NSInteger index = [tasksList rowForView:view];
    if([tasksData[index][@"state"] isEqual:@"stopped"]){
        tasksData[index][@"state"] =@"inprogress";
        tasksData[index][@"stopped"]=@0;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTaskProgress:) userInfo:[[NSMutableDictionary alloc] initWithDictionary:@{@"index":[NSNumber numberWithInteger:index] , @"seconds":[NSNumber numberWithInteger:[tasksData[index][@"currentPost"]intValue]]}] repeats:YES];
        NSLog(@"%@", tasksData[index]);
        [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
        
    }else{
        tasksData[index][@"state"]=@"stopped";
        tasksData[index][@"stopped"]=@1;
        
    }
    [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}
-(void)updateTaskProgress:(NSTimer*)timer{
    if(timer){
        if([timer.userInfo[@"seconds"] intValue] == 5){
            NSLog(@"%@",timer.userInfo[@"seconds"]);
            [timer invalidate];
            NSLog(@"Timer invalidated");
            
        }else{
            if([tasksData[[timer.userInfo[@"index"] intValue]][@"stopped"] intValue]){
                NSLog(@"%@", tasksData[[timer.userInfo[@"index"] intValue]][@"stopped"]);
                [timer invalidate];
            }else{
                timer.userInfo[@"seconds"] = [NSNumber numberWithInteger:[timer.userInfo[@"seconds"]intValue]+1];
                NSLog(@"%@",timer.userInfo[@"seconds"]);
                tasksData[[timer.userInfo[@"index"] intValue]][@"currentPost"] =[NSNumber numberWithInteger:[timer.userInfo[@"seconds"]intValue]];
                [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[timer.userInfo[@"index"] intValue]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            }
            //        TasksCellView *cell = (TasksCellView*)[tasksList relo
//             NSLog(@"%@", tasksData[[timer.userInfo[@"index"] intValue]][@"stop"]);
            
        }
    }
  
   
//   [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"https://google.com"]];
    
}
- (IBAction)newTask:(id)sender {
    [self addTask];
}
-(void)addTask{
    NSInteger taskIndex=[tasksData count];
    NSInteger totalPosts = 5;
    NSMutableDictionary *taskObject = [[NSMutableDictionary alloc]initWithDictionary:@{@"name":[NSString stringWithFormat:@"Task %li", taskIndex+1], @"totalPosts":[NSNumber numberWithInteger:totalPosts], @"currentPost":@0, @"state":@"inprogress"}];
    [tasksData addObject:taskObject];
    [tasksList insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[tasksData count]-1] withAnimation:NSTableViewAnimationSlideDown];
    
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    [dateComponents setYear:2016];
//    [dateComponents setMonth:12];
//    [dateComponents setDay:19];
//    [dateComponents setHour:15];
//    [dateComponents setMinute:20];
//    NSCalendar *calendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDate *configuredDate = [calendar dateFromComponents:dateComponents];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTaskProgress:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"index":[NSNumber numberWithInteger:taskIndex], @"seconds":@0}] repeats:YES];
  
    [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
    
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [tasksData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TasksCellView *cell = (TasksCellView*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.taskName.stringValue=tasksData[row][@"name"];
    cell.taskProgress.maxValue=[tasksData[row][@"totalPosts"] intValue];
    cell.taskProgress.doubleValue=[tasksData[row][@"currentPost"] intValue];
    if([tasksData[row][@"state"] isEqual:@"inprogress"]){
        cell.StopResume.image = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
        
    }else{
        cell.StopResume.image=[NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];
    }
    return cell;
}
@end
