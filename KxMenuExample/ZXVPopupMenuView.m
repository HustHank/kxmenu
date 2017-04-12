//
//  ZXVPopupMenu.m
//  USeeTV
//
//  Created by admin on 2017/4/10.
//  Copyright © 2017年 ZTE. All rights reserved.
//

#import "ZXVPopupMenuView.h"

#pragma mark - ZXVpopupItem

@interface ZXVPopupItem ()

/// 回调 callBack
@property (copy, readwrite, nonatomic) ZXVDropMenuCallBack callBack;
/// title
@property (copy, readwrite, nonatomic) NSString *title;
/// icon
@property (strong, readwrite, nonatomic) UIImage *iconImage;
/// target
@property (weak, readwrite, nonatomic) id target;
/// action
@property (readwrite, nonatomic) SEL action;

@end

@implementation ZXVPopupItem

+ (instancetype)itemWithTitle:(NSString *)title
                    iconImage:(UIImage *)iconImage
                     callBack:(ZXVDropMenuCallBack)callBack {
    ZXVPopupItem *item = [[ZXVPopupItem alloc] init];
    item.title = title;
    item.iconImage = iconImage;
    item.callBack = callBack;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title
                    iconImage:(UIImage *)iconImage
                       target:(id)target
                       action:(SEL)action {
    ZXVPopupItem *item = [[ZXVPopupItem alloc] init];
    item.title = title;
    item.iconImage = iconImage;
    item.target = target;
    item.action = action;
    return item;
}

@end

#pragma mark - ZXVPopupMenuTableViewCell

@interface ZXVPopupMenuTableViewCell : UITableViewCell

@end

@implementation ZXVPopupMenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:13.f];
        self.textLabel.textColor = [UIColor darkGrayColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.imageView) {
        self.imageView.frame = CGRectMake(10, CGRectGetMinY(self.imageView.frame), CGRectGetWidth(self.imageView.frame), CGRectGetHeight(self.imageView.frame));
        self.textLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    self.textLabel.frame = CGRectMake(
                                      CGRectGetMaxX(self.imageView.frame) + 5,
                                      CGRectGetMinY(self.textLabel.frame),
                                      CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(self.imageView.frame) - 10,
                                      CGRectGetHeight(self.textLabel.frame));
}

@end

#pragma mark - ZXVPopupMenu

static NSString * const kCellIdentifier = @"ZXVPopupMenuViewCell";
static const CGFloat kCellWidth = 120.f;
static const CGFloat kCellHeight = 44.f;
static const CGFloat kArrowSize = 5.f;
static const CGFloat kCornerRadius = 3.f;
static const CGFloat kLeftCellSeparatorDistance = 10.f;

@interface ZXVPopupMenuView ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, copy) NSArray<ZXVPopupItem *> *menuItems;
@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, assign) CGFloat arrowPosition;

@end

@implementation ZXVPopupMenuView

+ (void)showMenuFromRect:(CGRect)rect
               menuItems:(NSArray<ZXVPopupItem *> *)menuItems {
    [[[ZXVPopupMenuView alloc] init] showMenuFromRect:rect menuItems:menuItems];
    
}

- (void)showMenuFromRect:(CGRect)rect
               menuItems:(NSArray<ZXVPopupItem *> *)menuItems {
    self.menuItems = menuItems;
    [self setupViewWithRect:rect menuCount:menuItems.count];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {

    }];
}

- (void)dismissMenu:(BOOL)animated {
    if (self.superview) {
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^(void) {
                self.alpha = 0.f;
    
            } completion:^(BOOL finished) {
                [self.superview removeFromSuperview];
                [self removeFromSuperview];
            }];
            
        } else {
            [self.superview removeFromSuperview];
            [self removeFromSuperview];
        }
    }
}

- (void)commonInit {
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(2, 2);
    
    UIView *keyWindow = [[UIApplication sharedApplication] keyWindow];
    //灰色蒙板
    UIControl *blackOverlay = [[UIControl alloc] initWithFrame:keyWindow.bounds];
    blackOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4f];
    [blackOverlay addTarget:self action:@selector(dismissMenu:) forControlEvents:UIControlEventTouchUpInside];
    //最终加到keywindow上
    [keyWindow addSubview:blackOverlay];
    [blackOverlay addSubview:self];
    //tableView
    [self addSubview:self.menuTableView];
}

