//
//  CityCustomCell.m
//  TrinetixTest
//
//  Created by rost on 12.01.15.
//  Copyright (c) 2015 Rost. All rights reserved.
//

#import "CityCustomCell.h"
#import "UIImageView+AFNetworking.h"


@interface CityCustomCell ()
@property (nonatomic, strong) UIImageView *cityImgView;
@property (nonatomic, strong) UILabel *cityLbl;
@property (nonatomic, strong) UILabel *streetLbl;
@end


@implementation CityCustomCell

#pragma mark - Constructor
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.cityImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 50.0f, 50.0f)];
        [self addSubview:self.cityImgView];
        
        self.cityLbl = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 10.0f, self.bounds.size.width - 110.0f, 20.0f)];
        self.cityLbl.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:self.cityLbl];
        
        self.streetLbl = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 35.0f, self.bounds.size.width - 110.0f, 15.0f)];
        self.streetLbl.font = [UIFont boldSystemFontOfSize:13];
        self.streetLbl.textColor = [UIColor blueColor];
        [self addSubview:self.streetLbl];
    }
    
    return self;
}
#pragma mark -


#pragma mark - Setters
- (void)setCityImage:(NSString *)img {
    if ((img) && ([img componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]]))
        [self.cityImgView setImageWithURL:[NSURL URLWithString:img]];
}

- (void)setCity:(NSString *)title {
    if ((title) && ([title componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]]))
        self.cityLbl.text = title;
}

- (void)setStreet:(NSString *)street {
    if ((street) && ([street componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]]))
        self.streetLbl.text = street;
}
#pragma mark -

@end
