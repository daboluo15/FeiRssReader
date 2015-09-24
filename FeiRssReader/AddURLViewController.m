//
//  AddURLViewController.m
//  TableAndPageview
//
//  Created by Bo Gao on 9/8/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import "AddURLViewController.h"

// min and max size of NSURLConnection pages
static const NSUInteger minPageSize = 64;
static const NSUInteger maxPageSize = 10240;

// RSS MIME-type suffix
static NSString * const kRSSMIMESuffix = @"xml";

// rssRecord keys
static NSString * const kTitleKey = @"title";
static NSString * const kDescriptionKey = @"desc";
static NSString * const kUrlKey = @"url";

// RSS element names
static NSString * const kTitleElementName = @"title";
static NSString * const kDescriptionElementName = @"description";
static NSString * const kItemElementName = @"item";


@interface AddURLViewController ()
@property(nonatomic) NSString *urlString;
enum {
    BWRSSStateDiscovery = 1,
    BWRSSStateParseHeader
};
@property(nonatomic)NSInteger bwrssState;   // used for NSConnection
@property(nonatomic)NSMutableData * _xmlData;
@property(nonatomic)NSString * _currentElement;
@property(nonatomic)NSMutableDictionary * _feedRecord;
@property(nonatomic)NSURLConnection * _feedConnection;
@property(nonatomic)BOOL didFinishParsing;
@property(nonatomic)BOOL didReturnFeed;
@property(nonatomic)BOOL haveTitle;
@property(nonatomic)BOOL haveDescripton;

@property (nonatomic, weak) NSString *feedURL;
@property (nonatomic, weak) NSString *feedHost;

@end

@implementation AddURLViewController
//- (IBAction)addAction:(id)sender {
//    self.urlString = self.urlTextField.text;
//    NSLog(@"your input is %@", self.urlString);
//    [self.delegate didAddURL:self.urlString];
//    [self dismissViewControllerAnimated:YES completion:nil ];
//    
//}