- (void)setupViewWithRect:(CGRect)rect menuCount:(NSUInteger)menuCount {
    
    [self commonInit];

    UIView *keyWindow = [[UIApplication sharedApplication] keyWindow];
    const CGFloat outerWidth = CGRectGetWidth(keyWindow.frame);
    const CGFloat rectMidX = CGRectGetMidX(rect);
    const CGFloat rectMaxY = CGRectGetMaxY(rect) - kArrowSize;
    const CGFloat widthHalf = kCellWidth * 0.5f;
    const CGFloat kMargin = 5.f;
    
    CGPoint point = CGPointMake(rectMidX - widthHalf, rectMaxY);
    
    if (point.x < kMargin)
        point.x = kMargin;
    //如果下拉框超出右边便捷，设置为距边界margin距离的位置
    if ((point.x + kCellWidth + kMargin) > outerWidth)
        point.x = outerWidth - kCellWidth - kMargin;
    //计算箭头X坐标
    _arrowPosition = rectMidX - point.x;
    //计算菜单列表高度，如果超过3行，只取3行，3行内不可滑动
    CGFloat height = 0;
    if (menuCount >= 3) {
        height = kCellHeight * 3;
        self.menuTableView.scrollEnabled = YES;
    } else {
        height = kCellHeight * menuCount;
        self.menuTableView.scrollEnabled = NO;
    }
    
    //加上箭头高度
    height += kArrowSize;
    self.frame = CGRectMake(point.x, point.y, kCellWidth, height);
    self.menuTableView.frame = CGRectMake(0, kArrowSize, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - kArrowSize);
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    [self drawBackground:self.bounds
               inContext:UIGraphicsGetCurrentContext()];
}

- (void)drawBackground:(CGRect)frame
             inContext:(CGContextRef)context {
    
    CGFloat X0 = CGRectGetMinX(frame);
    CGFloat X1 = CGRectGetMaxX(frame);
    CGFloat Y0 = CGRectGetMinY(frame);
    CGFloat Y1 = CGRectGetMaxY(frame);
    
    // fix the issue with gap of arrow's base if on the edge
    const CGFloat kEmbedFix = 3.f;
    const CGFloat arrowXM = _arrowPosition;
    const CGFloat arrowX0 = arrowXM - kArrowSize;
    const CGFloat arrowX1 = arrowXM + kArrowSize;
    const CGFloat arrowY0 = Y0;
    const CGFloat arrowY1 = Y0 + kArrowSize + kEmbedFix;
    
    //画箭头
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY0}];
    [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
    [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY1}];
    [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY0}];
    
    [[UIColor whiteColor] set];

    [arrowPath fill];
    
    //画矩形
    Y0 += kArrowSize;
    const CGRect bodyFrame = {X0, Y0, X1 - X0, Y1 - Y0};
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:bodyFrame
                                                          cornerRadius:kCornerRadius];
    [[UIColor whiteColor] set];
    
    [borderPath fill];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = indexPath.row;
    ZXVPopupItem *item = self.menuItems[row];
    ZXVPopupMenuTableViewCell *cell = (ZXVPopupMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.imageView.image = item.iconImage;
    cell.textLabel.text = item.title;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger row = indexPath.row;
    ZXVPopupItem *item = self.menuItems[row];
    if (item.callBack) {
        item.callBack(row);
    } else if (item.target && item.action && [item.target respondsToSelector:item.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [item.target performSelector:item.action withObject:self];
#pragma clang diagnostic pop
    }
    [self dismissMenu:NO];
}

#pragma mark - Getters

- (UITableView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc] init];
        _menuTableView.backgroundColor = [UIColor clearColor];
        [_menuTableView setSeparatorInset:UIEdgeInsetsMake(0, kLeftCellSeparatorDistance, 0, 0)];
        _menuTableView.layer.cornerRadius = kCornerRadius;
        _menuTableView.rowHeight = kCellHeight;
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        _menuTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _menuTableView.showsVerticalScrollIndicator = NO;
        _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_menuTableView.frame), 1)];
        [_menuTableView registerClass:[ZXVPopupMenuTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _menuTableView;
}

@end
