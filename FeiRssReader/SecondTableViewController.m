//
//  SecondTableViewController.m
//  TableAndPageview
//
//  Created by Bo Gao on 9/7/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import "SecondTableViewController.h"
#import "WebViewController.h"
#import "TFHpple.h"

@interface SecondTableViewController ()
@property(nonatomic) NSURL *myURLTofile;
@property(nonatomic) NSMutableArray *urlArray;
@property(nonatomic) UIActivityIndicatorView *spinner;


@property (nonatomic, strong) NSXMLParser *xmlParser;

@property (nonatomic, strong) NSMutableArray *newsItem;
@property (nonatomic) NSMutableArray *imageUrlList;

@property (nonatomic, strong) NSMutableDictionary *tempDataStorage;

@property (nonatomic, strong) NSMutableString *foundValue;

@property (nonatomic, strong) NSString *currentElement;

@property (nonatomic) UIScrollView *scrollview;
@property (nonatomic) UIPageControl *pagecontrol;

@end

@implementation SecondTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createPageViewOnTableView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Add Edit button on the navigation bar
    //self.navigationItem.leftBarButtonItem = [self editButtonItem];
    self.navigationController.delegate = self;
    self.viewControllerCount = -1;
    
    self.spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    CGRect screenSize = [UIScreen mainScreen].bounds;

    CGFloat x = screenSize.size.width/2;
    CGFloat y = screenSize.size.height/2;
    
    //self.spinner.center = CGPointMake(self.view.center.x, self.view.center.y - 90);
    self.spinner.center = CGPointMake(x, y - 80);
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    self.pendingOperations = [[PendingOperations alloc] init];
    
    [self loadFeed];

    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(loadFeed)
                  forControlEvents:UIControlEventValueChanged];

}

- (void)didReceiveMemoryWarning {
    [self cancelAllOperations];
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
    NSLog(@"xxxbo: in didreceiveMemoryWarning: low memory!");
}

