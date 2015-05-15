//
//  ViewController.m
//  HinoMonkey
//
//  Created by yanoshin on 5/15/15.
//  Copyright (c) 2015 yanoshin. All rights reserved.
//

#import "ViewController.h"
#import "Konashi.h"

#define CONNCTED_STR  @"サルを切断する"
#define UNCONNCTED_STR  @"サルと接続する"
#define DO_SHAKE_STR  @"首を振る！！！"
#define STOP_SHAKE_STR  @"ストップ"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *doConnectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *monkeyImageView;
@property (weak, nonatomic) IBOutlet UIButton *doShakeBtn;
@end

@implementation ViewController
    int shake_state;//0=首停止中、1=首振り中


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //初期状態
    [self hideControlUI];//サルと操作UIを非表示
    shake_state = 0;

    //BLE接続の準備
    [Konashi initialize];
    
    //非同期処理の定義（接続確立時、切断時など）
    [Konashi addObserver:self selector:@selector(ready) name:KonashiEventReadyToUseNotification];
    [Konashi addObserver:self selector:@selector(disconnected) name:KonashiEventDisconnectedNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)find:(id)sender {
    NSLog(@"接続/切断ボタンが押された");
    if(![Konashi isConnected]){
        NSLog(@"接続を開始");
        [Konashi find];
    } else {
        NSLog(@"切断を開始");
        //切断する前に緑LEDを消灯する
        [Konashi pinMode:KonashiDigitalIO4 mode:KonashiPinModeOutput];
        [Konashi digitalWrite:KonashiDigitalIO4 value:KonashiLevelLow];

        //念のため、首振りも止めておいた方が良さそう
        [self stopShake];
        
        //切断しますよ
        [Konashi disconnect];
    }
}

- (void)ready
{
    NSLog(@"接続しました");
    //接続完了時 緑LEDを点灯する
    [Konashi pinMode:KonashiDigitalIO4 mode:KonashiPinModeOutput];
    [Konashi digitalWrite:KonashiDigitalIO4 value:KonashiLevelHigh];
    
    //UI
    [self.doConnectBtn setTitle:CONNCTED_STR forState:UIControlStateNormal];
    [self.doConnectBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self showControlUI];
}

- (void)disconnected
{
    NSLog(@"切断しました");
    //UI
    [self.doConnectBtn setTitle:UNCONNCTED_STR forState:UIControlStateNormal];
    [self.doConnectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self hideControlUI];
}


//首振りボタン押下（開始/停止）　首振り中は赤LEDを点灯する
- (IBAction)doShake:(id)sender {
    if(shake_state==0){
        NSLog(@"首振りを開始します");
        [self startShake];
    } else {
        NSLog(@"首振りをやめます");
        [self stopShake];
    }
}

//サルと操作ボタンを非表示
- (void)hideControlUI {
    self.monkeyImageView.hidden = YES;
    self.doShakeBtn.hidden = YES;
}

//サルと操作ボタンを表示
- (void)showControlUI {
    self.monkeyImageView.hidden = NO;
    self.doShakeBtn.hidden = NO;
}

//首振り開始
- (void)startShake{
    [Konashi pinMode:KonashiDigitalIO3 mode:KonashiPinModeOutput];
    [Konashi digitalWrite:KonashiDigitalIO3 value:KonashiLevelHigh];
    
    //UI
    [self.doShakeBtn setTitle:STOP_SHAKE_STR forState:UIControlStateNormal];
    [self.doShakeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    shake_state=1;
}

//首振り停止
- (void)stopShake{
    [Konashi pinMode:KonashiDigitalIO3 mode:KonashiPinModeOutput];
    [Konashi digitalWrite:KonashiDigitalIO3 value:KonashiLevelLow];
    
    //UI
    [self.doShakeBtn setTitle:DO_SHAKE_STR forState:UIControlStateNormal];
    [self.doShakeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    shake_state=0;
}

@end
