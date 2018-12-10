//
//  CTPageInfo.h
//  Core Text Demo
//
//  Created by Sailer on 2018/12/10.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface CTPageInfo : NSObject

@property (nonatomic,assign) CTFrameRef frame;
@property (nonatomic,strong) NSMutableArray *imgsInfo;
@property (nonatomic,assign) NSInteger length;

@end
