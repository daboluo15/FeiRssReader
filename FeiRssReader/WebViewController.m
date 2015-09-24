//
//  WebViewController.m
//  TableAndPageview
//
//  Created by Bo Gao on 9/7/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (nonatomic) BOOL theBool;
@property (nonatomic) NSTimer *myTimer;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myWebView.delegate = self;

    //Create a URL object.
    NSLog(@"in webview url is %@", self.urlAddress);
    // the url must start with http:// or https://
    //NSString *urlStringWithAt = [NSString stringWithFormat:@"http://%@/",self.urlAddress];
    //NSURL *url = [NSURL URLWithString:urlStringWithAt];
    //NSURL *correctedUrl = [NSURL URLWithString:[self.urlAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    // remove the space, tab, and new line from the url
    NSString *cleanUrlAddress = [self.urlAddress stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // convert the illegal character into legal ones
    NSString *correcedURLAddress = [cleanUrlAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURL *url = [NSURL URLWithString:correcedURLAddress];
    //NSURL *url = [NSURL URLWithString:self.urlAddress];
    NSLog(@"the nsurl is %@", url);
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    //Load the request in the UIWebView.
    [self.myWebView loadRequest:requestObj];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.progressBar.progress = 0;
    self.theBool = false;
    
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.theBool = true;
}
-(void)timerCallback {
    if (self.theBool) {
        if (self.progressBar.progress >= 1) {
            self.progressBar.hidden = true;
            [self.myTimer invalidate];
        }
        else {
            self.progressBar.progress += 0.1;
        }
    }
    else {
        self.progressBar.progress += 0.05;
        if (self.progressBar.progress >= 0.95) {
            self.progressBar.progress = 0.95;
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
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
