//
//  ViewController.m
//  metronome
//
//  Created by Kevin on 16/11/18.
//  Copyright © 2016年 com.linlin.kaige.com. All rights reserved.
//

#import "ViewController.h"
#import "MetronomeAudioManager.h"
#import "FlowLayout.h"
#import "MetronomeCollectionViewCell.h"

//ui
#define angle2Radian(angle) ((angle) / 180.0f * M_PI)
#define angle 30
#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define metro_h ((375.0/670.0) *SCREEN_H)
#define metro_w ((648.0/750.0) *SCREEN_W)
#define button_h 48
#define button_top 44

//color
#define MetroColorFromRGB(rgbValue)                                         \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
blue:((float)(rgbValue & 0xFF)) / 255.0             \
alpha:1.0]

#define MAIN_COLOR MetroColorFromRGB(0xb85050)
#define LINE_COLOR MetroColorFromRGB(0xc3c3c3)
#define BG_COLOR MetroColorFromRGB(0xe0e0e0)

//default
static int MetronomeBPMMinValue   = 30;
static int MetronomeBPMMaxValue   = 220;
static int MetronomeBPCMinValue   = 1;
static int MetronomeBPCMaxValue   = 16;
static int MetronomeBPMDefaultValue   = 80;
static int MetronomeBPCDefaultValue   = 4;

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UILabel *bpmLabel;
@property(nonatomic,strong)UILabel *bpcLabel;
@property(nonatomic,strong)MetronomeAudioManager *metronomeAM;
@property(nonatomic,strong)UIView *pointerView;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,assign)NSInteger currentTickCount;

@end

@implementation ViewController

