//
//  SubscribersViewController.m
//  vkapp
//
//  Created by sim on 29.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "SubscribersViewController.h"
#import "FullUserInfoPopupViewController.h"
#import "ViewControllerMenuItem.h"
#import <UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "MyTableRowView.h"
#import <SYFlatButton/SYFlatButton.h>
#import <NSColor_HexString/NSColor+HexString.h>
@interface SubscribersViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate>

@end

@implementation SubscribersViewController
@synthesize  ownerId;
- (void)viewDidLoad {
    [super viewDidLoad];
    subscribersList.delegate = self;
    subscribersList.dataSource = self;
    searchBar.delegate=self;
    [[subscribersScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    subscribersData = [[NSMutableArray alloc]init];
     _app = [[appInfo alloc]init];
    offsetCounter = 0;
    foundData = [[NSMutableArray alloc]init];
    friendsListPopupData = [[NSMutableArray alloc]init];

    selectedUsers = [[NSMutableArray alloc]init];
    _stringHighlighter = [[StringHighlighter alloc]init];
    [friendsListPopup removeAllItems];
    //     NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:favesScrollView.frame xRadius:4 yRadius:4];
    CAShapeLayer * layer = [CAShapeLayer layer];
    
    layer.cornerRadius=4;
    layer.borderWidth=1;
    layer.borderColor=[[NSColor colorWithWhite:0.8 alpha:1]CGColor];
    subscribersList.enclosingScrollView.wantsLayer = TRUE;
    subscribersList.enclosingScrollView.layer = layer;
    [self setFlatButtonStyle];
    
//    self.view.wantsLayer=YES;
//    [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisitUserPageFromSubscribers:) name:@"VisitUserPageFromSubscribers" object:nil];
    [self loadSubscribersPopup];
    
}
-(void)setFlatButtonStyle{
    NSLog(@"%@", self.view.subviews[0].subviews[0].subviews);
    for(NSArray *v in self.view.subviews[0].subviews[0].subviews){
        if([v isKindOfClass:[SYFlatButton class]]){
            SYFlatButton *button = (SYFlatButton *)v;
            [button setBezelStyle:NSRegularSquareBezelStyle];
            button.state=0;
            button.momentary = YES;
            button.cornerRadius = 4.0;
            button.borderWidth=1;
            button.backgroundNormalColor = [NSColor colorWithHexString:@"ecf0f1"];
            button.backgroundHighlightColor = [NSColor colorWithHexString:@"bdc3c7"];
            button.titleHighlightColor = [NSColor colorWithHexString:@"2c3e50"];
            //            button.titleNormalColor = [NSColor colorWithHexString:@"95a5a6"];
            button.titleNormalColor = [NSColor colorWithHexString:@"34495e"];
            button.borderHighlightColor = [NSColor colorWithHexString:@"7f8c8d"];
            button.borderNormalColor = [NSColor colorWithHexString:@"95a5a6"];
        }
    }
}
- (void)viewDidAppear{
    [self loadSubscribers:NO :NO];
    
    
}
- (void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:subscribersClipView]){
        NSInteger scrollOrigin = [[subscribersScrollView contentView]bounds].origin.y+NSMaxY([subscribersScrollView visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = subscribersList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
            if([foundData count] <=0){
                [self loadSubscribers:NO :YES];
            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }
}
- (void)VisitUserPageFromSubscribers:(NSNotification*)notification{
    
        NSInteger row = [notification.userInfo[@"row"] intValue];
        NSLog(@"%@", subscribersData[row]);
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@",subscribersData[row][@"id"]]]];
    
}

- (IBAction)friendsListPopupSelect:(id)sender {
    ownerId = subscribersData[[friendsListPopup indexOfSelectedItem]][@"id"];
    [self loadSubscribers:NO :NO];
}

-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadSearchSubscribers];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    subscribersData = subscribersDataCopy;
    [subscribersList reloadData];
}
-(void)loadSearchSubscribers{
    
    NSInteger counter=0;
    NSMutableArray *subscribersDataTemp=[[NSMutableArray alloc]init];
    subscribersDataCopy = [[NSMutableArray alloc]initWithArray:subscribersData];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    [subscribersDataTemp removeAllObjects];
    for(NSDictionary *i in subscribersData){
        
        NSArray *found = [regex matchesInString:i[@"full_name"]  options:0 range:NSMakeRange(0, [i[@"full_name"] length])];
        if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
            counter++;
            [subscribersDataTemp addObject:i];
        }
        
    }
    //     NSLog(@"Start search %@", banlistDataTemp);
    if([subscribersDataTemp count]>0){
        subscribersData = subscribersDataTemp;
        [subscribersList reloadData];
    }
    
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"subscribersMessageSeague"]){
        FriendsMessageSendViewController *controller = (FriendsMessageSendViewController *)segue.destinationController;
        NSInteger row = [subscribersList selectedRow];
        NSDictionary *receiverDataForMessage = subscribersData[row];
        NSLog(@"%@", receiverDataForMessage);
        controller.recivedDataForMessage=receiverDataForMessage;
    }
}
- (IBAction)selectAllAction:(id)sender {
    [subscribersList selectAll:self];
    
}
- (IBAction)showPopupProfileFullInfo:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
//    NSPoint mouseLoc = [NSEvent mouseLocation];
    //    int x = mouseLoc.x;
