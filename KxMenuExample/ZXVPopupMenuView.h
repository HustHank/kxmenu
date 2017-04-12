//
//  ZXVPopupMenu.h
//  USeeTV
//
//  Created by admin on 2017/4/10.
//  Copyright © 2017年 ZTE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZXVDropMenuCallBack)();

@interface ZXVPopupItem : NSObject

+ (instancetype)itemWithTitle:(NSString *)title
                    iconImage:(UIImage *)iconImage
                     callBack:(ZXVDropMenuCallBack)callBack;

+ (instancetype)itemWithTitle:(NSString *)title
                    iconImage:(UIImage *)iconImage
                       target:(id)target
                     action:(SEL)action;

@end

@interface ZXVPopupMenuView : UIView

+ (void)showMenuFromRect:(CGRect)rect
               menuItems:(NSArray<ZXVPopupItem *> *)menuItems;

@end
