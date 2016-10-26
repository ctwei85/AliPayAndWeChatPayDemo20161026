//
//  ViewController.m
//  iii
//
//  Created by lianchuang-hw on 16/10/25.
//  Copyright © 2016年 hw. All rights reserved.
//

#import "ViewController.h"

#import "WXApiObject.h"//微信支付
#import "Order.h"//支付宝支付
#import "DataSigner.h"//支付宝支付
#import <AlipaySDK/AlipaySDK.h>//支付宝支付
#import "WXApi.h"

@class PaymentModel;
@implementation PaymentModel
-(id)init{
    if(self = [super init]){
        _imageStr = @"";
        _paymentNameStr=@"";
        _isSelect = NO;
    }
    return self;
}


@end

@class PaymentCell;
@implementation PaymentCell
{
    UIImageView*_headerImage;//图像
    UILabel*_nameLabel;//名称
    UIImageView*_selectImage;//选中状态
    PaymentModel*_cellM;
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _headerImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 12, 44,44)];
        //_headerImage.layer.cornerRadius = (iPhone4 ? 40:47)*autoSizeScaleX/2.0f;
        _headerImage.clipsToBounds = YES;
        [self.contentView addSubview:_headerImage];
        
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headerImage.frame)+10, 26, 100, 22)];
        _nameLabel.font = [UIFont systemFontOfSize:18];
        _nameLabel.textColor=[UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.text = @"";
        [self.contentView addSubview:_nameLabel];
        
        UIButton*selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.frame =CGRectMake([UIScreen mainScreen].bounds.size.width-72, 0, 72, 72);
        [self.contentView addSubview:selectBtn];
        _selectImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"GC_subject_unselected" ]];
        _selectImage.userInteractionEnabled=YES;
        _selectImage.frame = CGRectMake(16, 16, 40, 40);
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSelect)];
        [_selectImage addGestureRecognizer:tap];
        [selectBtn addSubview:_selectImage];
        
        UIImageView*lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,71,[UIScreen mainScreen].bounds.size.width,1)];
        //_headerImage.layer.cornerRadius = (iPhone4 ? 40:47)*autoSizeScaleX/2.0f;
        lineImageView.clipsToBounds = YES;
        lineImageView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:lineImageView];
        
        
    }
    return self;
}
-(void)tapSelect
{
    if(_delegate&&[_delegate respondsToSelector:@selector(selectTap:)]){
        [_delegate selectTap:_cellM];
    }
}
-(void)setData:(PaymentModel*)m
{
    _cellM = m;
    _headerImage.image = [UIImage imageNamed:m.imageStr];
    _nameLabel.text = m.paymentNameStr;
    if(m.isSelect){
        _selectImage.image = [UIImage imageNamed:@"GC_subject_selected"];
    }else{
        _selectImage.image = [UIImage imageNamed:@"GC_subject_unselected"];
    }
}


