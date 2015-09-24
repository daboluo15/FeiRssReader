//
//  ImageDownloader.h
//  TableAndPageview
//
//  Created by Bo Gao on 9/21/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> // because we need UIImage

// Declare a delegate so that you can notify the caller once the operation is finished.
@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSOperation
@property(nonatomic) NSString *imageLink;
@property(nonatomic) UIImage *image;
@property(nonatomic) NSIndexPath *indexPathInTableView;
@property (nonatomic, weak) id <ImageDownloaderDelegate> delegate;

// Declare a designated initializer.
- (id)initWithImageLink:(NSString *)imageLink atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>) theDelegate;

@end

@protocol ImageDownloaderDelegate <NSObject>
// In your delegate method, pass the whole class as an object back to the caller so that the caller can access both indexPathInTableView and photoRecord. Because you need to cast the operation to NSObject and return it on the main thread, the delegate method canít have more than one argument.
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;
@end
