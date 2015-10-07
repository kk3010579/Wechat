//
//  MainViewController.h
//  Wechat
//
//  Created by Day on 14-5-27.
//  Copyright (c) 2014年 Day. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"
#import <AVFoundation/AVFoundation.h>
@interface MainViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,AVAudioRecorderDelegate>
 /*
 ***************
 **问你一个问题吧*
 ***************
 *程序猿有女朋友吗*
 ***************
 **闲着蛋疼写注释*
 ***************
 */

@property (assign, nonatomic) BOOL                 voiceInput;    //用于“按住录音”按钮和输入文字的判断
@property (retain, nonatomic) NSURL                *tmpFile;      //录音文件路径
@property (retain, nonatomic) UIView               *volChange;    //动态显示声波的view
@property (retain, nonatomic) UIView               *recordingView;//正在录音的view
@property (retain, nonatomic) NSTimer              *timer;        //用来监听动态显示声波的timer
@property (retain, nonatomic) UIButton             *sound;        //按住录音的按钮
@property (retain, nonatomic) NSMutableData        *data;         //接收赛科返回数据
@property (retain, nonatomic) AVAudioPlayer        *audioPlayer;  //播放器，用于播放录音
@property (retain, nonatomic) NSMutableArray       *sumChat;      //装聊天内容
@property (retain, nonatomic) AVAudioSession       *audioSession; //音频会话
@property (retain, nonatomic) AVAudioRecorder      *recorder;     //录音器
@property (retain, nonatomic) IBOutlet UIButton    *left1;        //xib关联
@property (retain, nonatomic) IBOutlet UIButton    *right1;       //xib关联
@property (retain, nonatomic) IBOutlet UIButton    *right2;       //xib关联
@property (retain, nonatomic) IBOutlet UIToolbar   *toolBar;      //xib关联
@property (retain, nonatomic) IBOutlet UITextField *chatInput;    //xib关联
@property (retain, nonatomic) IBOutlet UITableView *chatTableView;//xib关联

- (IBAction)left1Event: (id)sender;
- (IBAction)right1Event:(id)sender;
- (IBAction)right2Event:(id)sender;









@end