@end
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end
#define tabbarviewHeight 70
#define WeiXinPayString @"微信支付"
#define ZhiFuBaoString @"支付宝"
@implementation ViewController
{
    NSString*_money;
    UITableView*_tableView;
    NSMutableArray*_dataSourceArr;//数据源
    PaymentModel*_selectedPaymentM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"付款" ;
    _money = @"0.01";
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel*payStyleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 44, [UIScreen mainScreen].bounds.size.width, 55)];
    payStyleLabel.font = [UIFont boldSystemFontOfSize:25];
    payStyleLabel.textColor=[UIColor blackColor];
    payStyleLabel.textAlignment = NSTextAlignmentLeft;
    payStyleLabel.text = @"付款方式";
    [self.view addSubview:payStyleLabel];
    
    UIView*tabbarView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-tabbarviewHeight, [UIScreen mainScreen].bounds.size.width, tabbarviewHeight)];
    tabbarView.backgroundColor=[UIColor grayColor];
    [self.view addSubview:tabbarView];
    UILabel*payTotalNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 110, 30)];
    payTotalNumLabel.font = [UIFont systemFontOfSize:20];
    payTotalNumLabel.textColor=[UIColor blackColor];
    payTotalNumLabel.textAlignment = NSTextAlignmentLeft;
    payTotalNumLabel.text = @"支付总额：";
    [tabbarView addSubview:payTotalNumLabel];
    
    UILabel*payNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(payTotalNumLabel.frame), 20, 80, 30)];
    payNumLabel.font = [UIFont systemFontOfSize:20];
    payNumLabel.textColor=[UIColor blackColor];
    payNumLabel.textAlignment = NSTextAlignmentLeft;
    payNumLabel.text = [NSString stringWithFormat:@"¥ %.2f",[_money floatValue]];
    [tabbarView addSubview:payNumLabel];
    
    UIButton*payBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    payBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-80-15, 13, 80, 44);
    [payBtn setTitle:@"去支付" forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payBtn.backgroundColor = [UIColor orangeColor];
    [payBtn addTarget:self action:@selector(payBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [tabbarView addSubview:payBtn];
    
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(payStyleLabel.frame), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-CGRectGetMaxY(payStyleLabel.frame)-tabbarviewHeight)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    //数据源
    _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    for(int i=0;i<2;i++){
        PaymentModel*pm = [[PaymentModel alloc]init];
        if(i==0){
            pm.imageStr = @"zhifubao";
            pm.paymentNameStr = ZhiFuBaoString;
            pm.isSelect = YES;
            _selectedPaymentM = pm;//默认第一个选中
        }
        if(i==1){
            pm.imageStr = @"weixin";
            pm.paymentNameStr = WeiXinPayString;
            pm.isSelect = NO;
        }
        [_dataSourceArr addObject:pm];
        
    }
    
}
#pragma mark 点击去支付
-(void)payBtnClick
{
    //微信，支付宝支付
    if([_selectedPaymentM.paymentNameStr isEqualToString:WeiXinPayString]){
        [self gotoWeiXinPay];
    }
    if([_selectedPaymentM.paymentNameStr isEqualToString:ZhiFuBaoString]){
        [self gotoZhiFuBaoPay];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark tableview datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSourceArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentCell*cell = [tableView dequeueReusableCellWithIdentifier:@"PAYMENTCELL"];
    if(!cell){
        cell = [[PaymentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PAYMENTCELL"];
    }
    PaymentModel*m = _dataSourceArr[indexPath.row];
    cell.delegate = self;
    [cell setData:m];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PaymentModel*m = _dataSourceArr[indexPath.row];
    [self handleSelectModel:m];
    
}
-(void)handleSelectModel:(PaymentModel*)tmp
{
    NSMutableArray*a = [NSMutableArray arrayWithCapacity:0];
    for(int i=0;i<_dataSourceArr.count;i++){
        PaymentModel*tmpM = _dataSourceArr[i];
        if([tmpM isEqual:tmp]){
            tmpM.isSelect = YES;
            _selectedPaymentM = tmpM;
        }else{
            tmpM.isSelect = NO;
        }
        [a addObject:tmpM];
    }
    _dataSourceArr =a;
    [_tableView reloadData];
}
#pragma mark PaymentCellDelegate
-(void)selectTap:(PaymentModel *)tmp
{
    [self handleSelectModel:tmp];
}

#pragma mark 微信支付
-(void)gotoWeiXinPay
{
    NSLog(@"%@:%@",WeiXinPayString,_money);
    NSString *res = [self jumpToBizPay];
    if( ![@"" isEqual:res] ){
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"支付失败" message:res delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alter show];
    }
    
}

-(NSString *)jumpToBizPay {
    
    //============================================================
    // V3&V4支付流程实现
    // 注意:参数配置请查看服务器端Demo
    // 更新时间：2015年11月20日
    //============================================================
    NSString *urlString   = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
    //解析服务端返回json数据
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if ( response != nil) {
        NSMutableDictionary *dict = NULL;
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        
        NSLog(@"url:%@",urlString);
        if(dict != nil){
            NSMutableString *retcode = [dict objectForKey:@"retcode"];
            if (retcode.intValue == 0){
                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                
                //调起微信支付
                PayReq* req             = [[PayReq alloc] init];
                req.partnerId           = [dict objectForKey:@"partnerid"];
                req.prepayId            = [dict objectForKey:@"prepayid"];
                req.nonceStr            = [dict objectForKey:@"noncestr"];
                req.timeStamp           = stamp.intValue;
                req.package             = [dict objectForKey:@"package"];
                req.sign                = [dict objectForKey:@"sign"];
                [WXApi sendReq:req];
                //日志输出
                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                return @"";
            }else{
                return [dict objectForKey:@"retmsg"];
            }
        }else{
            return @"服务器返回错误，未获取到json对象";
        }
    }else{
        return @"服务器返回错误";
    }
}

#pragma mark 支付宝支付
-(void)gotoZhiFuBaoPay{
    NSLog(@"%@:%@",ZhiFuBaoString,_money);
    //重要说明
    //这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
    //真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
    //防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *appID = @"2016102002252582";
    NSString *privateKey = @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBALNcaJjDvAXbGkkwDABVODUTlPWpaX8J3Km8KrJgLQhStDeCEORhf1PRfNoITkovdgLb5Qd0mWfwmHCGJHr8gIFuv3yrh9JbEXT6Tj8KndQbXQBVuqwUc12FIbQ7i0cmSuKQ04EKBlGQ54Ns/834On4gmeuHHPqZP3nqG8bVZ2iLAgMBAAECgYEAqXnGp5pDfnECTGdm36Wmf5hqJxoVweEqrQNMgNGZm4SyHsT6eyGY8zU9uLMibryb0KXAqiPFlE3lbGWD8OXH8XAJHU94fdXKkKlXR7T1xdzabuCDLGnD4BhaZ+OxyljJobQ42VBQ2H1GE/53IzqxalucNz6HMBXLVhs1x3TgOuECQQDbZtmcRyk9ApjSxETzUk7SvOZRYb7VAcjLKYE8+SQQvJ2fFV7R7hCXH0sJgsznwmGX2Ap1ObKHIwwctJOlhI67AkEA0Uewq6gBjB7yoKAC2IvyNn8WnnjhBhQhuIhvQos/5FLZTH+9maczgrtlOE/ZcLktQqmVhX+XRlaz4VaBBAq4cQJBAIH62qzVE79LTJKBKIAmoQAEXUaVa+Lxna2OtzwSNaWcuJzIolYofbeqGGBYF2CuLfcxTHDKb9PTlZdj+5yxfYUCQQC7//PEcHtbXZ3GD5ge4bDnpcky+RHkPQeB1wZjt+XgfVB5eTNgqaQLZ75pFMoXijIPdXo9X74MUOzsm6HweJTxAkAVGfAhpWiISEzJ8sK6eb32hwbTVIoE6h9Tkcuf8ES1g0RZGkOtTGX9awNoAEzHEfMFIcZm+OAOSxztiGoCXJUB";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([appID length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少appId或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    
    // NOTE: app_id设置
    order.app_id = appID;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type设置
    order.sign_type = @"RSA";
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    order.biz_content.body = @"我是测试数据";
    order.biz_content.subject = @"1";
    order.biz_content.out_trade_no = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", 0.01]; //商品价格
    
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderInfo];
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"alisdkdemo";//@"alisdkdemo";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
    
}

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

@end
