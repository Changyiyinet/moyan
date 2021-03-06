//
//  MYWriteToOrderViewController.m
//  魔颜
//
//  Created by abc on 16/5/18.
//  Copyright © 2016年 abc. All rights reserved.
//

#import "MYQuickWriteToOrderForServiceViewController.h"
#import "MYTextView.h"
#import "MYQuickWriteToOrderForProductViewController.h"
#import "MYOrderResultViewController.h"
#import "MYModel.h"
#import "MYHeader.h"

@interface MYQuickWriteToOrderForServiceViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate>
@property(strong,nonatomic) UITableView * tableview;


@property(strong,nonatomic) UITextField * nametextfile;
@property(strong,nonatomic) UITextField * phonetextField;
@property(strong,nonatomic) UITextField * codetextfiled;

@property (copy, nonatomic) NSString *identifyCode;
@property(copy,nonatomic) NSString * superCode;

@property (nonatomic, assign) NSInteger number;

@property (weak, nonatomic) UIButton *timerBtn;

/** 计时器 */
@property (strong, nonatomic) NSTimer *timer;

@property(strong,nonatomic) MYTextView * textview;

/** 用户模型 */
@property (strong, nonatomic) MYModel *model;

@end

@implementation MYQuickWriteToOrderForServiceViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated ];
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGB(0xf7f7f7);

    self.title = @"填写订单";
    
    [self addtableview];
    self.tableview.tableFooterView = [[UIView alloc]init];
    [self addfooterview];
    [self addboomview];
}

-(void)addtableview
{
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 64, MYScreenW, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    line.alpha = 0.6;
    [self.view addSubview:line];
    
    UITableView *tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 65, MYScreenW, 150)];
    tableview.backgroundColor = UIColorFromRGB(0xf7f7f7);
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.scrollEnabled = NO;
    [self.view addSubview:tableview];
    self.tableview = tableview;
    

}

-(void)addfooterview
{
    UIView *footerview = [[UIView alloc]initWithFrame:CGRectMake(-1, 225, MYScreenW+2, 140)];
    footerview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:footerview];
    footerview.layer.borderColor = MYColor(200, 200, 200).CGColor;
    footerview.layer.borderWidth = 0.5;

    
    
    UILabel *beizhu = [[UILabel alloc]initWithFrame:CGRectMake(10, kMargin/2, 100, 30)];
    [footerview addSubview:beizhu];
    beizhu.text =@"备注";
    beizhu.font = MYFont(14);
    beizhu.textColor =  UIColorFromRGB(0x4c4c4c);
    
    
    MYTextView *textview = [[MYTextView alloc]initWithFrame:CGRectMake(kMargin, 40, MYScreenW-MYMargin, 90)];
    textview.delegate = self;
    [footerview addSubview:textview];
    textview.placeHoledr = @"如果您有特殊需求请您在这里登记一下，我们一定会为您提前安排好";
    textview.tag = 1;
    textview.placeLabel.font = MYFont(14);
    textview.textColor =  UIColorFromRGB(0x4c4c4c);
    self.textview = textview;

}

