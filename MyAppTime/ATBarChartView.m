//
//  ATBarChartView.m
//  MyAppTime
//
//  Created by Evian张 on 2019/3/27.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "ATBarChartView.h"

@implementation ATBarChartView {
    CGFloat _barWidth;
    CGFloat _space;
    CGFloat _bottomSpace;
    CGFloat _topSpace;
    CALayer *_mainLayer;
    NSScrollView *_scrollView;
}

- (void)awakeFromNib {
    _barWidth = 40.0;
    _space = 20.0;
    _bottomSpace = 40.0;
    _topSpace = 40.0;
    _mainLayer = [CALayer layer];
//    _scrollView = [NSScrollView ]
    _scrollView = [[NSScrollView alloc] init];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)buildFrame {
    for (CALayer *sublayer in _mainLayer.sublayers) {
        [sublayer removeFromSuperlayer];
    }
    
    NSUInteger numberOfBars = [self.dataSource numberOfBarsInBarChartView:self];
    
    if (numberOfBars) {
        CGFloat scrollViewWidth = (_barWidth + _space) * (CGFloat)numberOfBars;
        CGFloat scrollViewHeight = self.frame.size.height;
        [_scrollView.documentView setFrame:NSMakeRect(0, 0, scrollViewWidth, scrollViewHeight)];
        [_mainLayer setFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
        
        
        for (NSUInteger i = 0; i < numberOfBars; i++) {
            [self drawEntryAtIndex:i];
        }
    }
}

- (void)drawEntryAtIndex:(NSUInteger)index {
    CGFloat xPos = _space + (CGFloat)index * (_barWidth + _space);
    CGFloat yPos = [self translateToYPosFromHeightValue:[self.dataSource barChartView:self heightForBarAtIndex:index]];
    
    [self drawBarWithXPos:xPos yPos:yPos color:[self.dataSource barChartView:self colorForBarAtIndex:index]];
    
    [self drawTitleWithXPos:(xPos - _space / 2) yPos:(yPos - 30) title:[self.dataSource barChartView:self titleForBarAtIndex:index]];
}

- (void)drawBarWithXPos:(CGFloat)xPos yPos:(CGFloat)yPos color:(NSColor *)color {
    CALayer *barLayer = [CALayer layer];
    [barLayer setFrame:CGRectMake(xPos, yPos, _barWidth, _mainLayer.frame.size.height - _bottomSpace - yPos)];
    [barLayer setBackgroundColor:color.CGColor];
    [_mainLayer addSublayer:barLayer];
}

- (void)drawTitleWithXPos:(CGFloat)xPos yPos:(CGFloat)yPos title:(NSString *)title {
    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setFrame:CGRectMake(xPos, yPos, _barWidth + _space, 22)];
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.string = title;
    [_mainLayer addSublayer:textLayer];
}

- (CGFloat)translateToYPosFromHeightValue:(float)height {
    CGFloat yPos = 0.0;
    return yPos;
}

@end
