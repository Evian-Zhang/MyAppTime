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
    CGFloat _rightSpace;
    NSColor *_backgroundColor;
    NSColor *_barColor;
    NSColor *_commentColor;
    
    CALayer *_mainLayer;
    NSScrollView *_scrollView;
    NSView *_documentView;
    NSView *_yAxis;
    NSUInteger _numberOfBars;
    NSMutableArray<CALayer *> *_bars;
}

- (void)awakeFromNib {
    _barWidth = 10.0;
    _space = 10.0;
    _bottomSpace = 40.0;
    _topSpace = 20.0;
    _rightSpace = 40.0;
    _backgroundColor = [NSColor colorNamed:@"ATBackgroundColor"];
    _barColor = [NSColor colorNamed:@"ATBarColor"];
    _commentColor = [NSColor colorNamed:@"ATCommentColor"];
}

- (void)updateLayer {
    _backgroundColor = [NSColor colorNamed:@"ATBackgroundColor"];
    _barColor = [NSColor colorNamed:@"ATBarColor"];
    _commentColor = [NSColor colorNamed:@"ATCommentColor"];
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
    _scrollView.automaticallyAdjustsContentInsets = NO;
    _scrollView.autohidesScrollers = YES;
    [self addSubview:_scrollView];
    
    _bars = [NSMutableArray<CALayer *> array];
}

- (void)setDataSource:(id<ATBarChartViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    //clear all sublayers
    NSArray<CALayer *> *sublayers = [_mainLayer.sublayers copy];
    for (CALayer *sublayer in sublayers) {
        [sublayer removeFromSuperlayer];
    }
    
    _numberOfBars = [_dataSource numberOfBarsInBarChartView:self];
    
    if (_numberOfBars) {
        _barWidth = [self.dataSource widthForBarsInBarChartView:self];
        CGFloat documentViewWidth = _space + (_barWidth + _space) * (CGFloat)_numberOfBars + _rightSpace;
        CGFloat documentViewHeight = self.frame.size.height;
        
        //set frame and backgroundColor of _mainlayer
        [_mainLayer setFrame:CGRectMake(0, 0, documentViewWidth, documentViewHeight)];
        [_mainLayer setBackgroundColor:_backgroundColor.CGColor];
        
        //set _documentView
        _documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, documentViewWidth, documentViewHeight)];
        [_documentView setWantsLayer:YES];
        [_documentView.layer addSublayer:_mainLayer];
        
        //set _yAxis
        if (_yAxis && [_scrollView.subviews containsObject:_yAxis]) {
            [_yAxis removeFromSuperview];
        }
        
        _yAxis = [[NSView alloc] initWithFrame:NSMakeRect(_scrollView.frame.size.width, 0, _rightSpace, _scrollView.frame.size.height)];
        [_yAxis setWantsLayer:YES];
        _yAxis.layer.backgroundColor = _backgroundColor.CGColor;
        [self drawVerticalLine];
        
        //set _scrollView
        [_scrollView setDocumentView:_documentView];
        [_scrollView addFloatingSubview:_yAxis forAxis:NSEventGestureAxisHorizontal];
        
        //set _scrollView's contentView in case the scrollView is longer than its documentView
        [_scrollView.contentView setWantsLayer:YES];
        [_scrollView.contentView.layer setBackgroundColor:_backgroundColor.CGColor];
        
        //draw bars
        float maxHeight = [self maxHeightFrom:0 to:_numberOfBars];
        
        for (NSUInteger i = 0; i < _numberOfBars; i++) {
            [self drawEntryAtIndex:i withMaxHeight:maxHeight];
        }
        
    }
}

- (void)drawEntryAtIndex:(NSUInteger)index withMaxHeight:(float)maxHeight{
    CGFloat xPos = _space + (CGFloat)index * (_barWidth + _space);
    CGFloat height = [self relativeHeightFromAbsoluteHeight:[_dataSource barChartView:self timeUnitForBarAtIndex:index].floatValue maxHeight:maxHeight];
    
    [self drawBarWithXPos:xPos height:height];
    
    [self drawTitleWithXPos:(xPos - _space / 2) yPos:_bottomSpace - 20 title:[_dataSource barChartView:self titleForBarAtIndex:index]];
}

- (void)drawBarWithXPos:(CGFloat)xPos height:(CGFloat)height{
    CALayer *barLayer = [CALayer layer];
    [barLayer setFrame:CGRectMake(xPos, _bottomSpace, _barWidth, height)];

    [barLayer setBackgroundColor:_barColor.CGColor];
    [_mainLayer addSublayer:barLayer];
    [_bars addObject:barLayer];
}

- (void)drawTitleWithXPos:(CGFloat)xPos yPos:(CGFloat)yPos title:(NSString *)title {
    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setFrame:CGRectMake(xPos, yPos, _barWidth + _space, 15)];
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.string = title;
    textLayer.fontSize = 10.0;
    textLayer.foregroundColor = _commentColor.CGColor;
    [_mainLayer addSublayer:textLayer];
}

