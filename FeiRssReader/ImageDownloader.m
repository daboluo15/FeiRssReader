//
//  ImageDownloader.m
//  TableAndPageview
//
//  Created by Bo Gao on 9/21/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import "ImageDownloader.h"

@implementation ImageDownloader

#pragma mark - Life Cycle

- (id)initWithImageLink:(NSString *)imageLink atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>) theDelegate {
    
    if (self = [super init]) {
        // 2: Set the properties.
        self.delegate = theDelegate;
        self.imageLink = imageLink;
        self.indexPathInTableView = indexPath;
    }
    return self;
}

#pragma mark - Downloading image

// Regularly check for isCancelled, to make sure the operation terminates as soon as possible.
- (void)main {
    
    // 4: Apple recommends using @autoreleasepool block instead of alloc and init NSAutoreleasePool, because blocks are more efficient. You might use NSAuoreleasePool instead and that would be fine.
    @autoreleasepool {
        
        if (self.isCancelled)
            return;
        NSURL *imageURL = [NSURL URLWithString:self.imageLink];

        NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
        
        if (self.isCancelled) {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.image = downloadedImage;
            //self.photoRecord.image = downloadedImage;
        }
        else {
            //self.photoRecord.failed = YES;
        }
        
        imageData = nil;
        
        if (self.isCancelled)
            return;
        
        // 5: Cast the operation to NSObject, and notify the caller on the main thread.
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        
    }
}

@end