-(void)addboomview
{
    UIButton *NEXT = [[UIButton alloc]initWithFrame:CGRectMake(kMargin, MYScreenH-50, MYScreenW-MYMargin, 40)];
    [self.view addSubview:NEXT];
    
    [NEXT setBackgroundColor:UIColorFromRGB(0xed0381)];
    [NEXT setTitle:@"下一步" forState:UIControlStateNormal];
    NEXT.titleLabel.font = MYFont(17);
    NEXT.layer.cornerRadius = 5;
    NEXT.layer.masksToBounds = YES;
    [NEXT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NEXT addTarget:self action:@selector(pushNextVC:) forControlEvents:UIControlEventTouchUpInside];

}
/** 点击下一步 */
-(void)pushNextVC:(UIButton*)btn
{

    if ([self.nametextfile.text isEqualToString:@""] || self.nametextfile.text == nil) {
        [MBProgressHUD showHUDWithTitle:@"请输入姓名" andImage:nil andTime:1.0];
        return;
    }
    if ([self CheakAll]) {
        
        NSString *devCode = [MYUserDefaults objectForKey:@"devCode"];

        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"phone"] = self.phonetextField.text;
        params[@"deviceCode"] = devCode ? devCode : [MYStringFilterTool getUDID];
        
        [MYHttpTool postWithUrl:[NSString stringWithFormat:@"%@user/quickAddUser",kOuternet1]  params:params success:^(id responseObject) {
            
            MYModel *model = [MYModel objectWithKeyValues:responseObject];
            self.model = model;
            
            NSString *str = [NSString stringWithFormat:@"%@%@",kOuternet1,[responseObject[@"user"] objectForKey:@"pic"]];
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
            
            //让验证码倒计时消失
            if(self.timer != nil)
                [self.timer invalidate];
            self.timer = nil;
            self.timerBtn.userInteractionEnabled = YES;
            self.timerBtn.titleLabel.text = @"获取验证码";
            
            if (self.price) {
                
                MYOrderResultViewController *resultVC = [[MYOrderResultViewController alloc] init];
                resultVC.name = self.nametextfile.text;
                resultVC.phoneNumber = model.user.phone;
                resultVC.isLogin = model.isLogin;
                resultVC.userId = model.user.ID;
                resultVC.id = self.id;
                resultVC.discountPrice = self.discountPrice;
                resultVC.price = self.price;
                resultVC.goodsTitle = self.goodsTitle;
                resultVC.beizhu = self.textview.text;
                resultVC.FROMEVC = @"SERVICE";
                resultVC.jigoustr = _jigoustr;
                resultVC.Vctage = _vctag;
                resultVC.listPic = self.listPic;
                
                //保存默认用户
                [MYUserDefaults setBool:YES forKey:@"hasLogin"];//已经登陆
                [MYUserDefaults setObject:self.model.user.sex forKey:@"sex"];
//              [MYUserDefaults setObject:self.model.user.pic forKey:@"data"];
                [MYUserDefaults setObject:self.model.user.region forKey:@"region"];
                [MYUserDefaults setObject:self.model.user.phone forKey:@"code"];
                [MYUserDefaults setObject:self.model.user.ID forKey:@"id"];
                [MYUserDefaults setObject:self.model.user.password forKey:@"password"];
                [MYUserDefaults setObject:self.nametextfile.text forKey:@"name"];
                [MYUserDefaults setObject:self.model.user.token forKey:@"token"];
                [MYUserDefaults setObject:self.model.isLogin forKey:@"ISLOGIN"];
                //是否是新注册的用户
                [MYUserDefaults setObject:data forKey:@"data"];
                [MYUserDefaults synchronize];

                MYAppDelegate.isLogin = YES;
                [self.navigationController pushViewController:resultVC animated:YES];
                
                
            }else{
            
                /**
                 *  拿到价格(如果是一分钱抢购)
                 */
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                param[@"specialdealsId"] = self.id;
                param[@"userId"] = model.user.ID;
                
                [MYHttpTool postWithUrl:[NSString stringWithFormat:@"%@salonSpe/queryUserDiscount",kOuternet1] params:param success:^(id responseObject) {
                    
                    NSString *status = [responseObject objectForKey:@"status"];
                    if ([status isEqualToString:@"success"]) {
                        
                        MYOrderResultViewController *resultVC = [[MYOrderResultViewController alloc] init];
                        resultVC.name = self.nametextfile.text;
                        resultVC.phoneNumber = self.model.user.phone;
                        resultVC.isLogin = self.model.isLogin;
                        resultVC.userId = self.model.user.ID;
                        
                        resultVC.FROMEVC = @"PRODUCT";
                        resultVC.beizhu = self.textview.text;
                        resultVC.jigoustr = _jigoustr;
                        resultVC.Vctage = _vctag;
                        resultVC.listPic = responseObject[@"listPic"];
                        
                        resultVC.id = self.id;
                        if ([responseObject[@"isDiscount"] isEqualToString:@"1"]) {
                            
                            resultVC.discountPrice = responseObject[@"bindDiscount"];
                            
                        }else{
                            
                            resultVC.discountPrice = self.discountPrice;
                        }
                        resultVC.price = responseObject[@"price"];
                        resultVC.goodsTitle = self.goodsTitle;
                        
                        //保存默认用户
                        [MYUserDefaults setBool:YES forKey:@"hasLogin"];//已经登陆

                        [MYUserDefaults setObject:self.model.user.sex forKey:@"sex"];
//                       [MYUserDefaults setObject:self.model.user.pic forKey:@"data"];
                        [MYUserDefaults setObject:self.model.user.region forKey:@"region"];
                        [MYUserDefaults setObject:self.model.user.phone forKey:@"code"];
                        [MYUserDefaults setObject:self.model.user.ID forKey:@"id"];
                        [MYUserDefaults setObject:self.model.user.password forKey:@"password"];
                        [MYUserDefaults setObject:self.nametextfile.text forKey:@"name"];
                        [MYUserDefaults setObject:self.model.user.token forKey:@"token"];
                        [MYUserDefaults setObject:self.model.isLogin forKey:@"ISLOGIN"];//是否是新注册的用户
                        [MYUserDefaults setObject:data forKey:@"data"];
                        [MYUserDefaults synchronize];
                        
                        
                        MYAppDelegate.isLogin = YES;

                        [self.navigationController pushViewController:resultVC animated:YES];


                    }
                    
                } failure:^(NSError *error) {
                    
                    
                }];
            }
            
                
            } failure:^(NSError *error) {
              
            }];
       
        
        }
        
       

}