#pragma mark - page view
-(void) createPageViewOnTableView {
    //创建scrollview 添加内容，设置代理，将其添加到headerview中
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    self.scrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, width, 150)];
    NSLog(@"the width of the screen is %f", [[UIScreen mainScreen] bounds].size.width);
    //分页设置
    self.scrollview.pagingEnabled = YES;
    //滚动条显示设置
    self.scrollview.showsHorizontalScrollIndicator=NO;
    self.scrollview.showsVerticalScrollIndicator=NO;
    //视图内容的尺寸
    self.scrollview.contentSize = CGSizeMake(width*4, 150);
    self.tableView.tableHeaderView = self.scrollview;
    self.scrollview.delegate = self;
    //添加内容
    float x = 0;
    for (int i = 1; i <= 4; i++)
    {
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(x, 0, width, 150)];
        
        //NSString *imagename=[NSString stringWithFormat:@"Image%d.jpg",i];
        NSString *imagename = @"news-paper";
        
        UIImage *oldImage = [UIImage imageNamed:imagename];
        
        imageview.image = oldImage;
        
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, width - 40, 40)];
        myLabel.text = @"Getting Content...";
        myLabel.textAlignment = NSTextAlignmentCenter;
        myLabel.textColor = [UIColor whiteColor];
        myLabel.backgroundColor = [UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:0.8];
        //myLabel.backgroundColor = [UIColor clearColor];
        [imageview addSubview:myLabel];
        
        [self.scrollview addSubview:imageview];
        x += width;
        
        
    }
    self.tableView.tableHeaderView=self.scrollview;
    //self.tableView.dataSource = self;
    
    
    //创建分页控制器，添加到tableview中
    self.pagecontrol=[[UIPageControl alloc]initWithFrame:CGRectMake(width/2 - 5, 130, 20, 20)];
    //总得页数
    self.pagecontrol.numberOfPages=4;
    //当前显示的页数
    self.pagecontrol.currentPage=0;
    [self.tableView addSubview:self.pagecontrol];
    
    [self setupGestureRecognizer];

}

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.scrollview addGestureRecognizer:tapGestureRecognizer];
    //tapGestureRecognizer.delegate = self;
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    //Code to handle the gesture
    long currentPage = self.pagecontrol.currentPage;
    NSLog(@"current page is %ld", currentPage);
    
    // Select uitableview row programmatically
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentPage inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];

    [self performSegueWithIdentifier:@"webView" sender:self];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.newsItem.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.urlArray removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        [self.urlArray writeToURL:self.myURLTofile atomically:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }

    // Configure the cell...

    NSString *title = [[[self.newsItem objectAtIndex:indexPath.row] objectForKey:@"title"] stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // set the label of the headerview
    if (indexPath.row < self.scrollview.subviews.count) {
        if ([self.scrollview subviews])
        {
            UIView *currentPageView = [[self.scrollview subviews] objectAtIndex:indexPath.row];
            UILabel *currentLabel = [[currentPageView subviews] objectAtIndex:0];
            currentLabel.text = title;

        }
    }
    
    cell.textLabel.text = title;
    
    NSLog(@"cell image name is %@, indexpath.row = %ld", [self.imageUrlList objectAtIndex:indexPath.row], indexPath.row);
    
    // always show the default thumnail always
    [self showDefaultNewsThumbnailForCell:cell];
    
    // already has image downloaded, just show it directly
    if ([[self.newsItem objectAtIndex:indexPath.row] objectForKey:@"image"] != [NSNull null]) {
        UIImage *thumbnail = [[self.newsItem objectAtIndex:indexPath.row] objectForKey:@"image"];
        // set the showing size of the image
        CGSize itemSize = CGSizeMake(60, 45);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [thumbnail drawInRect:imageRect];
        
        // set round corner
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 10.0;
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [cell setNeedsLayout];

    } else {
        // first show the default image
        if ([[self.imageUrlList objectAtIndex:indexPath.row] isEqualToString:@""]) {

            [self showDefaultNewsThumbnailForCell:cell];

        } else {
            // download the image and show it in the cell
            if (!self.tableView.dragging && !self.tableView.decelerating) {
                if ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    NSLog(@"xxxbo: visible %@", indexPath);
                    // download the image asynchronously
                    
                    [self startOperationsForImageLink:[self.imageUrlList objectAtIndex:indexPath.row] atIndexPath:indexPath];
                }
            }
        }
    }
    return cell;
}

-(void) showDefaultNewsThumbnailForCell:(UITableViewCell *)cell {
    CGSize itemSize = CGSizeMake(60, 45);
    UIGraphicsBeginImageContext(itemSize);
    UIImage *thumbnail = nil;
    thumbnail = [UIImage imageNamed:@"news-paper"];
    
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [thumbnail drawInRect:imageRect];
    
    // set round corner
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 10.0;
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [cell setNeedsLayout];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"webView"]) {
        WebViewController *detailedTableView = [segue destinationViewController];
        
        detailedTableView.urlAddress = [[self.newsItem objectAtIndex:[self.tableView indexPathForSelectedRow].row] objectForKey:@"link"];
        NSLog(@"detailedTableView.urlAddress is %@", detailedTableView.urlAddress);
        
//       // Cancel all operation
//        [self cancelAllOperations];
        
    };
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    NSArray *viewControllers = [navigationController viewControllers];
    
    if (self.viewControllerCount == 2 && viewControllers.count == 1)
    {
        NSLog(@"boxxx: go back");
        [self cancelAllOperations];
    }
    
    self.viewControllerCount = viewControllers.count;
    
}


- (void)downloadDataFromURL:(NSURL *)url forIndex:(int)index withCompletionHandler:(void (^)(NSData *, int aindex))completionHandler{
    // Instantiate a session configuration object.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Instantiate a session object.
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // Create a data task object to perform the data downloading.
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            // If any error occurs then just display its description on the console.
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            // If no error occurs, check the HTTP status code.
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
            
            // If it's other than 200, then show it on the console.
            if (HTTPStatusCode != 200) {
                NSLog(@"HTTP status code = %ld", HTTPStatusCode);
            }
            
            // Call the completion handler with the returned data on the main thread.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler(data, index);
            }];
        }
    }];
    
    // Resume the task.
    [task resume];
}

