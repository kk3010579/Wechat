//
//  TableViewCell.m
//  Wechat
//
//  Created by Day on 14-5-27.
//  Copyright (c) 2014年 Day. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)dealloc {
    [_cellBackImage release];
    [_cellLabel release];
    [_head release];
    [super dealloc];
}
@end
