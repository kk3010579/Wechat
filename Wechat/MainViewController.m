

#warning 是觉得在同一个文件的代码很多不知看哪里呢？点↑↑↑↑上面吧！

//  Created by Day on 14-5-27.
//  Copyright (c) 2014年 Day. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Wechat";
    }
    return self;
}

 /*
 *******************
 ***WeChat机器人版***
 *******************
 ***这里采用智能对话***
 *******************
 **感谢赛科智能机器人**
 *******************
 ***网上的其他机器人***
 *******************
 *要么收费，要么要签名**
 *******************
 *这里赛科直接用web调用*
 ********************
 *******但是**********
 ***赛课机器人有个问题**
 ********************
 ***就是不能输入中文****
 *不是我的问题，是赛科API的问题哦！*
 ********************
 *赛科机器人支持拼音字母*
 ********************
 *本应用暂时不做7.0以下兼容*
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化toolBar
    [self.toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_bottom_bar"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    //初始化声音输入为no
    self.voiceInput = NO;
    
    //“按住说话”的button在这里初始化，然后加入toolBar并隐藏
    UIButton *bt = [[UIButton alloc]init];
    self.sound = bt;
    [bt release];
    self.sound.frame = CGRectMake(66, 4, 142, 34);
    [self.sound setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.sound setTitle:@"请说话" forState:UIControlStateHighlighted];
    [self.sound setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sound setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    
    //这里用UIControlEventTouchDown实现"按住说话"
    [self.sound addTarget:self action:@selector(talk) forControlEvents:UIControlEventTouchDown];
    [self.sound addTarget:self action:@selector(talkStop) forControlEvents:UIControlEventTouchUpInside];
    self.sound.backgroundColor = [UIColor grayColor];
    [self.toolBar addSubview:self.sound];
    self.sound.hidden = YES;
    
    //初始化信息存储数组
    _sumChat = [[NSMutableArray alloc]init];
    
#warning 这里注释了手势事件，这里的手势作用是：用户点击空白处的时候取消UITextField的第一响应者，从而让键盘消失。但是如果当我选中一个cell的时候想要响应播放录音的话会有bug，bug就是无法播放声音。原因是这个点击事件UITouch被下面的手势识别器吸收掉了。这里按照响应者链的层级关系来决定的。所以才无法播放声音。但是我要实现和微信一样的即能点击播放声音，又能点击空白的地方响应手势事件呢？有个想法是：将cell的contentView里面分开两个，一部分是有内容的气泡，另一部分是没内容的空白地方。这时候我们就可以分开响应这两种情况了。具体有待试验。这里就不做了。直接取消了手势事件。
    //添加手势事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    tap.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:tap];
    [tap release];
    
    //一个监听键盘高度改变的通知事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //初始化录音音量动态显示的view
    _recordingView = [[UIView alloc]initWithFrame:CGRectMake(160-50, [[UIScreen mainScreen]bounds].size.height-200, 100, 100)];
    self.recordingView.backgroundColor = [UIColor grayColor];
    UIImageView *recordingImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_bottom_voice_nor"]];
    recordingImage.tag = 10004;
    recordingImage.frame = CGRectMake(0, 20, 60, 60);
    [_recordingView addSubview:recordingImage];
    [recordingImage release];
    [self.view addSubview:_recordingView];
    _recordingView.hidden = YES;
    
    //初始化音量声波view，就是会动的那个view，这里通过改变view的高度来显示动态声波的效果
    UIView *volChangeView = [[UIView alloc]initWithFrame:CGRectMake(60, 80, 20, 10)];
    volChangeView.backgroundColor = [UIColor yellowColor];
    volChangeView.tag = 10005;
    [_recordingView addSubview:volChangeView];
    [volChangeView release];
    
}


#pragma mark - 触摸事件
-(void)tap
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, [[UIScreen mainScreen]bounds].size.height);
    }completion:^(BOOL finished){}];
    
    [self.chatInput resignFirstResponder];
}

#pragma mark - 监听键盘高度改变事件
- (void)keyboardWillShow:(NSNotification *)notification {
    //无候选词的时候的键盘高度
    static CGFloat normalKeyboardHeight = 216.0f;
    //获取传过来的对象
    NSDictionary *info = [notification userInfo];
    //获取有候选词的时候的键盘高度
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //求差值：高度36px
    CGFloat distanceToMove = kbSize.height - normalKeyboardHeight;
    
    //一定要判断，不然在拼音和英文之间切换的时候会有高度上移的bug。
    if (distanceToMove == 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, [[UIScreen mainScreen]bounds].size.height-216);
        }completion:^(BOOL finished){
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-distanceToMove);
        }completion:^(BOOL finished){
        }];
    }
    if (self.sumChat.count >1) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.sumChat.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - 语音--键盘  按钮
- (IBAction)left1Event:(id)sender {
    if (self.voiceInput == NO) {
        [self.left1 setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor"] forState:UIControlStateNormal];
        [self.left1 setImage:[UIImage imageNamed:@"chat_bottom_keyboard_press"] forState:UIControlStateHighlighted];
        self.voiceInput = YES;
        self.chatInput.hidden = YES;
        self.sound.hidden = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = CGRectMake(0, 0,self.view.frame.size.width, [[UIScreen mainScreen]bounds].size.height);
        }completion:^(BOOL finished){}];
        [self.chatInput resignFirstResponder];
        
    }else{
        [self.left1 setImage:[UIImage imageNamed:@"chat_bottom_voice_nor"] forState:UIControlStateNormal];
        [self.left1 setImage:[UIImage imageNamed:@"chat_bottom_voice_press"] forState:UIControlStateHighlighted];
        self.voiceInput = NO;
        self.chatInput.hidden = NO;
        self.sound.hidden = YES;
        [self.chatInput becomeFirstResponder];
    }
}

#pragma mark - 录音
-(void)talk
{
    NSLog(@"说话。。。");
    _recordingView.hidden = NO;
    
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [_audioSession setActive:YES error:nil];
    
    NSDictionary *setting = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithFloat: 44100.0],AVSampleRateKey,
                             [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                             [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                             [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                             [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                             [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                             nil]; //然后直接把文件保存成.wav就好了

    NSDate *time = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    [timeFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *timeNow = [timeFormatter stringFromDate:time];
    [timeFormatter release];

    _tmpFile = [NSURL fileURLWithPath:
               [NSTemporaryDirectory() stringByAppendingPathComponent:
                [NSString stringWithFormat: @"%@%@.%@",
                 @"我的录音文件",
                 timeNow,@"caf"]]];
    _recorder = [[AVAudioRecorder alloc] initWithURL:_tmpFile settings:setting error:nil];
    [_recorder setDelegate:self];
    [_recorder prepareToRecord];
    [_recorder record];
    [setting release];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(volChange2) userInfo:nil repeats:YES];
}

-(void)volChange2
{
    [_recorder updateMeters];//刷新音量数据
    
#warning 这里本来是想要动态显示音量的声波的，但是有bug，不知道为什么初始化录音是1，录音时却是0。这个bug有待研究。
    float vol = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    NSLog(@"波动值：%f",vol);
    NSArray *array = _recordingView.subviews;
    UIView *volView = nil;
    for (UIView *view in array) {
        if (view.tag == 10005) {
            volView = view;
        }
    }
    
    volView.frame = CGRectMake(60, 100-100*vol, 20, 100*vol);
}

#pragma mark - 停止录音
-(void)talkStop
{
#warning 采用随机用户对话模式。
    //和打飞机一样的自慰式对话。这里简单设置。采用随机数。
    int a = arc4random()%10;
    NSLog(@"停止说话。。。");
    [_audioSession setActive:NO error:nil];
    [_recorder stop];
    AVAudioPlayer *av = [[AVAudioPlayer alloc]initWithContentsOfURL:_tmpFile error:nil];
    NSString *string = [NSString stringWithFormat:@"%0.1fs",av.duration];
    if (av.duration >= 1) {
        _recordingView.hidden = YES;
        if (a > 4) {
            NSDictionary *tom = [NSDictionary dictionaryWithObjectsAndKeys:
                                 string,@"content",
                                 @"tom",@"name",
                                 _tmpFile,@"recordFile",
                                 nil];
            [self.sumChat addObject:tom];
            
        }else{
            NSDictionary *jackey = [NSDictionary dictionaryWithObjectsAndKeys:
                                    string,@"content",
                                    @"jackey",@"name",
                                    _tmpFile,@"recordFile",
                                    nil];
            [self.sumChat addObject:jackey];
            
        }
    }else{
        self.recordingView.hidden = YES;

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(160-50, [[UIScreen mainScreen]bounds].size.height-200, 100, 100)];
        label.backgroundColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"时间过短";
        [self.view addSubview:label];
        
        [UIView transitionWithView:label duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
            label.hidden = NO;
        }completion:^(BOOL finished){
            label.hidden = YES;
        }];
        
        [label release];
    }
    //重载tableView
    [self.chatTableView reloadData];
    [av release];
    
    if (self.sumChat.count >1) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.sumChat.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    //停止定时器timer
    [self.timer invalidate];
}

- (IBAction)right1Event:(id)sender {
    
}

- (IBAction)right2Event:(id)sender {
    
}

#pragma mark - UITextField代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSDictionary *jackey = [NSDictionary dictionaryWithObjectsAndKeys:
                            textField.text,@"content",
                            @"jackey",@"name",
                            @"NoRecord",@"recordFile",
                            nil];
    [self.sumChat addObject:jackey];
    
    //为了清除之前的回答数据，在这里释放_data，不然每次alloc会有不同地址造成内存泄露。
    [_data release];
    _data = nil;
    _data = [[NSMutableData alloc]init];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://dev.skjqr.com/api/weixin.php?email=5914018@qq.com&appkey=d5fa0a17b4bb12838b9a0e57a34edc17&msg=%@",textField.text]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    [request release];

    [self.chatTableView reloadData];
    
    if (self.sumChat.count >1) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.sumChat.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

    textField.text = nil;
//    [textField resignFirstResponder];
    return YES;
}

#pragma mark - NSURLConnection代理方法
//数据加载过程调用---在多线程
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}
//加载完成后调用-----在主线程
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *string = [[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    //这里要截取两次。不然前面的[msg]截取不了。
    NSString *subString = [string substringFromIndex:4];
    NSString *subString2 = [subString substringFromIndex:6];
    NSString *subString3 = [subString2 substringToIndex:subString2.length-6];
    NSDictionary *tom = [NSDictionary dictionaryWithObjectsAndKeys:
                            subString3,@"content",
                            @"tom",@"name",
                            @"NoRecord",@"recordFile",
                            nil];
    [self.sumChat addObject:tom];
    [string release];
    
    [_chatTableView reloadData];
    if (self.sumChat.count >1) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.sumChat.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
#pragma mark - UITableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //去除cell间隔线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return self.sumChat.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#warning 这里就不用xib做cell了，尝试过一下，卡在了toolBar的问题上故暂时放下，该用在这里用代码实现。我也不将cell封装成一个类了。下次再尝试把。
    static NSString *cellIndentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier] autorelease];
    }
    
    //清除上一次的视图
    for(UIView *view in cell.contentView.subviews){
        
        if(view.tag==1001 || view.tag==1002)
            [view removeFromSuperview];
    }
    
    //头像
    UIImageView *imageViewHead = [[UIImageView alloc]init];
    imageViewHead.tag=1001;
    //气泡
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.tag=1002;
    //文字
    UILabel *label = [[UILabel alloc]init];
    label.tag=1003;
    label.numberOfLines = 0;
    
    label.text = [[self.sumChat objectAtIndex:indexPath.row] objectForKey:@"content"];
    
    //计算文字内容的宽度和高度
    CGSize size = [label.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(200, INT_MAX)];
    
    //设置头像文字气泡等
    if ([[[self.sumChat objectAtIndex:indexPath.row] objectForKey:@"name"]isEqual:@"tom"]) {
        imageViewHead.image = [UIImage imageNamed:@"icon01.jpg"];
        imageViewHead.frame = CGRectMake(0, 0, 60, 60);
        imageView.image = [UIImage imageNamed:@"chatfrom_bg_normal"];
        label.frame = CGRectMake(20, 0, size.width+20, size.height+40);
        imageView.frame = CGRectMake(60, 0, size.width+60, size.height+50);
    }else{
        imageViewHead.image = [UIImage imageNamed:@"icon02.jpg"];
        imageViewHead.frame = CGRectMake(320-60, 0, 60, 60);
        imageView.image = [UIImage imageNamed:@"chatto_bg_normal"];
        label.frame = CGRectMake(20, 0, size.width+20, size.height+40);
        imageView.frame = CGRectMake(320-imageViewHead.frame.size.width-size.width-60, 0, size.width+60, size.height+50);
    }
    
    CGFloat top = 50; // 顶端盖高度
    CGFloat bottom = 50 ; // 底端盖高度
    CGFloat left = 50; // 左端盖宽度
    CGFloat right = 50; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    imageView.image = [imageView.image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    cell.backgroundColor = [UIColor clearColor];
    [imageView addSubview:label];
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:imageViewHead];
    [imageViewHead release];
    [label release];
    [imageView release];
    
    //选中cell后背景无颜色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = [[self.sumChat objectAtIndex:indexPath.row] objectForKey:@"content"];
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(200, 100000)];
    return size.height+50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError *error;
    if (![[[self.sumChat objectAtIndex:indexPath.row]objectForKey:@"recordFile"]isEqual:@"NoRecord"]) {
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:_tmpFile error:&error];
        _audioPlayer.volume = 8;
        
        if (error) {
            NSLog(@"paly error is : %@",[error description]);
            return;
        }
        
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
    
    //让键盘消失
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, [[UIScreen mainScreen]bounds].size.height);
    }completion:^(BOOL finished){}];
    [_chatInput resignFirstResponder];
}

#pragma mark - 释放内存
- (void)dealloc {
    [_chatTableView release];
    [_toolBar release];
    [_chatInput release];
    [_left1 release];
    [_right1 release];
    [_left1 release];
    [_right1 release];
    [_right2 release];
    [self.sound release];
    [self.timer release];
    [self.sumChat release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recordingView release];
    [_recorder release];
    [_tmpFile release];
    [_audioPlayer release];
    [_audioSession release];
    [_data release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