-(void)loadFeed {
    //NSString *rssFeed = @"http://feeds.feedburner.com/lyndacom-new-releases?format=xml";
    //NSString *rssFeed = @"http://feeds.feedburner.com/google/think";
    //NSString *rssFeed = @"http://www.mitbbs.com/rss/top.xml";
    //NSString *rssFeed = @"http://cn.engadget.com/rss.xml";
    //NSString *rssFeed = @"http://www.36kr.com/feed";
    //NSString *rssFeed = @"http://cn.wsj.com/gb/rss02.xml";
    //NSString *rssFeed = @"http://songshuhui.net/feed";
    //NSString *rssFeed = @"http://time.com/newsfeed/feed/";
    //NSString *rssFeed = @"http://www.engadget.com/rss.xml";
    NSString *rssFeed = [NSString stringWithFormat:@"%@", self.rssLink];
    NSLog(@"rssFeed is %@", rssFeed);
    
    NSURL *rssURL = [NSURL URLWithString:rssFeed];
#if 0
    [self downloadDataFromURL:rssURL forIndex:-1 withCompletionHandler:^(NSData *data, int aindex) {
        // Make sure that there is data.
        if (data != nil) {
            self.xmlParser = [[NSXMLParser alloc] initWithData:data];
            self.xmlParser.delegate = self;
            
            // Initialize the mutable string that we'll use during parsing.
            self.foundValue = [[NSMutableString alloc] init];
            
            // Start parsing.
            [self.xmlParser parse];
        }
    }];
#else
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *data = [NSData dataWithContentsOfURL:rssURL];
        NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"ret=%@", ret);
        dispatch_async(dispatch_get_main_queue(), ^{
            // Make sure that there is data.
            if (data != nil) {
                self.xmlParser = [[NSXMLParser alloc] initWithData:data];
                self.xmlParser.delegate = self;
                
                // Initialize the mutable string that we'll use during parsing.
                self.foundValue = [[NSMutableString alloc] init];
                
                // Start parsing.
                [self.xmlParser parse];
            }
        });
    });
#endif
    
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    // Initialize the neighbours data array.
    self.newsItem = [[NSMutableArray alloc] init];
    self.imageUrlList = [[NSMutableArray alloc] initWithCapacity:1000];
    for(int i = 0; i<1000; i++) {
        [self.imageUrlList addObject: @""];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
    [self.spinner stopAnimating];
    
    // fetch all image url
    //[self fetchAllImageUrl];
    [self fetchVisibleImageUrl];
    
    //loop the array and print the items
#if 0
    for (NSDictionary *myItem in self.newsItem) {
        NSLog(@"the title is %@", [myItem objectForKey:@"title"]);
        NSLog(@"the link is %@", [myItem objectForKey:@"link"]);
        NSLog(@"the image is %@", [myItem objectForKey:@"image"]);
        //NSLog(@"the image url is %@", [myItem objectForKey:@"imageURL"]);
    }
#endif
    
    // When the parsing has been finished then simply reload the table view.
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    // If the current element name is equal to "geoname" then initialize the temporary dictionary.
    if ([elementName isEqualToString:@"item"]) {
        self.tempDataStorage = [[NSMutableDictionary alloc] init];
    }
    
    // Keep the current element.
    self.currentElement = elementName;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"item"]) {
        // If the closing element equals to "geoname" then the all the data of a neighbour country has been parsed and the dictionary should be added to the neighbours data array.
        [self.tempDataStorage setObject:[NSNull null] forKey:@"image"];
        //[self.newsItem addObject:[[NSDictionary alloc] initWithDictionary:self.tempDataStorage]];
        [self.newsItem addObject:[[NSMutableDictionary alloc] initWithDictionary:self.tempDataStorage]];
        
    }
    else if ([elementName isEqualToString:@"title"]){
        // If the country name element was found then store it.
        [self.tempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"title"];
    }
    else if ([elementName isEqualToString:@"link"]){
        // If the toponym name element was found then store it.
        [self.tempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"link"];
    }
    
    // Clear the mutable string.
    [self.foundValue setString:@""];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Store the found characters if only we're interested in the current element.
    if ([self.currentElement isEqualToString:@"title"] ||
        [self.currentElement isEqualToString:@"link"]) {
        
        if (![string isEqualToString:@"\n"]) {
            [self.foundValue appendString:string];
        }
    }
}