//    int y = mouseLoc.y;
    //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
    
    NSView *parentCell = [sender superview];
    NSInteger row = [subscribersList rowForView:parentCell];
//    CGRect rect=CGRectMake(0, y, 0, 0);
    popuper.receivedData = subscribersData[row];
    [popuper setToViewController];
//    NSLog(@"%@", subscribersData[row]);
//    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:subscribersList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadUserFullInfo" object:self userInfo:dataForUserInfo];

    
    
}
- (IBAction)addToFriendsActions:(id)sender {
    NSIndexSet *rows;
    rows=[subscribersList selectedRowIndexes];
    [selectedUsers removeAllObjects];
    void(^addToFriendsBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedUsers addObject:@{@"id":subscribersData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
        }
        for(NSDictionary *i in selectedUsers){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.add?user_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *addToBanResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", addToBanResponse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [subscribersList deselectRow:[i[@"index"] intValue]];
                });
                
            }]resume];
            sleep(1);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [subscribersData removeObjectsAtIndexes:rows];
//            arrayController.content = subscribersData;
//            [foundData removeAllObjects];
            [subscribersList reloadData];
        });
       
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        addToFriendsBlock();
    });

    
}
- (IBAction)addToBanAction:(id)sender {
    NSIndexSet *rows;
    rows=[subscribersList selectedRowIndexes];
    [selectedUsers removeAllObjects];
    
   void(^addToBanBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedUsers addObject:@{@"id":subscribersData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
            
           
        }
       for(NSDictionary *i in selectedUsers){
           [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.banUser?user_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
               NSDictionary *addToBanResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
               NSLog(@"%@", addToBanResponse);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [subscribersList deselectRow:[i[@"index"] intValue]];
                 });
           }]resume];
           sleep(1);
           
       }
       dispatch_async(dispatch_get_main_queue(), ^{
           [subscribersData removeObjectsAtIndexes:rows];
//           arrayController.content = subscribersData;
           //            [foundData removeAllObjects];
           [subscribersList reloadData];
       });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        addToBanBlock();
    });
//    NSLog(@"%@", selectedUsers);
    
}

- (IBAction)leaveAction:(id)sender {
    
    
}
- (IBAction)womenFilterAction:(id)sender {
    [self loadSubscribers:NO :NO];
    
}
- (IBAction)menFilterAction:(id)sender {
    [self loadSubscribers:NO :NO];
}
- (IBAction)FriendsFilterOfflineAction:(id)sender {
    
    [self loadSubscribers:NO :NO];
    
}
- (IBAction)FriendsFilterOnlineAction:(id)sender {
    
    [self loadSubscribers:NO :NO];
}
- (IBAction)FriendsFilterActiveAction:(id)sender {
    if(subscribersFilterActive.state == 0){
        subscribersFilterOffline.state=1;
        subscribersFilterOnline.state=0;
    }
    else{
        subscribersFilterOnline.state=1;
    }
    [self loadSubscribers:NO :NO];
}
- (IBAction)goUpAction:(id)sender {
    [subscribersList scrollToBeginningOfDocument:self];
}
- (IBAction)goDownAction:(id)sender {
    [subscribersList scrollToEndOfDocument:self];
    
}

