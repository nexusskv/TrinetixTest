//
//  DataLoader.h
//  TrinetixTest
//
//  Created by rost on 12.01.15.
//  Copyright (c) 2015 Rost. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LoadDataCallback)(id);


@interface DataLoader : NSObject

@property (nonatomic, copy) LoadDataCallback callbackBlock;

- (id)initWithCallback:(LoadDataCallback)block;
- (void)loadData;

@end
