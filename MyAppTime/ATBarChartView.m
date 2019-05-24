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
    _topSpace = 40.0;
    _rightSpace = 40.0;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidEndLiveScroll) name:NSScrollViewDidEndLiveScrollNotification object:nil];
}

- (void)setDataSource:(id<ATBarChartViewDataSource>)dataSource {
    _dataSource = dataSource;
    NSArray<CALayer *> *sublayers = [_mainLayer.sublayers copy];
    for (CALayer *sublayer in sublayers) {
        [sublayer removeFromSuperlayer];
    }
    
    _numberOfBars = [_dataSource numberOfBarsInBarChartView:self];
    
    if (_numberOfBars) {
        CGFloat documentViewWidth = _space + (_barWidth + _space) * (CGFloat)_numberOfBars + _rightSpace;
        CGFloat documentViewHeight = self.frame.size.height;
        
        [_mainLayer setFrame:CGRectMake(0, 0, documentViewWidth, documentViewHeight)];
        
        _documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, documentViewWidth, documentViewHeight)];
        [_documentView setWantsLayer:YES];
        [_documentView.layer addSublayer:_mainLayer];
        
        [_scrollView setDocumentView:_documentView];
        
        if (_yAxis && [_scrollView.subviews containsObject:_yAxis]) {
            [_yAxis removeFromSuperview];
        }
        
        _yAxis = [[NSView alloc] initWithFrame:NSMakeRect(_scrollView.frame.size.width, 0, _rightSpace, _scrollView.frame.size.height)];
        [_yAxis setWantsLayer:YES];
        _yAxis.layer.backgroundColor = [NSColor blueColor].CGColor;
        [_scrollView addFloatingSubview:_yAxis forAxis:NSEventGestureAxisHorizontal];
        
//        [self drawBottomLineWithXPos:0.0 yPos:_bottomSpace];
        
        float maxHeight = [self maxHeightFrom:0 to:_numberOfBars];
        
        for (NSUInteger i = 0; i < _numberOfBars; i++) {
            [self drawEntryAtIndex:i withMaxHeight:maxHeight];
        }
        
    }
}

- (void)drawEntryAtIndex:(NSUInteger)index withMaxHeight:(float)maxHeight{
    CGFloat xPos = _space + (CGFloat)index * (_barWidth + _space);
    CGFloat height = [self relativeHeightFromAbsoluteHeight:[_dataSource barChartView:self timeUnitForBarAtIndex:index].floatValue maxHeight:maxHeight];
    
    [self drawBarWithXPos:xPos height:height color:[_dataSource barChartView:self colorForBarAtIndex:index]];
    
    [self drawTitleWithXPos:(xPos - _space / 2) yPos:_bottomSpace - 20 title:[_dataSource barChartView:self titleForBarAtIndex:index]];
}

- (void)drawBarWithXPos:(CGFloat)xPos height:(CGFloat)height color:(NSColor *)color {
    CALayer *barLayer = [CALayer layer];
    [barLayer setFrame:CGRectMake(xPos, _bottomSpace, _barWidth, height)];

    [barLayer setBackgroundColor:color.CGColor];
    [_mainLayer addSublayer:barLayer];
    [_bars addObject:barLayer];
}

- (void)drawTitleWithXPos:(CGFloat)xPos yPos:(CGFloat)yPos title:(NSString *)title {
    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setFrame:CGRectMake(xPos, yPos, _barWidth + _space, 15)];
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.string = title;
    textLayer.fontSize = 10.0;
    [_mainLayer addSublayer:textLayer];
}

- (CGFloat)relativeHeightFromAbsoluteHeight:(float)height maxHeight:(float)maxHeight{
    CGFloat relativeHeight;
    if (maxHeight != 0.0) {
        relativeHeight = height / maxHeight * (self.frame.size.height - _bottomSpace);
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
    [lineLayer setBackgroundColor:[NSColor whiteColor].CGColor];
    [_yAxis.layer addSublayer:lineLayer];
    
    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setFrame:CGRectMake(5, self.frame.size.height - 15, 30, 15)];
    textLayer.alignmentMode = kCAAlignmentLeft;
    textLayer.string = [self maxTimeUnitFrom:0 to:_numberOfBars].description;
    textLayer.fontSize = 10.0;
    [_yAxis.layer addSublayer:textLayer];
}

- (void)reloadData {
    NSArray<CALayer *> *sublayers = [_mainLayer.sublayers copy];
    for (CALayer *sublayer in sublayers) {
        [sublayer removeFromSuperlayer];
    }
    _numberOfBars = [_dataSource numberOfBarsInBarChartView:self];
    
    if (_numberOfBars) {
        CGFloat documentViewWidth = _space + (_barWidth + _space) * (CGFloat)_numberOfBars + _rightSpace;
        CGFloat documentViewHeight = self.frame.size.height;
        
        [_mainLayer setFrame:CGRectMake(0, 0, documentViewWidth, documentViewHeight)];
        
        _documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, documentViewWidth, documentViewHeight)];
        [_documentView setWantsLayer:YES];
        [_documentView.layer addSublayer:_mainLayer];
        
        [_scrollView setDocumentView:_documentView];
        
        if (_yAxis) {
            [_yAxis removeFromSuperview];
        }
        
        _yAxis = [[NSView alloc] initWithFrame:NSMakeRect(self.frame.size.width - _rightSpace, 0, _rightSpace, _scrollView.frame.size.height)];
        [_yAxis setWantsLayer:YES];
        _yAxis.layer.backgroundColor = [NSColor blueColor].CGColor;
        [_scrollView addFloatingSubview:_yAxis forAxis:NSEventGestureAxisHorizontal];
        [self drawVerticalLine];
        //        [self drawBottomLineWithXPos:0.0 yPos:_bottomSpace];
        
        float maxHeight = [self maxHeightFrom:0 to:_numberOfBars];
        
        for (NSUInteger i = 0; i < _numberOfBars; i++) {
            [self drawEntryAtIndex:i withMaxHeight:maxHeight];
        }
        
    }
}

- (void)scrollToPoint:(NSPoint)point {
    [_scrollView.contentView scrollToPoint:point];
}

- (void)scrollViewDidEndLiveScroll {
    NSRect documentVisibleRect = _scrollView.documentVisibleRect;
    NSUInteger leftBarIndex = floor(documentVisibleRect.origin.x / (_space + _barWidth));
    NSUInteger rightBarIndex = fmin(ceil((documentVisibleRect.origin.x + documentVisibleRect.size.width) / (_space + _barWidth)), _numberOfBars - 1);
    
    float maxHeight = [self maxHeightFrom:leftBarIndex to:rightBarIndex];
    
    
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
    int index = 0;
    for (NSUInteger barIndex = start; barIndex < end; barIndex++) {
        float height = [_dataSource barChartView:self timeUnitForBarAtIndex:barIndex].floatValue;
        if (max < height) {
            max = height;
            index = barIndex;
        }
    }
    return [_dataSource barChartView:self timeUnitForBarAtIndex:index];
}


@end