-(void)loadSubscribersPopup{
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    __block  NSMenuItem *menuItem;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(!_loadFromFullUserInfo){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.get?owner_id=%@&v=%@&fields=city,domain,photo_50&access_token=%@", _app.person, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data){
                    NSDictionary *getFriendsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    for(NSDictionary *i in getFriendsResponse[@"response"][@"items"]){
                        [friendsListPopupData addObject:@{@"full_name":[NSString stringWithFormat:@"%@ %@", i[@"first_name"], i[@"last_name"]], @"id":i[@"id"]}];
                        ViewControllerMenuItem *viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
                        [viewControllerItem loadView];
                        menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@", i[@"first_name"], i[@"last_name"]] action:nil keyEquivalent:@""];
                        
                        
                        NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:i[@"photo_50"]]];
                        
                        image.size=NSMakeSize(30,30);
                        viewControllerItem.photo.wantsLayer=YES;
                        viewControllerItem.photo.layer.masksToBounds=YES;
                        viewControllerItem.photo.layer.cornerRadius=39/2;
                        [menuItem setImage:image];
                        //                    viewControllerItem.photo.layer.borderColor = [[NSColor grayColor] CGColor];
                        //                     viewControllerItem.photo.layer.borderWidth = 2.0;
                        [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
                        viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@ %@", i[@"first_name"],i[@"last_name"]];
                        [viewControllerItem.photo setImage:image];
                        [menuItem setView:[viewControllerItem view]];
                        [menu1 addItem:menuItem];
                    }
                    dispatch_async(dispatch_get_main_queue(),^{
                        //[friendsListDropdown setPullsDown:YES];
                        [friendsListPopup removeAllItems];
                        [friendsListPopup setMenu:menu1];
                    });
                }
            }]resume];
        }else{
            [friendsListPopupData removeAllObjects];
            NSLog(@"%@", _userDataFromFullUserInfo);
            [friendsListPopupData addObject:@{@"full_name":[NSString stringWithFormat:@"%@", _userDataFromFullUserInfo[@"full_name"]], @"id":_userDataFromFullUserInfo[@"id"]}];
            ViewControllerMenuItem *viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
            [viewControllerItem loadView];
            menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@", _userDataFromFullUserInfo[@"full_name"]] action:nil keyEquivalent:@""];
            
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:_userDataFromFullUserInfo[@"user_photo"]]];
            image.size=NSMakeSize(30,30);
            viewControllerItem.photo.wantsLayer=YES;
            viewControllerItem.photo.layer.masksToBounds=YES;
            viewControllerItem.photo.layer.cornerRadius=39/2;
            [menuItem setImage:image];
            [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
            viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@", _userDataFromFullUserInfo[@"full_name"]];
            [viewControllerItem.photo setImage:image];
            [menuItem setView:[viewControllerItem view]];
            [menu1 addItem:menuItem];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [friendsListPopup removeAllItems];
                //                [friendsListPopup addItemWithTitle:_userDataFromFullUserInfo[@"full_name"]];
                [friendsListPopup setMenu:menu1];
            });
        }
    });
    

}
-(void)loadSubscribers:(BOOL)searchByName :(BOOL)makeOffset{
   
    __block NSDictionary *object;
    if(makeOffset){
        offsetLoadSubscribers=offsetLoadSubscribers+500;
    }else{
        [subscribersData removeAllObjects];
        [subscribersList reloadData];
        offsetLoadSubscribers=0;
        offsetCounter=0;
    }
    ownerId = ownerId ? ownerId : _app.person;
     [progressSpin startAnimation:self];
//    __block NSMutableArray *tempSubscribers = [[NSMutableArray alloc]init];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.getFollowers?user_id=%@&count=500&offset=%i&suggested=0&need_viewed=1&fields=city,domain,photo_100,photo_200,status,last_seen,bdate,online,country,sex,about,site,contacts,books,music,schools,education,quotes,relation&v=%@&access_token=%@", ownerId, offsetLoadSubscribers, _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *responseGetFollowers = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(error){
                NSLog(@"responseGetFollowers error:%@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
                return;
          
            }
            if([response isKindOfClass:[NSHTTPURLResponse class]]){
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                if(statusCode != 200){
                    NSLog(@"responseGetFollowers response error %lu", statusCode );
                    return;
                }
                else{
                    
                    
                    NSString *city;
                    NSString *status;
                    NSString *bdate;
                    NSString *online;
                    NSString *firstName;
                    NSString *lastName;
                    NSString *fullName;
                    NSString *countryName;
                    NSString *last_seen;
                    NSString *sex;
                    NSString *books;
                    NSString *site;
                    NSString *mobilePhone;
//                    NSString *phone;
                    NSString *photoBig;
                    NSString *photo;
                    NSString *about;
                    NSString *music;
                    NSString *schools;
                    NSString *education;
                    NSString *quotes;
                    NSString *relation;
                    NSString *relation_partner;
                    NSString *domain;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        subscribersTotalCount.title=[NSString stringWithFormat:@"%i",[responseGetFollowers[@"response"][@"count"] intValue]];
                        
                        
                        
                    });
                    for(NSDictionary *a in responseGetFollowers[@"response"][@"items"]){
                        firstName = a[@"first_name"];
                        lastName=a[@"last_name"];
                        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                        city = a[@"city"] && a[@"city"][@"title"]!=nil ? a[@"city"][@"title"] : @"";
                        sex = a[@"sex"] && [a[@"sex"] intValue]==1? @"W" :[a[@"sex"] intValue]==2 ?  @"M" : [a[@"sex"] intValue]==0 ? @"n/a" : @"";
                        status = a[@"status"] && a[@"status"]!=nil ? a[@"status"] : @"";
                        music = a[@"music"] && a[@"music"]!=nil ? a[@"music"] : @"";
                        online = [NSString stringWithFormat:@"%@", a[@"online"]];
                        domain = a[@"domain"] && a[@"domain"]!=nil ? a[@"domain"] : @"";
                        if(a[@"bdate"] && a[@"bdate"] && a[@"bdate"]!=nil){
                            bdate = a[@"bdate"];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            NSString *templateLateTime2 = @"yyyy";
                            NSString *templateLateTime1 = @"d.M.yyyy";
                            //                            NSString *todayTemplate =@"d",
                            [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
                            [formatter setDateFormat:templateLateTime1];
                            NSDate *date = [formatter dateFromString:bdate];
                            [formatter setDateFormat:templateLateTime2];
                            if(![bdate isEqual:@""]){
                                bdate = [NSString stringWithFormat:@"%d лет", 2016 - [[formatter stringFromDate:date] intValue]];
                            }
                            if([bdate isEqual:@"2016 лет" ]){
                                bdate=@"";
                            }
                        }
                        else{
                            bdate=@"";
                        }
                       
                        
                        if(a[@"last_seen"] && a[@"last_seen"]!=nil){
                            double timestamp = [a[@"last_seen"][@"time"] intValue];
                            NSDate *gotDate = [[NSDate alloc] initWithTimeIntervalSince1970: timestamp];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            NSString *templateLateTime= @"dd.MM.yy HH:mm";
                            //                            NSString *todayTemplate =@"d",
                            [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
                            [formatter setDateFormat:templateLateTime];
                            last_seen = [NSString stringWithFormat:@"%@", [formatter stringFromDate:gotDate]];
                            
                        }
                        else{
                            last_seen = @"";
                        }
                        if([online intValue] == 1){
                            last_seen=@"";
                        }
                        countryName = a[@"country"] && a[@"country"]!=nil ? a[@"country"][@"title"] : @"";
                      
                        site = a[@"site"] && a[@"site"]!=nil ? a[@"site"] :  @"";
                        photoBig = a[@"photo_200"] ? a[@"photo_200"] : a[@"photo_100"];
                        photo = a[@"photo_100"];
                        mobilePhone = a[@"mobile_phone"] && a[@"mobile_phone"]!=nil ? a[@"mobile_phone"] : @"";
                        sex = a[@"sex"] && [a[@"sex"] intValue]==1 ? @"W" :[a[@"sex"] intValue]==2 ?  @"M" : [a[@"sex"] intValue]==0 ? @"n/a" : @"";
                        books = a[@"books"] && a[@"books"]!=nil ? a[@"books"] : @"";
                        about = a[@"about"] && a[@"about"]!=nil ? a[@"about"] : @"";
                        education = a[@"university_name"] && a[@"university_name"]!=nil ? a[@"university_name"] : @"";
                        schools = a[@"schools"] && a[@"schools"]!=nil &&  [a[@"schools"] count] > 0  ? a[@"schools"][0][@"name"] : @"";
                        quotes = a[@"quotes"] && a[@"quotes"]!=nil ? a[@"quotes"] : @"";
                        relation = a[@"relation"] && a[@"relation"]!=nil? a[@"relation"] : @"";
                        relation_partner = a[@"relation_partner"] && a[@"relation_partner"]!=nil ? a[@"relation_partner"] : @"";
//                        NSLog(@"%@", [a[@"schools"] count] > 0 ? a[@"schools"][0] : @"nnn");
                        object = @{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo,@"user_photo_big":photoBig, @"country":countryName, @"bdate":bdate, @"online":online, @"last_seen":last_seen, @"sex":sex, @"about":about, @"site":site, @"books":books, @"mobile":mobilePhone, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"relation":relation, @"relation_partner":relation_partner,@"domain":domain};
                        
                        if(subscribersFilterOnline.state==1 && subscribersFilterOffline.state ==1 && subscribersFilterActive.state == 1){
                            
                            
                            if(searchByName){
                                NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
                                fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                                NSArray *found = [regex matchesInString:fullName  options:0 range:NSMakeRange(0, [fullName length])];
                                
                                if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
                                    offsetCounter++;
                                    [subscribersData addObject:object];
                                }
                                
                            }
                            else{
                    
                                if (!a[@"deactivated"]){
                                    if(womenFilter.state==1 && menFilter.state==1){
                                        if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                            offsetCounter++;
                                            [subscribersData addObject:object];
                                        }
                                    }
                                    else if(womenFilter.state==1 && menFilter.state==0){
                                        if([a[@"sex"] intValue]==1){
                                            offsetCounter++;
                                            [subscribersData addObject:object];
                                        }
                                    }
                                    else if(womenFilter.state==0 && menFilter.state==1){
                                        if([a[@"sex"] intValue]==2){
                                            offsetCounter++;
                                            [subscribersData addObject:object];
                                        }
                                        
                                    }
                                    else if(womenFilter.state==0 && menFilter.state==0){
                                        if([a[@"sex"] intValue]==0){
                                            offsetCounter++;
                                            [subscribersData addObject:object];
                                        }
                                        
                                    }
                                }
                                
                            }
                        }
                        else if(subscribersFilterOnline.state==0 && subscribersFilterOffline.state ==1 && subscribersFilterActive.state == 1 ) {
                            
                        
                            if (![online  isEqual: @"1"]){
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                            }
                        }
                        else if(subscribersFilterOnline.state==1 && subscribersFilterOffline.state ==0 && subscribersFilterActive.state == 1) {
                            
                            if ([online  isEqual: @"1"]){
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                    
                                }
                            }
                        }
                        else if(subscribersFilterOnline.state==0 && subscribersFilterOffline.state == 1 && subscribersFilterActive.state == 0) {
                            
                            if (a[@"deactivated"]){
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                }
                            }
                        }
                        else if(subscribersFilterOnline.state==1 && subscribersFilterOffline.state == 1 && subscribersFilterActive.state == 0) {
                            
                            if (a[@"deactivated"] && ([online intValue]==1 || [online intValue]==0)){
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [progressSpin stopAnimation:self];
                        if([subscribersData count]>0){
                            
                            [subscribersList reloadData];
                            //                        [FriendsData removeAllObjects];
                            //                        [ActionProgress1 stopAnimation:(id)self];
                            subscribersCountInline.title=[NSString stringWithFormat:@"%lu",offsetCounter];
                        }
                        //                        [progressSpin stopAnimation:self];
                        //                        NSLog(@"%@", FriendsData);
                    });
                    
                    
                }
            }
        }
    }] resume];
}