// strip leading and trailing characters
// returns new string
NSString * trimString ( NSString * string ) {
    return [string stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (IBAction)addAction:(id)sender {
      self.urlString = self.urlTextField.text;
//    NSLog(@"your input is %@", self.urlString);
//    [self.delegate didAddURL:self.urlString];
//    [self dismissViewControllerAnimated:YES completion:nil ];
    [self getRSSFeed:trimString(self.urlString)];
    //[self getRSSFeed:self.urlString];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil ];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.urlTextField becomeFirstResponder];
    self.urlTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.urlTextField) {
        [textField resignFirstResponder];
        [self addAction:nil];
        return NO;
    }
    return YES;
}

#pragma mark - RSS Feed Management

- (void) getRSSFeed:(NSString *) url {
    NSLog(@"%s with url %@", __FUNCTION__, url);
    
    if ([url length] < 1) return;  // don't bother with empty string
    if (!([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])) {
        url = [@"http://" stringByAppendingString:url];
    }
    
    [self fetchURL:url withState:BWRSSStateDiscovery];
}

- (void) fetchURL:(NSString *) url withState:(BOOL) urlState {
    NSLog(@"%s %@ %d", __FUNCTION__, url, urlState);
    
    if ([url length] < 1) return;  // don't bother with empty string
    
    // the returned url is in form of //www.engadget.com/rss.xml, so we need to remove the first two //
    if ([url characterAtIndex:0] == '/' && [url characterAtIndex:1] == '/') {
        url = [url substringFromIndex:2];
        NSLog(@"the new url is %@", url);
    }
    if (!([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])) {
        url = [@"http://" stringByAppendingString:url];
    }

    NSLog(@"%s %@ %d", __FUNCTION__, url, urlState);
    self.bwrssState = urlState;
    self._xmlData = [NSMutableData dataWithCapacity:0];
    //[self statusMessage:@"Requesting %@", url];
    NSURLRequest *rssURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    self._feedConnection = [[NSURLConnection alloc] initWithRequest:rssURLRequest delegate:self];
    NSAssert(self._feedConnection != nil, @"Could not create xmlConnection");
}

// findFeedURL
// callback from connectionDidFinishLoading
// find a feed URL in an HTML page
- (void) findFeedURL {
    NSLog(@"%s, data length: %lu", __FUNCTION__, (unsigned long)[self._xmlData length]);
    if ([self._xmlData length] < minPageSize) {
        [self errorAlert:@"Page is empty."];
        return;
    }
    
    // web pages can be huge. we havd no use for more than maxPageSize bytes
    NSUInteger len = [self._xmlData length];
    if (len > maxPageSize) len = maxPageSize;
    
    NSString * pageString = [[NSString alloc] initWithBytesNoCopy: (void *)[self._xmlData bytes]
                                                           length:len encoding:NSUTF8StringEncoding freeWhenDone:NO];
    NSDictionary * rssLink = [self rssLinkFromHTML:pageString];
    
    [self._xmlData setLength:0];
    
    if (rssLink) {
        [self fetchURL:[rssLink objectForKey:@"href"] withState:BWRSSStateParseHeader];
    } else {
        [self errorAlert:@"Did not find a feed."];
    }
}

- (void)errorAlert:(NSString *) message {
    // NSLog(@"%s", __FUNCTION__);
    [self.delegate haveAddViewMessage:message];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//- (void) haveFeed {
//    // NSLog(@"%s", __FUNCTION__);
//    // default values
//    if (!_feedRecord[kTitleElementName]) _feedRecord[kTitleElementName] = self.feedHost;
//    if (!_feedRecord[kDescriptionElementName]) _feedRecord[kDescriptionElementName] = @"";
//    
//    _feedRecord[kTitleKey] = trimString(flattenHTML(_feedRecord[kTitleElementName]));
//    _feedRecord[kDescriptionKey] = trimString(flattenHTML(_feedRecord[kDescriptionElementName]));
//    [_feedRecord removeObjectForKey:kDescriptionElementName];	 // not a database column
//    
//    [self statusMessage:@"Have feed: %@", _feedRecord[kTitleKey]];
//    [self.delegate haveAddViewRecord:_feedRecord];
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark -
#pragma mark RSS discovery methods

- (NSDictionary *) rssLinkFromHTML:(NSString *) htmlString {
    NSLog(@"%s: htmlString %ld bytes", __FUNCTION__, [htmlString length]);
    NSDictionary * rssLink = nil;
    
    // set up the string scanner
    NSScanner * pageScanner = [NSScanner scannerWithString:htmlString];
    [pageScanner setCaseSensitive:NO];
    [pageScanner setCharactersToBeSkipped:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    while ([pageScanner scanUpToString:@"<link " intoString:nil]) {
        NSString * linkString = nil;
        if ([pageScanner scanUpToString:@">" intoString:&linkString]) {
            rssLink = [self getAttributes:linkString];
            NSString * attRel = [rssLink valueForKey:@"rel"];
            NSString * attType = [rssLink valueForKey:@"type"];
            if (attRel && attType &&
                [attRel caseInsensitiveCompare:@"alternate"] == NSOrderedSame &&
                ( [attType caseInsensitiveCompare:@"application/rss+xml"] == NSOrderedSame ||
                 [attType caseInsensitiveCompare:@"application/atom+xml"] == NSOrderedSame ) ) {
                    break;
                } else {
                    rssLink = nil;
                }
            
        }
    }
    if (rssLink && ![rssLink valueForKey:@"href"]) rssLink = nil;
    return rssLink;
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


#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
     NSLog(@"%s %@", __FUNCTION__, [response MIMEType]);
    //[self statusMessage:@"Connected to %@", [response URL]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (self.bwrssState == BWRSSStateDiscovery && [[response MIMEType] hasSuffix:kRSSMIMESuffix]) {
        NSLog(@"MIME-type is RSS feed (%@) -- updating bwrssState", [response MIMEType]);
        self.bwrssState = BWRSSStateParseHeader;
    }
    if (self.bwrssState == BWRSSStateParseHeader) {
        self.feedURL = [[response URL] absoluteString];
        self.feedHost = [[response URL] host];
        
        NSLog(@"Have feed: %@", self.feedURL);
        [self.delegate didAddURL:self.feedURL];
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    if ([self._xmlData length]) [self._xmlData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // NSLog(@"%s (length: %d)", __FUNCTION__, [data length]);
    if ( (self.bwrssState == BWRSSStateDiscovery) && ([self._xmlData length] > maxPageSize) ) {
        [connection cancel];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self findFeedURL];
    } else {
        [self._xmlData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // NSLog(@"%s", __FUNCTION__);
    self._feedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    switch (self.bwrssState) {
        case BWRSSStateDiscovery:
            [self findFeedURL];
            break;
        case BWRSSStateParseHeader:
            //[self statusMessage:@"Have RSS feed header (%d bytes)", _xmlData.length];
            NSLog(@"Have RSS feed header %d bytes", self._xmlData.length);
            //[self parseRSSHeader];
            break;
        default:
            NSAssert(0, @"invalid bwrssState");
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(
                                                                                      @"No Connection Error",
                                                                                      @"Not connected to the Internet.") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleURLError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleURLError:error];
    }
    self._feedConnection = nil;
}

#pragma mark - Error handling

- (void)handleURLError:(NSError *)error {
    // NSLog(@"%s", __FUNCTION__);
    [self.delegate haveAddViewError:error];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