#pragma mark -
#pragma mark - UIScrollView delegate

#if 1
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 1: As soon as the user starts scrolling, you will want to suspend all operations and take a look at what the user wants to see.
    [self suspendAllOperations];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 2: If the value of decelerate is NO, that means the user stopped dragging the table view. Therefore you want to resume suspended operations, cancel operations for offscreen cells, and start operations for onscreen cells.
    if (!decelerate) {
        [self loadImagesForOnscreenCells];
        [self resumeAllOperations];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 3: This delegate method tells you that table view stopped scrolling, so you will do the same as in #2.
    [self loadImagesForOnscreenCells];
    [self resumeAllOperations];
}
#endif

//使用代理方法实现翻页效果

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    if (scrollView==self.scrollview)
    //    {
    //        NSLog(@"scrollview.contentoffset is %f", self.scrollview.contentOffset.x);
    //        int page= self.scrollview.contentOffset.x/[[UIScreen mainScreen] bounds].size.width;
    //        self.pagecontrol.currentPage=page;
    //
    //    }
    //    CGFloat pageWidth = scrollView.bounds.size.width;
    //    NSLog(@"pageWidth is %f", pageWidth);
    //    NSInteger pageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //    self.pagecontrol.currentPage = pageNumber;
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    self.pagecontrol.currentPage = page;
    
}



#pragma mark -
#pragma mark - Cancelling, suspending, resuming queues / operations


- (void)suspendAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:YES];
    [self.pendingOperations.getMainImageUrlQueue setSuspended:YES];
}


- (void)resumeAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:NO];
    [self.pendingOperations.getMainImageUrlQueue setSuspended:NO];
}


- (void)cancelAllOperations {
    [self.pendingOperations.downloadQueue cancelAllOperations];
    [self.pendingOperations.getMainImageUrlQueue cancelAllOperations];
}

- (void)loadImagesForOnscreenCells {
    
    // 1: Get a set of visible rows.
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    
    // 2: Get a set of all pending operations (download and filtration).
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[self.pendingOperations.getMainImageUrlInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    // 3: Rows (or indexPaths) that need an operation = visible rows ñ pendings.
    //[toBeStarted minusSet:pendingOperations];
    
    // 4: Rows (or indexPaths) that their operations should be cancelled = pendings ñ visible rows.
    //[toBeCancelled minusSet:visibleRows];
    
    // 5: Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadsInProgress removeObjectForKey:anIndexPath];
        
        GetMainImageFromWebpage *pendingGetMainImage = [self.pendingOperations.getMainImageUrlInProgress objectForKey:anIndexPath];
        [pendingGetMainImage cancel];
        [self.pendingOperations.getMainImageUrlInProgress removeObjectForKey:anIndexPath];

    }
    toBeCancelled = nil;
    
    // 6: Loop through those to be started, and call startOperationsForPhotoRecord:atIndexPath: for each.
    for (NSIndexPath *anIndexPath in toBeStarted) {
        
        //PhotoRecord *recordToProcess = [self.photos objectAtIndex:anIndexPath.row];
        //[self startOperationsForPhotoRecord:recordToProcess atIndexPath:anIndexPath];
        [self startOperationsForImageLink:[self.imageUrlList objectAtIndex:anIndexPath.row] atIndexPath:anIndexPath];
        [self fetchVisibleImageUrl];
    }
    toBeStarted = nil;
    
}



