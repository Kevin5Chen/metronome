//
//  MetronomeCollectionViewCell.m
//  metronome
//
//  Created by Kevin on 16/11/18.
//  Copyright © 2016年 com.linlin.kaige.com. All rights reserved.
//

#import "MetronomeCollectionViewCell.h"

#define MetroColorFromRGBA(rgbValue, a)                                     \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
blue:((float)(rgbValue & 0xFF)) / 255.0             \
alpha:a]

@interface MetronomeCollectionViewCell ()

@property(nonatomic,strong)UIView *dotView;

@end

@implementation MetronomeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.dotView];
    }
    return self;
}

- (void)setIsLeftFirst:(BOOL)isLeftFirst {
    _isLeftFirst = isLeftFirst;
    CGFloat w ;
    CGFloat frame_w = self.frame.size.width;
    CGFloat frame_h = self.frame.size.height;
    w = frame_w>frame_h?frame_h:frame_w;
    if (_isLeftFirst) {
        w = w*0.8;
    }else {
        w = w*0.6;
    }
    _dotView.frame = CGRectMake(0, 0, w, w);
    _dotView.center = CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5);
    _dotView.layer.cornerRadius = w*0.5;
    _dotView.layer.masksToBounds = YES;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (_isSelected) {
        _dotView.backgroundColor = MetroColorFromRGBA(0xb85050, 1);
    }else {
        _dotView.backgroundColor = MetroColorFromRGBA(0xb85050, 0.5);
    }
}

- (UIView *)dotView {
    if (_dotView) {
        return _dotView;
    }
    _dotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _dotView.backgroundColor = [UIColor redColor];
    return _dotView;
}


@end
