//
//  CTPageInfo.m
//  Core Text Demo
//
//  Created by Sailer on 2018/12/10.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import "CTPageInfo.h"

@implementation CTPageInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imgsInfo = @[].mutableCopy;
    }
    return self;
}
@end
