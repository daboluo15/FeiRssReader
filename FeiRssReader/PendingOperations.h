//
//  PendingOperations.h
//  TableAndPageview
//
//  Created by mahuiye on 9/21/15.
//  Copyright (c) 2015 Bo Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject

@property(nonatomic) NSMutableDictionary *downloadsInProgress;
@property(nonatomic) NSOperationQueue *downloadQueue;

@property (nonatomic, strong) NSMutableDictionary *getMainImageUrlInProgress;
@property (nonatomic, strong) NSOperationQueue *getMainImageUrlQueue;

@end
