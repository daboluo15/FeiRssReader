//
//  AddURLViewController.h
//  TableAndPageview
//
//  Created by Bo Gao on 9/8/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddURLDelegate <NSObject>

@optional
- (void)didAddURL:(NSString *)webURLAddress;

-(void) haveAddViewError:(NSError *) error;
-(void) haveAddViewMessage:(NSString *) message;

@end

@interface AddURLViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (nonatomic, weak) id<AddURLDelegate> delegate;

@end
