//
//  ForumSimpleThreadTableViewCell.m
//  CCF
//
//  Created by WDY on 16/3/17.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSimpleThreadTableViewCell.h"

@implementation ForumSimpleThreadTableViewCell {
    NSIndexPath *selectIndexPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(SimpleThread *)data {
    NSString *title = [NSString stringWithFormat:@"[%@]%@", data.threadCategory, data.threadTitle];
    self.threadTitle.text = title;
    self.threadAuthorName.text = data.threadAuthorName;
    self.lastPostTime.text = data.lastPostTime;
    self.threadCategory.text = data.threadCategory;

    [self showAvatar:self.ThreadAuthorAvatar userId:data.threadAuthorID];
}

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {
    selectIndexPath = indexPath;
    [self setData:data];
}

- (void)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:selectIndexPath];
}

@end