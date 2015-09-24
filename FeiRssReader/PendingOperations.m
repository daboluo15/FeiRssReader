//
//  PendingOperations.m
//  TableAndPageview
//
//  Created by mahuiye on 9/21/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations

- (NSMutableDictionary *)downloadsInProgress {
    if (!_downloadsInProgress) {
        _downloadsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _downloadsInProgress;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Image Download Queue";
        _downloadQueue.maxConcurrentOperationCount = 5;
    }
    return _downloadQueue;
}

- (NSMutableDictionary *)getMainImageUrlInProgress {
    if (!_getMainImageUrlInProgress) {
        _getMainImageUrlInProgress = [[NSMutableDictionary alloc] init];
    }
    return _getMainImageUrlInProgress;
}

- (NSOperationQueue *)getMainImageUrlQueue {
    if (!_getMainImageUrlQueue) {
        _getMainImageUrlQueue = [[NSOperationQueue alloc] init];
        _getMainImageUrlQueue.name = @"Getting Main Image URL Queue";
        _getMainImageUrlQueue.maxConcurrentOperationCount = 5;
    }
    return _getMainImageUrlQueue;
}

@end
