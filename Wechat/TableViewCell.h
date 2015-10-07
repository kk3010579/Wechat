//
//  TableViewCell.h
//  Wechat
//
//  Created by Day on 14-5-27.
//  Copyright (c) 2014年 Day. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *cellBackImage;
@property (retain, nonatomic) IBOutlet UILabel *cellLabel;
@property (retain, nonatomic) IBOutlet UIImageView *head;

@end
