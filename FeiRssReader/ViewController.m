//
//  ViewController.m
//  TableAndPageview
//
//  Created by Bo Gao on 9/4/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import "ViewController.h"
#import "MSCellAccessory.h"
#import "SecondTableViewController.h"
#import "AddURLViewController.h"
#import "TFHpple.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic) UIScrollView *scrollview;
@property (nonatomic) UIPageControl *pagecontrol;

@property(nonatomic) NSURL *myURLTofile;
@property(nonatomic) NSMutableArray *urlArray;
@property(nonatomic) NSArray *allImageURL;


@end

@implementation ViewController


- (void)viewDidLoad {
      [super viewDidLoad];
//    // ...
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
//    //...
//    UIPageControl *page = [[UIPageControl alloc]init];
//    page.backgroundColor = [UIColor redColor];
//    //...
//    [headerView addSubview:page];
//    self.myTableView.tableHeaderView = headerView;
//    // ...
  
#if 0
    //创建scrollview 添加内容，设置代理，将其添加到headerview中
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    self.scrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, width, 150)];
    NSLog(@"the width of the screen is %f", [[UIScreen mainScreen] bounds].size.width);
    //分页设置
    self.scrollview.pagingEnabled=YES;
    //滚动条显示设置
    self.scrollview.showsHorizontalScrollIndicator=NO;
    self.scrollview.showsVerticalScrollIndicator=NO;
    //视图内容的尺寸
    self.scrollview.contentSize=CGSizeMake(width*4, 150);
    self.myTableView.tableHeaderView= self.scrollview;
    self.scrollview.delegate=self;
    //添加内容
    float x=0;
    for (int i=1; i<=4; i++)
    {
        UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(x, 0, width, 150)];
        
        NSString *imagename=[NSString stringWithFormat:@"Image%d.jpg",i];

        UIImage *oldImage = [UIImage imageNamed:imagename];
        
        imageview.image = oldImage;


        
        [self.scrollview addSubview:imageview];
        x += width;
        
        
    }
    self.myTableView.tableHeaderView=self.scrollview;
    self.myTableView.dataSource = self;
    
    
    //创建分页控制器，添加到tableview中
    self.pagecontrol=[[UIPageControl alloc]initWithFrame:CGRectMake(200, 130, 20, 20)];
    //总得页数
    self.pagecontrol.numberOfPages=4;
    //当前显示的页数
    self.pagecontrol.currentPage=0;
    [self.myTableView addSubview:self.pagecontrol];
    
    [self setupGestureRecognizer];
#endif
    
    self.myURLTofile = [self createAndOpenURLFile];
    //self.urlArray = [[NSMutableArray alloc] init];
    self.urlArray = [NSMutableArray arrayWithContentsOfURL:self.myURLTofile];
    
    if (self.urlArray == nil) {
        self.urlArray = [[NSMutableArray alloc] init];
        [self initWithDefaultRssFeed];
    }
    
    self.title = @"FeiRssReader";
    
    //[self fetchAllImageURL:@"http://36kr.com/p/5037508.html"];
}

- (void) initWithDefaultRssFeed {
    [self.urlArray addObject:@"http://songshuhui.net/feed"];
    [self.urlArray addObject:@"http://cn.engadget.com/rss.xml"];
    [self.urlArray addObject:@"http://www.36kr.com/feed"];
    [self.urlArray addObject:@"http://engadget.com/rss.xml"];
    [self.urlArray addObject:@"http://cn.wsj.com/gb/rss02.xml"];
    [self.urlArray addObject:@"http://time.com/newsfeed/feed/"];
    [self.urlArray addObject:@"http://www.zhihu.com/rss"];
}

- (void) printAllImage {
    for (TFHppleElement *element in self.allImageURL)
    {
        NSString *src = [element objectForKey:@"src"];
        NSLog(@"img src: %@", src);
    }
}

- (void)fetchAllImageURL:(NSString *)webPageLink {
    // Load a web page.
    NSURL *URL = [NSURL URLWithString:webPageLink];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          NSString *contentType = nil;
          if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
              NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
              contentType = headers[@"Content-Type"];
          }
          
          TFHpple *parser = [TFHpple hppleWithHTMLData:data];
          
          NSString *xpathQueryString = @"//img";
          self.allImageURL = [parser searchWithXPathQuery:xpathQueryString];
          [self printAllImage];
      }]
     resume];
}

- (NSURL *)createAndOpenURLFile {
    // Get a reference to the file system
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    // URL to Documents directory
    NSURL *urlToDocumentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    // URL to a data file named 'settings.plist' in that directory
    NSURL *tempURL = [urlToDocumentsDirectory URLByAppendingPathComponent:@"url.plist"];
    
    return tempURL;
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
    self.pagecontrol.currentPage=page;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.myTableView reloadData];
}

#pragma mark - AddURLDelegate delegate methods

- (void) didAddURL:(NSString *)webURLAddress {
    NSLog(@"Add url: %@ is finished", webURLAddress);
    [self.urlArray addObject:webURLAddress];
    [self.urlArray writeToURL:self.myURLTofile atomically:YES];
    
    // remove the duplicate url from the urlArray
    NSOrderedSet *mySet = [[NSOrderedSet alloc] initWithArray:self.urlArray];
    self.urlArray = [[NSMutableArray alloc] initWithArray:[mySet array]];
    
    //NSLog(@"%@",myArray);
    
}