-(void)fetchAllImageUrl {
    // loading the http link and then fetch the first image link inside it
    
    // got the index of visible cell on the screen
    NSArray *indexArray = [self.tableView indexPathsForVisibleRows];
    int i=0;
    while(i != indexArray.count){
        //Log out the int value for the row
        NSLog(@"in fetchAllImageUrl, the index of visible cell %ld", ((NSIndexPath*)[indexArray objectAtIndex:i]).row);
        i++;
    }

    int index = 0;
    for (NSMutableDictionary *myItem in self.newsItem) {
        NSLog(@"the title is %@", [myItem objectForKey:@"title"]);
        NSLog(@"the link is %@", [myItem objectForKey:@"link"]);
        // remove the space, tab, and new line from the url
        NSString *cleanUrlAddress = [[NSString stringWithString:[myItem objectForKey:@"link"]] stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // convert the illegal character into legal ones
        NSString *correcedURLAddress = [cleanUrlAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        NSURL *url = [NSURL URLWithString:correcedURLAddress];
        
        [self downloadDataFromURL:url forIndex:index withCompletionHandler:^(NSData *data, int aindex) {
            // Make sure that there is data.
            if (data != nil) {
                NSString *stringHTML = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                
    #if 0
                NSString *imageURL = [self getFirstImageUrl:stringHTML];
                NSLog(@"the image is %@, for aindex = %d, index = %d", imageURL, aindex, index);
                
                if (imageURL != nil) {
                    [self.imageUrlList replaceObjectAtIndex:aindex withObject:[NSString stringWithString:imageURL]];
                    [self.tableView reloadData];
                }
                else {
                    [self.imageUrlList replaceObjectAtIndex:aindex withObject:@""];
                    //[self.tableView reloadData];
                }
    #else
                [self getMainContentImageUrl:stringHTML itemIndex:aindex];
    #endif
            }
        }];
        
        index++;
    }
  }

-(void)fetchVisibleImageUrl {
    // loading the http link and then fetch the first image link inside it
    
    // got the index of visible cell on the screen
    NSArray *indexArray = [self.tableView indexPathsForVisibleRows];
    int i=0;
    while(i != indexArray.count){
        //Log out the int value for the row
        NSLog(@"in fetchVisibleImageUrl, the index of visible cell %ld", ((NSIndexPath*)[indexArray objectAtIndex:i]).row);
        i++;
    }
#if 1
    int index = 0;
    
    for (NSMutableDictionary *myItem in self.newsItem) {

        // remove the space, tab, and new line from the url
        NSString *cleanUrlAddress = [[NSString stringWithString:[myItem objectForKey:@"link"]] stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // convert the illegal character into legal ones
        NSString *correcedURLAddress = [cleanUrlAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        NSURL *url = [NSURL URLWithString:correcedURLAddress];
        
        [self downloadDataFromURL:url forIndex:index withCompletionHandler:^(NSData *data, int aindex) {
            // Make sure that there is data.
            if (data != nil) {
                NSString *stringHTML = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                
                
                //[self getMainContentImageUrl:stringHTML itemIndex:aindex];
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self startOperationForGetMainImageForHtmlContent:stringHTML atIndexPath:indexPath];
                
            }
        }];
        
        index++;
    }
    
#else
    
    for (int i = 0; i < indexArray.count; i++) {
        long  index = ((NSIndexPath*)[indexArray objectAtIndex:i]).row;
        NSMutableDictionary *tempItem = [self.newsItem objectAtIndex:index];
        //        NSLog(@"the title is %@", [tempItem objectForKey:@"title"]);
        //        NSLog(@"the link is %@", [tempItem objectForKey:@"link"]);
        // remove the space, tab, and new line from the url
        NSString *cleanUrlAddress = [[NSString stringWithString:[tempItem objectForKey:@"link"]] stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // convert the illegal character into legal ones
        NSString *correcedURLAddress = [cleanUrlAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        NSURL *url = [NSURL URLWithString:correcedURLAddress];
        
        [self downloadDataFromURL:url forIndex:index withCompletionHandler:^(NSData *data, int aindex) {
            // Make sure that there is data.
            if (data != nil) {
                NSString *stringHTML = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                
                
                //[self getMainContentImageUrl:stringHTML itemIndex:aindex];
                [self startOperationForGetMainImageForHtmlContent:stringHTML atIndexPath:[indexArray objectAtIndex:i]];
                
            }
        }];
        
        //index++;
    }
#endif
}


-(NSString *)getFirstImageUrl: (NSString *) html {

    NSDictionary * imageLink = nil;
    NSString *imageSource = nil;
    
    NSScanner *pageScanner = [NSScanner scannerWithString:html];
    [pageScanner scanUpToString:@"<img " intoString:nil];
    NSString * linkString = nil;
    if ([pageScanner scanUpToString:@">" intoString:&linkString]) {
        imageLink = [self getAttributes:linkString];
        
        imageSource = [imageLink valueForKey:@"src"];
    }
    return imageSource;
}

-(void)getMainContentImageUrl: (NSString *) html itemIndex: (int) index {
    

    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    
    NSString *xpathQueryString = @"//img";
    NSArray *nodes = [parser searchWithXPathQuery:xpathQueryString];

    __block float maxSize = 0.0;
    __block NSString *maxImageSource = nil;
    __block BOOL gotImageURL = false;
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_queue_t imageQueue = dispatch_queue_create("Image Queue",DISPATCH_QUEUE_CONCURRENT);
    
    // global queue and concurrent queue don't work, only serial queue works
    dispatch_queue_t imageQueue = dispatch_queue_create("Image Queue", NULL);
    dispatch_async(imageQueue, ^{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //dispatch_group_t group = dispatch_group_create();
        for (TFHppleElement *element in nodes)
        {
        
            NSString *imageSource = [element objectForKey:@"src"];
            //NSString *imageSource = [[nodes objectAtIndex:0] objectForKey:@"src"];
            
            NSURL *imageURL = [NSURL URLWithString:imageSource];
            
            //dispatch_async(imageQueue, ^{

                NSLog(@"in dispatch, imageurl = %@", imageSource);
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                // the size > 10k
                if (imageData != nil) {
                    NSLog(@"imagedata.length = %f KB", imageData.length/1024.0);
                } else {
                    NSLog(@"imagedata is nil");
                }
    #if 1
                // if the image is bigger than 30 KB, use it as thumbnail
                //if (imageData.length/1024.0 > 40 && !gotImageURL) {
            if (imageData.length/1024.0 > 40) {
                
                    // Update the UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *tempImage = [UIImage imageWithData:imageData];
                        NSLog(@"image: width = %f, height = %f", tempImage.size.width, tempImage.size.height);
                        NSLog(@"in getMainContentImageUrl, the main image url = %@", imageSource);
                        
                        if (imageURL != nil) {
                            [self.imageUrlList replaceObjectAtIndex:index withObject:[NSString stringWithString:imageSource]];
                            [self.tableView reloadData];
                        }
                        else {
                            [self.imageUrlList replaceObjectAtIndex:index withObject:@""];
                            //[self.tableView reloadData];
                        }
                    });
                
                    gotImageURL = true;

                    break;
                }
    #else
                // got the biggest image as the thumbnail image
                if (imageData.length > maxSize) {
                    maxSize = imageData.length;
                    maxImageSource = imageSource;
                    [self.imageUrlList replaceObjectAtIndex:index withObject:[NSString stringWithString:maxImageSource]];
                    [self.tableView reloadData];
                }
    #endif
            //});

        }
        if (!gotImageURL && nodes.count != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageUrlList replaceObjectAtIndex:index withObject:[NSString stringWithString:[[nodes objectAtIndex:0] objectForKey:@"src"]]];
                [self.tableView reloadData];
            });
        }
    });
}