/*
 @brief 是否填写准确判断
 */
- (BOOL)CheakAll
{
    //1.手机
    if ([self checkInput]) {
        
        if(self.codetextfiled.text.length == 0){
            [MBProgressHUD showError:@"验证码不能为空"];
            return NO;
        }else if (self.codetextfiled.text.length != 4){
            [MBProgressHUD showError:@"验证码格式有误"];
            return NO;
            
        }else if([self.codetextfiled.text isEqualToString:self.identifyCode] || [self.codetextfiled.text isEqualToString:self.superCode])
        {
            return YES;
            
        }else{
            
            [MBProgressHUD showError:@"验证码验证失败"];
            return NO;
            
        }
    }else{
        return NO;
    }
}
//发送验证码
-(void)sendcode
{
    if ([self checkInput]){
        
        //获取验证码
        NSString* str = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"我们将会发送验证码到手机", nil),self.phonetextField.text];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认手机号码" message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alertView show];
        
    }
}

//发送验证码
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        //1.倒计时
        self.number = 60;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        self.timer = timer;
        [timer fire];
        
        //2.把数据传给后台
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"phone"] = self.phonetextField.text;
        
        [MYHttpTool postWithUrl:[NSString stringWithFormat:@"%@/user/getCode",kOuternet1] params:params success:^(id responseObject) {
            NSString *status = responseObject[@"status"];
            
            if ([status isEqualToString:@"error"]) {
                
                [MBProgressHUD showSuccess:@"服务器错误"];
            }
            
            NSString *superCode = responseObject[@"musterCode"];
            self.superCode = superCode;
            NSString *identifyCode = [responseObject objectForKey:@"code"];
            self.identifyCode = identifyCode;
        
        } failure:^(NSError *error) {
            
            [MBProgressHUD showError:@"验证码获取失败"];
            
        }];
    }
}

//计算定时器时间
-(void)updateTime:(NSTimer *)Timer
{
    self.number--;
    
    self.timerBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.timerBtn.titleLabel.text = [NSString stringWithFormat:@"%lds",(long)self.number];
    self.timerBtn.userInteractionEnabled = NO;
    
    if (self.number == 0){
        
        [Timer invalidate];
        
        self.timerBtn.titleLabel.text = @"获取验证码";
        self.timerBtn.userInteractionEnabled = YES;
        
    }else{
        
    }
}

