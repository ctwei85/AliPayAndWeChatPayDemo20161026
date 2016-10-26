//
//  ViewController.h
//  iii
//
//  Created by lianchuang-hw on 16/10/25.
//  Copyright © 2016年 hw. All rights reserved.
//

//#import <UIKit/UIKit.h>

@interface PaymentModel : NSObject
@property(nonatomic,copy)NSString*imageStr;
@property(nonatomic,copy)NSString*paymentNameStr;
@property(nonatomic,assign)BOOL isSelect;
@end

@protocol PaymentCellDelegate <NSObject>

-(void)selectTap:(PaymentModel*)tmp;

@end
@interface PaymentCell : UITableViewCell
-(void)setData:(PaymentModel*)m;
@property(nonatomic,assign)id<PaymentCellDelegate>delegate;
@end
@interface ViewController : UIViewController<PaymentCellDelegate>
@end