- (NSDictionary *) getAttributes:(NSString *) htmlTag {
    // NSLog(@"%s: %@", __FUNCTION__, htmlTag);
    NSMutableDictionary * attribs = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString * attributeString = nil;
    NSString * valueString = nil;
    
    NSScanner * linkScanner = [NSScanner scannerWithString:htmlTag];
    [linkScanner setCaseSensitive:NO];
    [linkScanner setCharactersToBeSkipped:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [linkScanner scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:nil];
    
    while([linkScanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&attributeString]) {
        if([linkScanner scanString:@"=\"" intoString:nil] && [linkScanner scanUpToString:@"\"" intoString:&valueString]) {
            [attribs setObject:valueString forKey:attributeString];
        }
        [linkScanner scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:nil];
    }
    
    return attribs;
}

#pragma mark - ImageDownloader delegate


- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    
    // 1: Check for the indexPath of the operation, whether it is a download, or filtration.
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    
    // 2: Get hold of the image instance.
    UIImage *itemImage = downloader.image;
    
    // update the pageView
    if (indexPath.row < self.scrollview.subviews.count) {
        UIImageView *currentPageView = [[self.scrollview subviews] objectAtIndex:indexPath.row];
        currentPageView.image = itemImage;
    }
    
    if (itemImage != nil) {
        // 3: Replace the updated PhotoRecord in the main data source (Photos array).
        [[self.newsItem objectAtIndex:indexPath.row] setObject:itemImage forKey:@"image"];
        
        // 4: Update UI.
        [self.tableView addSubview:self.pagecontrol];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // 5: Remove the operation from downloadsInProgress.
        [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
    }
}

#pragma mark GetMainImageFromWebpage delegage
- (void) GetMainImageDidFinish:(GetMainImageFromWebpage *)downloader {
    // 1: Check for the indexPath of the operation, whether it is a download, or filtration.
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    
    // 2: Get hold of the image instance.
    NSString *imageLink = downloader.imageLink;
    
    // 3: Replace the updated PhotoRecord in the main data source (Photos array).
    [self.imageUrlList replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithString:imageLink]];
    
    // 4: Update UI.
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // 5: Remove the operation from downloadsInProgress.
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark - Operations

// 1: To keep it simple, you pass in the link of a image that requires operations, along with its indexPath.
- (void)startOperationsForImageLink:(NSString *)imageLink atIndexPath:(NSIndexPath *)indexPath {
    
    // 2: You inspect it to see whether it has an image; if so, then ignore it.
    if ([[self.newsItem objectAtIndex:indexPath.row] objectForKey:@"image"] == [NSNull null]) {
        
        // 3: If it does not have an image, start downloading the image by calling startImageDownloadingForRecord:atIndexPath: (which will be implemented shortly). Youíll do the same for filtering operations: if the image has not yet been filtered, call startImageFiltrationForRecord:atIndexPath: (which will also be implemented shortly).
        [self startImageDownloadingForImageLink:imageLink atIndexPath:indexPath];
        
    }
}


- (void)startImageDownloadingForImageLink:(NSString *)imageLink atIndexPath:(NSIndexPath *)indexPath {
    
    // 1: First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        
        // 2: If not, create an instance of ImageDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
        // Start downloading
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageLink:imageLink atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}

- (void)startOperationForGetMainImageForHtmlContent:(NSString *)htmlContent atIndexPath:(NSIndexPath *)indexPath {
    // 2: You inspect it to see whether it has an image; if so, then ignore it.
    if ([[self.newsItem objectAtIndex:indexPath.row] objectForKey:@"image"] == [NSNull null]) {
        
        // 3: If it does not have an image, start downloading the image by calling startImageDownloadingForRecord:atIndexPath: (which will be implemented shortly). Youíll do the same for filtering operations: if the image has not yet been filtered, call startImageFiltrationForRecord:atIndexPath: (which will also be implemented shortly).
        [self startGetMainImageForHtmlContent:htmlContent atIndexPath:indexPath];
    }
    
}

- (void)startGetMainImageForHtmlContent:(NSString *)htmlContent atIndexPath:(NSIndexPath *)indexPath {
    
    // 1: First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
    if (![self.pendingOperations.getMainImageUrlInProgress.allKeys containsObject:indexPath]) {
        
        // 2: If not, create an instance of ImageDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
        // Start downloading
        GetMainImageFromWebpage *getMainImage = [[GetMainImageFromWebpage alloc] initWithHtmlContent:htmlContent atIndexPath:indexPath delegate:self];
        [self.pendingOperations.getMainImageUrlInProgress setObject:getMainImage forKey:indexPath];
        [self.pendingOperations.getMainImageUrlQueue addOperation:getMainImage];
    }
}


@end
