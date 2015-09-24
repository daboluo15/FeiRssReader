//
//  SecondTableViewController.h
//  TableAndPageview
//
//  Created by Bo Gao on 9/7/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"
#import "GetMainImageFromWebpage.h"
#import "PendingOperations.h"

@interface SecondTableViewController : UITableViewController <NSXMLParserDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, ImageDownloaderDelegate, GetMainImageFromWebpageDelegate>
@property (nonatomic) long pageNumber;
@property (nonatomic) long selectedCell;
@property (nonatomic) NSString *rssLink;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) PendingOperations *pendingOperations;
@property (nonatomic) NSInteger viewControllerCount;

@end
