//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2016 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSSelectPhotoCollectionViewCell.h"
#import "BBSApiBaseViewController.h"

@interface BBSShortCutCreateNewThreadViewController : BBSApiBaseViewController

@property(weak, nonatomic) IBOutlet UITextField *subject;

@property(weak, nonatomic) IBOutlet UITextView *message;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak, nonatomic) IBOutlet UITextField *createWhichForum;

- (IBAction)createThread:(id)sender;

- (IBAction)back:(id)sender;

- (IBAction)pickPhoto:(id)sender;

- (IBAction)showAllForums:(id)sender;

@property(weak, nonatomic) IBOutlet UICollectionView *selectPhotos;

- (IBAction)showCategory:(UIButton *)sender;

@end
