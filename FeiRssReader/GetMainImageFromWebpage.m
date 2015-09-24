//
//  GetMainImageFromWebpage.m
//  TableAndPageview
//
//  Created by Bo Gao on 9/23/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import "GetMainImageFromWebpage.h"
#import "TFHpple.h"

@implementation GetMainImageFromWebpage

#pragma mark - Life Cycle
- (id)initWithHtmlContent:(NSString *)htmlContent atIndexPath:(NSIndexPath *)indexPath delegate:(id<GetMainImageFromWebpageDelegate>)theDelegate{
    
    if (self = [super init]) {
        // 2: Set the properties.
        self.delegate = theDelegate;
        self.htmlContent = htmlContent;
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
        
        NSData *data = [self.htmlContent dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *parser = [TFHpple hppleWithHTMLData:data];
        
        if (self.isCancelled)
            return;
        
        NSString *xpathQueryString = @"//img";
        NSArray *nodes = [parser searchWithXPathQuery:xpathQueryString];
        
        if (self.isCancelled)
            return;
        
        BOOL gotImageURL = false;

        for (TFHppleElement *element in nodes)
        {
            if (self.isCancelled)
                return;
            
            NSString *imageSource = [element objectForKey:@"src"];
            self.imageLink = imageSource;
            
            NSURL *imageURL = [NSURL URLWithString:imageSource];
            
            NSLog(@"in dispatch, imageurl = %@", imageSource);
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            
            if (self.isCancelled) {
                imageData = nil;
                return;
            }
            
            
            // the size > 10k
            if (imageData != nil) {
                NSLog(@"imagedata.length = %f KB", imageData.length/1024.0);
            } else {
                NSLog(@"imagedata is nil");
            }
            
            // if the image is bigger than 40 KB, use it as thumbnail
            //if (imageData.length/1024.0 > 40 && !gotImageURL) {
            if (imageData.length/1024.0 > 40) {
                
                // Update the UI
                if (self.isCancelled)
                    return;
               
                UIImage *tempImage = [UIImage imageWithData:imageData];
                NSLog(@"image: width = %f, height = %f", tempImage.size.width, tempImage.size.height);
                NSLog(@"in getMainContentImageUrl, the main image url = %@", imageSource);
                
                if (imageURL != nil) {
                    self.imageLink = imageSource;
                }
                else {
                    self.imageLink = @"";
                }
                
                // 5: Cast the operation to NSObject, and notify the caller on the main thread.
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(GetMainImageDidFinish:) withObject:self waitUntilDone:NO];

                gotImageURL = true;
                
                break;
            }
            
        }
        
        if (self.isCancelled)
            return;
        if (!gotImageURL && nodes.count != 0) {
            // 5: Cast the operation to NSObject, and notify the caller on the main thread.
            self.imageLink = [[nodes objectAtIndex:0] objectForKey:@"src"];
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(GetMainImageDidFinish:) withObject:self waitUntilDone:NO];
        }
    }
}

@end
