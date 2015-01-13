//
//  DataLoader.m
//  TrinetixTest
//
//  Created by rost on 12.01.15.
//  Copyright (c) 2015 Rost. All rights reserved.
//

#import "DataLoader.h"
#import "AFHTTPRequestOperation.h"
#import "DataFetcher.h"


@implementation DataLoader


#pragma mark - initWithCallback:
- (id)initWithCallback:(LoadDataCallback)block
{
    if (self = [super init])
        self.callbackBlock = block;
    
    return self;
}
#pragma mark -


#pragma mark - loadData
- (void)loadData {
    NSURL *requestUrl = [NSURL URLWithString:@"http://public.trinetix.net/test.json"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:requestUrl]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([responseArray count] > 0) {
            [[DataFetcher shared] saveCities:responseArray];
            
            self.callbackBlock(@YES);
            
        } else {
            NSLog(@"Response is empty");
            self.callbackBlock(@NO);
        }
            
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request error: %@", error.description);
        self.callbackBlock(@NO);
    }];
    [operation start];
}
#pragma mark -

@end