- (void)dealloc {
    [_metronomeAM stop];
    _metronomeAM = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MetroColorFromRGB(0xececec);
    
    self.metronomeAM = [[MetronomeAudioManager alloc] init];
    self.metronomeAM.bpmValue = MetronomeBPMDefaultValue;
    self.metronomeAM.bpcValue = MetronomeBPCDefaultValue;
    __weak typeof(self)weakSelf = self;
    self.metronomeAM.tickCountBlock = ^(NSInteger tickCount,BOOL isLeft){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%zd",tickCount);
            weakSelf.currentTickCount = tickCount;
            [weakSelf.collectionView reloadData];
            if (isLeft) {
                [weakSelf startAni:[NSNumber numberWithFloat:angle2Radian(-angle)] duration:weakSelf.metronomeAM.speed];
            }else {
                [weakSelf startAni:[NSNumber numberWithFloat:angle2Radian(angle)] duration:weakSelf.metronomeAM.speed];
            }
        });
    };
    
    //UI
    CGFloat bgtop = (SCREEN_H-metro_h-button_h-button_top)*0.5;
    CGFloat bgleft = (SCREEN_W-metro_w)*0.5;
    CGRect bgFrame = CGRectMake(bgleft, bgtop, metro_w, metro_h);
    UIView *bgView = [[UIView alloc] initWithFrame:bgFrame];
    bgView.backgroundColor = BG_COLOR;
    bgView.layer.cornerRadius = 10;
    bgView.layer.masksToBounds = YES;
    bgView.layer.borderColor = LINE_COLOR.CGColor;
    bgView.layer.borderWidth = 1;
    [self.view addSubview:bgView];
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_W-140)*0.5, bgView.frame.size.height+bgView.frame.origin.y+button_top, 140, button_h)];
    [playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    playButton.backgroundColor = MAIN_COLOR;
    [playButton setTitle:@"开始" forState:UIControlStateNormal];
    playButton.layer.cornerRadius = 5;
    playButton.layer.masksToBounds = YES;
    [self.view addSubview:playButton];
    
    CGFloat h_3 = 73;
    CGFloat h_2 = 60;
    CGFloat h_0_1 = (metro_h-h_2-h_3)*0.5;
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, h_0_1, metro_w, 1)];
    line1.backgroundColor = LINE_COLOR;
    [bgView addSubview:line1];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, h_0_1*2, metro_w, 1)];
    line2.backgroundColor = LINE_COLOR;
    [bgView addSubview:line2];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, h_0_1*2+h_2, metro_w, 1)];
    line3.backgroundColor = LINE_COLOR;
    [bgView addSubview:line3];
    
    self.pointerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, h_0_1*2)];
    self.pointerView.center = line2.center;
    self.pointerView.backgroundColor =  MAIN_COLOR;
    self.pointerView.layer.anchorPoint = CGPointMake(0.5, 1);
    [bgView addSubview:self.pointerView];
    
    UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    dotView.layer.cornerRadius = 10;
    dotView.layer.masksToBounds = YES;
    dotView.center = line2.center;
    dotView.layer.borderWidth = 1;
    dotView.layer.borderColor = LINE_COLOR.CGColor;
    dotView.backgroundColor = BG_COLOR;
    [bgView addSubview:dotView];
    
    self.bpmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, line3.frame.origin.y+8, metro_w*0.5, 20)];
    self.bpmLabel.textAlignment = NSTextAlignmentCenter;
    self.bpmLabel.font = [UIFont systemFontOfSize:16.0f];
    self.bpmLabel.text = [NSString stringWithFormat:@"BPC: %d",MetronomeBPMDefaultValue];
    [bgView addSubview:self.bpmLabel];
    
    //w = 94, h = 29
    UIStepper *bpmStepper = [[UIStepper alloc] initWithFrame:CGRectMake((metro_w*0.5-94)*0.5, self.bpmLabel.frame.origin.y+self.bpmLabel.frame.size.height+8, 0, 0)];
    bpmStepper.tintColor = MAIN_COLOR;
    bpmStepper.minimumValue = MetronomeBPMMinValue;
    bpmStepper.maximumValue = MetronomeBPMMaxValue;
    bpmStepper.value = MetronomeBPMDefaultValue;
    [bpmStepper addTarget:self action:@selector(bpmStepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    [bgView addSubview:bpmStepper];
    
    self.bpcLabel = [[UILabel alloc] initWithFrame:CGRectMake(metro_w*0.5, line3.frame.origin.y+8, metro_w*0.5, 20)];
    self.bpcLabel.textAlignment = NSTextAlignmentCenter;
    self.bpcLabel.font = [UIFont systemFontOfSize:16.0f];
    self.bpcLabel.text = [NSString stringWithFormat:@"节拍: %d",MetronomeBPCDefaultValue];
    [bgView addSubview:self.bpcLabel];
    
    UIStepper *bpcStepper = [[UIStepper alloc] initWithFrame:CGRectMake((metro_w*0.5-94)*0.5+(metro_w*0.5), self.bpmLabel.frame.origin.y+self.bpmLabel.frame.size.height+8, 0, 0)];
    bpcStepper.tintColor = MAIN_COLOR;
    bpcStepper.minimumValue = MetronomeBPCMinValue;
    bpcStepper.maximumValue = MetronomeBPCMaxValue;
    bpcStepper.value = MetronomeBPCDefaultValue;
    [bpcStepper addTarget:self action:@selector(bpcStepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    [bgView addSubview:bpcStepper];
    
    self.collectionView.frame = CGRectMake(0, h_0_1*2+10, metro_w, 40);
    self.collectionView.backgroundColor = BG_COLOR;
    [bgView addSubview:self.collectionView];
    
}

- (void)startAni:(NSValue*)value duration:(CGFloat)duration {
    CABasicAnimation *ani = [CABasicAnimation animation];
    ani.keyPath = @"transform.rotation";
    ani.duration = duration;
    ani.repeatCount = 1;
    ani.toValue = value;
    ani.removedOnCompletion = NO;
    ani.fillMode = kCAFillModeForwards;
    ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.pointerView.layer addAnimation:ani forKey:nil];
}

#pragma mark -UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.metronomeAM.bpcValue;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MetronomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    cell.backgroundColor = BG_COLOR;
    
    cell.isLeftFirst = indexPath.row==0?YES:NO;
    
    if (self.metronomeAM.isPlaying) {
        if (indexPath.row==self.currentTickCount) {
            cell.isSelected = YES;
        }else {
            cell.isSelected = NO;
        }
    }else {
        cell.isSelected = NO;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = metro_w/8.0;
    if (self.metronomeAM.bpcValue<=8) {
        w = metro_w/8.0;
    }else if(self.metronomeAM.bpcValue<=12){
        w = metro_w/12.0;
    }else{
        w = metro_w/16.0;
    }
    return CGSizeMake(w, 40);
}

#pragma mark -response

- (void)playButtonClicked:(UIButton *)sender {
    if (self.metronomeAM.isPlaying) {
        [self.metronomeAM stop];
        [self.pointerView.layer removeAllAnimations];
        [self.collectionView reloadData];
        [sender setTitle:@"开始" forState:UIControlStateNormal];
    }else {
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        [self startAni:[NSNumber numberWithFloat:angle2Radian(-angle)] duration:self.metronomeAM.speed*0.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.metronomeAM.speed*0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.metronomeAM play];
        });
    }
}

- (void)bpmStepperValueChanged:(UIStepper *)sender {
    self.metronomeAM.bpmValue = (NSInteger)sender.value;
    self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %zd",(NSInteger)sender.value];
}

- (void)bpcStepperValueChanged:(UIStepper *)sender {
    self.metronomeAM.bpcValue = (NSInteger)sender.value;
    self.bpcLabel.text = [NSString stringWithFormat:@"节拍: %zd",(NSInteger)sender.value];
    [self.collectionView reloadData];
}

#pragma mark getter

- (UICollectionView *)collectionView {
    if (_collectionView) {
        return _collectionView;
    }
    FlowLayout *flowLayout = [[FlowLayout alloc] init];
    flowLayout.alignment = FlowAlignmentCenter;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[MetronomeCollectionViewCell class] forCellWithReuseIdentifier:@"item"];
    return _collectionView;
}

@end