//-(void)tableViewSelectionDidChange:(NSNotification *)notification{
//    
//    
//}
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    MyTableRowView *rowView = [[MyTableRowView alloc]init];
    
    return rowView;
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if ([subscribersData count]>0){
        return [subscribersData count];
    }
    return 0;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([subscribersData count]>0 && [subscribersData lastObject] && row <= [subscribersData count]){
        SubscribersCustomCell *cell = [[SubscribersCustomCell alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.fullName.stringValue = subscribersData[row][@"full_name"];
        cell.city.stringValue = subscribersData[row][@"city"];
        cell.country.stringValue = subscribersData[row][@"country"];
        cell.bdate.stringValue = subscribersData[row][@"bdate"];
        cell.lastSeen.stringValue = subscribersData[row][@"last_seen"];
//        cell.status.stringValue = subscribersData[row][@"status"];
        [cell.status setAllowsEditingTextAttributes:YES];
        [cell.status setFont:[NSFont fontWithName:@"Helvetica" size:12]];
        cell.sex.stringValue = subscribersData[row][@"sex"];
        cell.photo.wantsLayer=YES;
        cell.photo.layer.masksToBounds=YES;
        cell.photo.image.size = NSMakeSize(80, 80);
        cell.photo.layer.cornerRadius=80/2;
        
        
        [_stringHighlighter highlightStringWithURLs:subscribersData[row][@"status"] Emails:YES fontSize:12 completion:^(NSMutableAttributedString *highlightedString) {
            cell.status.attributedStringValue=highlightedString;
        }];
        
        [cell.photo sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", subscribersData[row][@"user_photo"]]] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSImageRep *rep = [[image representations] objectAtIndex:0];
            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
            image.size=imageSize;
            [cell.photo setImage:image];
        }];
        
        if([subscribersData[row][@"online"] intValue] == 1){
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
//            cell.lastOnline.stringValue = @"";
        }
        else{
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusNone]];
//              cell.lastOnline.stringValue = subscribersData[row][@"last_seen"];
        }
 
        return cell;
    }

    return nil;
}

@end