- (CGFloat)relativeHeightFromAbsoluteHeight:(float)height maxHeight:(float)maxHeight{
    CGFloat relativeHeight;
    if (maxHeight != 0.0) {
        relativeHeight = height / maxHeight * (self.frame.size.height - _bottomSpace - _topSpace);
    } else {
        relativeHeight = 0.0;
    }
    return relativeHeight;
}

- (void)drawBottomLineWithXPos:(CGFloat)xPos yPos:(CGFloat)yPos {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xPos, yPos)];
    [path lineToPoint:CGPointMake(_scrollView.frame.size.width, yPos)];
    [path closePath];
    [[NSColor whiteColor] setFill];
    [path fill];
    [[NSColor whiteColor] setStroke];
    [path setLineWidth:1];
    [path stroke];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = path.quartzPath;
    lineLayer.lineWidth = 3;
    lineLayer.strokeColor = [NSColor whiteColor].CGColor;
    [self setWantsLayer:YES];
    [self.layer addSublayer:lineLayer];
}

- (void)drawVerticalLine {
    NSArray<CALayer *> *sublayers = _yAxis.layer.sublayers.copy;
    for (CALayer *sublayer in sublayers) {
        [sublayer removeFromSuperlayer];
    }
    CALayer *lineLayer = [CALayer layer];
    [lineLayer setFrame:CGRectMake(0, _bottomSpace, 3, self.frame.size.height - _bottomSpace)];
    [lineLayer setBackgroundColor:_commentColor.CGColor];
    [_yAxis.layer addSublayer:lineLayer];
    
    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setFrame:CGRectMake(5, self.frame.size.height - _topSpace - 15, 30, 15)];
    textLayer.alignmentMode = kCAAlignmentLeft;
    textLayer.string = [self maxTimeUnitFrom:0 to:_numberOfBars].shortDescription;
    textLayer.fontSize = 10.0;
    textLayer.foregroundColor = _commentColor.CGColor;
    [_yAxis.layer addSublayer:textLayer];
}

- (void)reloadData {
    NSArray<CALayer *> *sublayers = [_mainLayer.sublayers copy];
    for (CALayer *sublayer in sublayers) {
        [sublayer removeFromSuperlayer];
    }
    _numberOfBars = [_dataSource numberOfBarsInBarChartView:self];
    
    if (_numberOfBars) {
        _barWidth = [self.dataSource widthForBarsInBarChartView:self];
        CGFloat documentViewWidth = _space + (_barWidth + _space) * (CGFloat)_numberOfBars + _rightSpace;
        CGFloat documentViewHeight = self.frame.size.height;
        
        [_mainLayer setFrame:CGRectMake(0, 0, documentViewWidth, documentViewHeight)];
        [_mainLayer setBackgroundColor:_backgroundColor.CGColor];
        
        _documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, documentViewWidth, documentViewHeight)];
        [_documentView setWantsLayer:YES];
        [_documentView.layer addSublayer:_mainLayer];
        
        [_scrollView setDocumentView:_documentView];
        
        if (_yAxis) {
            [_yAxis removeFromSuperview];
        }
        
        _yAxis = [[NSView alloc] initWithFrame:NSMakeRect(self.frame.size.width - _rightSpace, 0, _rightSpace, _scrollView.frame.size.height)];
        [_yAxis setWantsLayer:YES];
        _yAxis.layer.backgroundColor = _backgroundColor.CGColor;
        [_scrollView addFloatingSubview:_yAxis forAxis:NSEventGestureAxisHorizontal];
        [_scrollView.contentView setWantsLayer:YES];
        [_scrollView.contentView.layer setBackgroundColor:_backgroundColor.CGColor];
        [self drawVerticalLine];
        
        float maxHeight = [self maxHeightFrom:0 to:_numberOfBars];
        
        for (NSUInteger i = 0; i < _numberOfBars; i++) {
            [self drawEntryAtIndex:i withMaxHeight:maxHeight];
        }
        
    }
}

- (void)scrollToPoint:(NSPoint)point {
    [_scrollView.contentView scrollToPoint:point];
}

- (float)maxHeightFrom:(NSUInteger)start to:(NSUInteger)end {
    float max = 0;
    for (NSUInteger barIndex = start; barIndex < end; barIndex++) {
        float height = [_dataSource barChartView:self timeUnitForBarAtIndex:barIndex].floatValue;
        if (max < height) {
            max = height;
        }
    }
    return max;
}

- (ATTimeUnit *)maxTimeUnitFrom:(NSUInteger)start to:(NSUInteger)end {
    float max = 0;
    NSUInteger index = 0;
    for (NSUInteger barIndex = start; barIndex < end; barIndex++) {
        float height = [_dataSource barChartView:self timeUnitForBarAtIndex:barIndex].floatValue;
        if (max < height) {
            max = height;
            index = barIndex;
        }
    }
    ATTimeUnit *maxTimeUnit = [_dataSource barChartView:self timeUnitForBarAtIndex:index];
    if (maxTimeUnit.second == 0 && maxTimeUnit.minute == 0 && maxTimeUnit.hour == 0) {
        maxTimeUnit.minute = 30;
    }
    return maxTimeUnit;
}


@end
