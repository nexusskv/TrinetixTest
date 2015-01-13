//
//  CityCustomCell.h
//  TrinetixTest
//
//  Created by rost on 12.01.15.
//  Copyright (c) 2015 Rost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityCustomCell : UITableViewCell
- (void)setCityImage:(NSString *)img;
- (void)setCity:(NSString *)title;
- (void)setStreet:(NSString *)link;
@end
