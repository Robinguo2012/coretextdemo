//
//  ViewController.m
//  Core Text Demo
//
//  Created by Sailer on 2018/12/2.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import "ViewController.h"
#import "ParagraphView.h"
#import "SimpleTextView.h"
#import "ColumnarTextView.h"
#import "ManualBreaklineView.h"
#import "ParagraphStyleView.h"
#import "NORectangularView.h"

#import "ImageTextViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    ParagraphView *paraView = [ParagraphView new];
    paraView.frame = CGRectMake(0, 40, self.view.bounds.size.width, 40);
    [self.view addSubview:paraView];
    
    SimpleTextView *sT = [SimpleTextView new];
    sT.frame = CGRectMake(0, 90, self.view.bounds.size.width
                          , 30);
    [self.view addSubview:sT];
    
    // But when I try my best to do what  I have scheduled, it's look like that it far away from me
    ColumnarTextView *cTextView = [ColumnarTextView new];
    NSString *text = @"I want be successful and I have no way to it.Sometimes I think is simple thing, just a little jump I can hold it.";
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text];
    cTextView.attributeString = attrString;
    cTextView.frame = CGRectMake(0, 150, 120, 100);
    [self.view addSubview:cTextView];
    
    ManualBreaklineView *mView = [ManualBreaklineView new];
    mView.frame = CGRectMake(0, 260, self.view.bounds.size.width, 60);
    mView.attributeString = attrString;
    [self.view addSubview:mView];
    
    ParagraphStyleView *paraStyleView = [ParagraphStyleView new];
    paraStyleView.frame = CGRectMake(0, 330, self.view.bounds.size.width, 150);
    [self.view addSubview:paraStyleView];
    
    NORectangularView *noRectangular = [NORectangularView new];
    noRectangular.frame = CGRectMake(0, 490, self.view.bounds.size.width/2, 200);
    [self.view addSubview:noRectangular];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [noRectangular addGestureRecognizer:tap];
    
    /**
     Next Step:
     1.Attachment(image)
     2.Event handle for coretext.
     */
    
}


- (void)handleTap {
    ImageTextViewController *imgVC = [ImageTextViewController new];
    [self.navigationController pushViewController:imgVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
