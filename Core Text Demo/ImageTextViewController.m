//
//  ImageTextViewController.m
//  Core Text Demo
//
//  Created by Sailer on 2018/12/10.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import "ImageTextViewController.h"
#import "RichImageView.h"
#import <UIView+LayoutMethods.h>

@interface ImageTextViewController ()

@end

@implementation ImageTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RichImageView *richText = [[RichImageView alloc] init];
    richText.frame = CGRectMake(0, 100, self.view.ct_width, 400);
    [self.view addSubview:richText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
