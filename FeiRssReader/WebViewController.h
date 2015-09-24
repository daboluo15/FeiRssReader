//
//  WebViewController.h
//  TableAndPageview
//
//  Created by Bo Gao on 9/7/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (nonatomic) NSString *urlAddress;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@end
