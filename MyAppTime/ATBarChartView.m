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
    NSView *_documentView;
}

- (void)awakeFromNib {
    _barWidth = 10.0;
    _space = 10.0;
    _bottomSpace = 40.0;
    _topSpace = 40.0;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)layout {
    [super layout];
    [_scrollView setFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (instancetype)init {
    if (self = [super init]) {
        [self setUpView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self setUpView];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    _mainLayer = [CALayer layer];
    _scrollView = [[NSScrollView alloc] init];
    _scrollView.hasHorizontalScroller = YES;
    [self addSubview:_scrollView];
}

- (void)setDataSource:(id<ATBarChartViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    for (CALayer *sublayer in _mainLayer.sublayers) {
        [sublayer removeFromSuperlayer];
    }
    
    NSUInteger numberOfBars = [_dataSource numberOfBarsInBarChartView:self];
    
    if (numberOfBars) {
        CGFloat documentViewWidth = (_barWidth + _space) * (CGFloat)numberOfBars;
        CGFloat documentViewHeight = self.frame.size.height;
        [_mainLayer setFrame:CGRectMake(0, 0, documentViewWidth, documentViewHeight)];
        
        _documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, documentViewWidth, documentViewHeight)];
        [_documentView setWantsLayer:YES];
        [_documentView.layer addSublayer:_mainLayer];
        
        [_scrollView setDocumentView:_documentView];
        
        [self drawBottomLineWithXPos:0.0 yPos:_bottomSpace];
        
        for (NSUInteger i = 0; i < numberOfBars; i++) {
            [self drawEntryAtIndex:i];
        }
        
    }
}

- (void)drawEntryAtIndex:(NSUInteger)index {
    CGFloat xPos = _space + (CGFloat)index * (_barWidth + _space);
    CGFloat height = [self relativeHeightFromAbsoluteHeight:[_dataSource barChartView:self heightForBarAtIndex:index]];
    
    [self drawBarWithXPos:xPos height:height color:[_dataSource barChartView:self colorForBarAtIndex:index]];
    
    [self drawTitleWithXPos:(xPos - _space / 2) yPos:-_bottomSpace title:[_dataSource barChartView:self titleForBarAtIndex:index]];
}

- (void)drawBarWithXPos:(CGFloat)xPos height:(CGFloat)height color:(NSColor *)color {
    CALayer *barLayer = [CALayer layer];
    [barLayer setFrame:CGRectMake(xPos, _bottomSpace, _barWidth, height)];

    [barLayer setBackgroundColor:color.CGColor];
    [_mainLayer addSublayer:barLayer];
}

- (void)drawTitleWithXPos:(CGFloat)xPos yPos:(CGFloat)yPos title:(NSString *)title {
    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setFrame:CGRectMake(xPos, yPos, _barWidth + _space, 50)];
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.string = title;
    textLayer.fontSize = 20.0;
    [_mainLayer addSublayer:textLayer];
}

- (CGFloat)relativeHeightFromAbsoluteHeight:(float)height {
    CGFloat relativeHeight = 10.0;
    return relativeHeight;
}

- (void)drawBottomLineWithXPos:(CGFloat)xPos yPos:(CGFloat)yPos {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xPos, yPos)];
    [path lineToPoint:CGPointMake(_scrollView.frame.size.width, yPos)];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = path.quartzPath;
    lineLayer.lineWidth = 0.5;
    lineLayer.borderColor = [NSColor whiteColor].CGColor;
    [self.layer insertSublayer:lineLayer atIndex:0];
}

@end