-(void) haveAddViewError:(NSError *) error {
    // NSLog(@"%s %@", __FUNCTION__, error);
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"URL Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void) haveAddViewMessage:(NSString *)message {
    // NSLog(@"%s %@", __FUNCTION__, message);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RSS Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.urlArray.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // test for add url from plist file
    cell.textLabel.text = [self.urlArray objectAtIndex:indexPath.row];
    //cell.textLabel.text=[NSString stringWithFormat:@"row: %ld",indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"subtitle row: %ld",indexPath.row];
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 10.0;

    CGSize itemSize = CGSizeMake(32, 32);
    UIGraphicsBeginImageContext(itemSize);
    
    UIImage *iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"rss-icon.jpg"]];
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [iconImage drawInRect:imageRect];
    
    // set round corner
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 10.0;
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [cell setNeedsLayout];

    
    // extract the domain name
    NSURL* url = [NSURL URLWithString:[self.urlArray objectAtIndex:indexPath.row]];
    NSString* domain = [url host];
    domain = [NSString stringWithFormat:@"http://%@/", domain];
    NSString *domainIcon = [NSString stringWithFormat:@"%@favicon.ico", domain];
    NSLog(@"domain icon is %@", domainIcon);
    NSURL *iconURL = [NSURL URLWithString:domainIcon];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        // Request the image
        NSData *imageData = [NSData dataWithContentsOfURL:iconURL];
        
        if (imageData != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 4. Set image in cell
                CGSize itemSize = CGSizeMake(32, 32);
                UIGraphicsBeginImageContext(itemSize);
                
                UIImage *thumbnail = [UIImage imageWithData:imageData];
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [thumbnail drawInRect:imageRect];
                
                // set round corner
                cell.imageView.layer.masksToBounds = YES;
                cell.imageView.layer.cornerRadius = 10.0;
                cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [cell setNeedsLayout];
            });
        }
    });
    
    // tintcolor is not applied to UITableViewCellAccessoryDisclosureIndicator
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.accessoryType = UITableViewCellAccessoryDetailButton;
    //cell.tintColor = [UIColor colorWithRed:178.0/255 green:34.0/255 blue:34.0/255 alpha:1.0];
    
//    // set background color of the cell
//    if (indexPath.row % 2)
//    {
//        [cell setBackgroundColor:[UIColor colorWithRed:.8 green:.8 blue:1 alpha:1]];
//    }
//    else [cell setBackgroundColor:[UIColor clearColor]];
    
#if 0
    if(indexPath.row % 6 == 0)
    {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DETAIL_DISCLOSURE colors:@[[UIColor colorWithRed:253/255.0 green:184/255.0 blue:0/255.0 alpha:1.0], [UIColor colorWithWhite:0.5 alpha:1.0]]];
            }
    else if(indexPath.row % 6 == 1)
    {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DETAIL_BUTTON color:[UIColor colorWithRed:132/255.0 green:100/255.0 blue:159/255.0 alpha:1.0]];
    }
    else if(indexPath.row % 6 == 2)
    {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor colorWithRed:0/255.0 green:166/255.0 blue:149/255.0 alpha:1.0]];
    }
    else if(indexPath.row % 6 == 3)
    {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIColor colorWithRed:0/255.0 green:123/255.0 blue:170/255.0 alpha:1.0]];
    }
    else if(indexPath.row % 6 == 4)
    {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_UNFOLD_INDICATOR color:[UIColor colorWithRed:0/255.0 green:123/255.0 blue:170/255.0 alpha:1.0]];
    }
    else if(indexPath.row % 6 == 5)
    {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_FOLD_INDICATOR color:[UIColor colorWithRed:0/255.0 green:123/255.0 blue:170/255.0 alpha:1.0]];
    }
#else
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor colorWithRed:0/255.0 green:166/255.0 blue:149/255.0 alpha:1.0]];
#endif
    
    
    
    return cell;
}


- (void)setupGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.scrollview addGestureRecognizer:tapGestureRecognizer];
    //tapGestureRecognizer.delegate = self;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"secondTableView"])
    {
        SecondTableViewController *detailedTableView = [segue destinationViewController];
        detailedTableView.pageNumber = self.pagecontrol.currentPage;

    }
    else if ([[segue identifier] isEqualToString:@"cellToTableView"])
    {
        SecondTableViewController *detailedTableView = [segue destinationViewController];
        detailedTableView.pageNumber = -1;
        detailedTableView.selectedCell = [self.myTableView indexPathForSelectedRow].row;
        detailedTableView.rssLink =  [self.urlArray objectAtIndex:[self.myTableView indexPathForSelectedRow].row];
        NSLog(@"detailedTableview.rsslink is %@", detailedTableView.rssLink);
    } else if ([[segue identifier] isEqualToString:@"AddRssFeed"]) {
        AddURLViewController *detailedTableView = [segue destinationViewController];
        detailedTableView.delegate = self;
    }
}


- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    //Code to handle the gesture
    long currentPage = self.pagecontrol.currentPage;
    NSLog(@"current page is %ld", currentPage);
    [self performSegueWithIdentifier:@"secondTableView" sender:self];
}



@end