#pragma mark--代理方法
//行数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str_Identifier = [NSString stringWithFormat:@"Tiezi%ld",(long)[indexPath row]];
    
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:str_Identifier];
    
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str_Identifier];
    }
    CGFloat RowHeight = 50;
    CGFloat leftwidth = 60;
    
    //去掉点击效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.row == 0) {
        
        UILabel *titleLabel = [self addLabelWithFrame:CGRectMake(kMargin, 0, leftwidth, RowHeight) text:@"姓名"];

        [cell.contentView addSubview:titleLabel];
        
        
        UITextField *name = [self addFieldWithFrame:CGRectMake(kMargin+leftwidth, 0, MYScreenW-leftwidth-MYMargin, RowHeight) text:self.nametextfile.text];
        self.nametextfile = name;
        [cell.contentView addSubview:name];
        
    }
    else if(indexPath.row == 1) {
        
        UILabel *label = [self addLabelWithFrame:CGRectMake(kMargin, 0, leftwidth, RowHeight) text:@"手机"];
        [cell.contentView addSubview:label];
        
        
        UITextField *phonetextField = [self addFieldWithFrame:CGRectMake(leftwidth+kMargin , 0, MYScreenW-leftwidth-MYMargin, RowHeight) text:self.phonetextField.text];
        self.phonetextField = phonetextField;
        [cell.contentView addSubview:phonetextField];

    }else if(indexPath.row == 2) {
        
        UITextField *codetextfiled = [self addFieldWithFrame:CGRectMake(kMargin, 0, MYScreenW - 160, RowHeight) text:self.codetextfiled.text];
        codetextfiled.placeholder = @"请输入短信验证码";
        self.codetextfiled = codetextfiled;
        [cell.contentView addSubview:codetextfiled];

        
        UIView *lie = [[UIView alloc]initWithFrame:CGRectMake(MYScreenW-120, 10, 0.5, 30)];
        lie.backgroundColor = [UIColor lightGrayColor];
        lie.alpha = 0.4;
        [cell.contentView addSubview:lie];
        
        
        UIButton *sendCode = [[UIButton alloc]initWithFrame:CGRectMake(MYScreenW-110, 10, 90, 30)];
        [cell.contentView addSubview:sendCode];
        [sendCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [sendCode setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        sendCode.titleLabel.font = MYFont(14);
        sendCode.layer.cornerRadius = 15;
        sendCode.layer.masksToBounds = YES;
        sendCode.layer.borderColor = UIColorFromRGB(0x808080).CGColor;
        sendCode.layer.borderWidth = 1;
        self.timerBtn = sendCode;
        [sendCode addTarget:self action:@selector(sendcode) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (BOOL)checkInput
{
    BOOL accountNumGood = [MYStringFilterTool filterByPhoneNumber:self.phonetextField.text];
    
    if (!accountNumGood) {
        
        [MBProgressHUD showError:@"请输入正确的手机号"];
        return NO;
        
    }else{
        
        return YES;
    }
}

/*
@brief textField
*/
- (UITextField *)addFieldWithFrame:(CGRect)frame text:(NSString *)text
{
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = frame;
    textField.delegate = self;
//    textField.placeholder = @"点击可编辑";
    [textField setValue:UIColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    [textField setValue:MYFont(14) forKeyPath:@"_placeholderLabel.font"];
    textField.font = MYSFont(14);
    textField.text = text;
    textField.textColor = UIColorFromRGB(0x4c4c4c);
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    return textField;
}

/*
 @brief 左边Label
 */
- (UILabel *)addLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.frame = frame;
    leftLabel.text = text;
    leftLabel.textColor = UIColorFromRGB(0x4c4c4c);
    leftLabel.font = MYFont(15);
    
    return leftLabel;
}

/*
 @brief 分割线左对齐
 */
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    //按照作者最后的意思还要加上下面这一段
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

// 将要拖拽的时候调一次
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

/**
 *  IOS键盘出现时视图上移
*/
- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    [self animateTextField: textView up: YES];
    
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self animateTextField: textView up: NO];
    
    return YES;
}

- (void) animateTextField: (UITextView*) textField up: (BOOL) up
{
    if (textField.tag && self.tableview.contentOffset.y < 110) {
        
         int movementDistance ; // tweak as needed
        if (MYScreenW<=320) {
            movementDistance = 50;
        }else{
//            movementDistance=25;
        }
        
        [UIView animateWithDuration:0.3f animations:^{
            
            int movement = (up ? -movementDistance : movementDistance);
            
            self.view.frame = CGRectOffset(self.view.frame, 0, movement);
            
        } completion:^(BOOL finished) {
            
        }];
    }
}
@end
