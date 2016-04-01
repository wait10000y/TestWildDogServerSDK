//
//  ViewController.m
//  TestWildDogServerSDK
//
//  Created by wsliang on 16/3/30.
//  Copyright © 2016年 wsliang. All rights reserved.
//

#import "ViewController.h"
#import <Wilddog/Wilddog.h>

#import "UIView+Additions.h"
#import "UUInputAccessoryView.h"


@interface ViewController ()

@property (nonatomic,weak) IBOutlet UITextField *inputText;
@property (nonatomic ,weak) IBOutlet UITextView *showText;

@property (nonatomic) NSMutableString *showString;
@property (nonatomic) Wilddog *mServer;

@property (nonatomic) NSString *baseUrl;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 创建引用
  if (!_mServer) {
    self.showString = [NSMutableString new];
//    _mServer = [[Wilddog alloc] initWithUrl:@"https://wsliang.wilddogio.com"];
  }
  
  [self serverAddObserver:_mServer];
  
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if (!(self.baseUrl.length>0)) {
    [self showInputAlertView];
  }
  
}

-(void)showInputAlertView
{
  UIAlertView *alertView = [self.view showAlertViewInput:@"请输入URL地址" content:nil input:UIAlertViewStylePlainTextInput choseBlock:^(BOOL isOK, NSString *textStr, NSString *pwdStr) {
    if(isOK && textStr.length>0){
      self.mServer = [[Wilddog alloc] initWithUrl:textStr];
      if (self.mServer) {
        [self serverAddObserver:self.mServer];
        self.baseUrl = textStr;
      }else{
        self.baseUrl = nil;
        [self showInputAlertView];
      }
    }else{
      // show error
//      [self.view showAlertView:@"错误提示:" withContent:@"未正确输入服务器地址"];
      [self showInputAlertView];
    }
  }];
  UITextField *t1 = [alertView textFieldAtIndex:0];
  t1.text = @"https://wsliang.wilddogio.com";
}

-(void)serverAddObserver:(Wilddog *)theServer
{
  [theServer observeEventType:WEventTypeValue andPreviousSiblingKeyWithBlock:^(WDataSnapshot *snapshot, NSString *prevKey) {
    [self showMessage:[NSString stringWithFormat:@"observeEventValue_Sibling: prevKey:%@ , data:[ %@:%@ ] \r\n",prevKey,snapshot.key,snapshot.value] isAppend:YES];
  } withCancelBlock:^(NSError *error) {
    [self showMessage:[NSString stringWithFormat:@"observeEventValue_Sibling: error:%@ \r\n",error] isAppend:YES];
  }];
  
  [theServer observeEventType:WEventTypeValue withBlock:^(WDataSnapshot *snapshot) {
    [self showMessage:[NSString stringWithFormat:@"observeEventValue: data:[ %@:%@ ] \r\n",snapshot.key,snapshot.value] isAppend:YES];
  } withCancelBlock:^(NSError *error) {
    [self showMessage:[NSString stringWithFormat:@"observeEventValue: error:%@ \r\n",error] isAppend:YES];
  }];
  
  // 只调用一次
  [theServer observeSingleEventOfType:WEventTypeValue withBlock:^(WDataSnapshot *snapshot) {
    [self showMessage:[NSString stringWithFormat:@"observeSingleEventValue: data:[ %@:%@ ] \r\n",snapshot.key,snapshot.value] isAppend:YES];
  } withCancelBlock:^(NSError *error) {
    [self showMessage:[NSString stringWithFormat:@"observeSingleEventValue: error:%@ \r\n",error] isAppend:YES];
  }];
}

-(void)serverRemoveAllObserver:(Wilddog*)theServer
{
  [theServer removeAllObservers];
}


-(void)showMessage:(NSString *)theMsg isAppend:(BOOL)isAppend
{
  if (isAppend) {
    [self.showString appendFormat:@"\r\n%@",theMsg?:@""];
  }else{
    [self.showString setString:theMsg?:@""];
  }
  self.showText.text = self.showString;
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


/*
 
 101 清除屏幕
 102 上一节点
 子节点
 删除当前节点
 清除全部
 添加一个节点
 删除一个节点
 查询 by key
 查询 by value
 
 */
-(IBAction)actionOperations:(UIButton*)sender
{
  switch (sender.tag) {
    case 100:
    {
      [UUInputAccessoryView showBlock:^(NSString *contentStr) {
        self.inputText.text = contentStr;
      }];
    } break;
    case 101: // 清除屏幕
    {
      [UUInputAccessoryView showBlock:^(NSString *contentStr) {
        self.inputText.text = contentStr;
      }];
//      self.showText.text = nil;
      self.inputText.text = nil;
      [self showMessage:@"清屏完成完成" isAppend:NO];
    } break;
    case 102: // 上一节点
    {
      Wilddog *pNode = [_mServer parent];
      if (_mServer != pNode) {
         [self showMessage:@"切换到上一节点完成" isAppend:NO];
        [self serverRemoveAllObserver:_mServer];
        [self serverAddObserver:pNode];
        _mServer = pNode;
      }else{
         [self showMessage:@"当前节点已是根节点" isAppend:YES];
      }
      
    } break;
    case 103: // 子节点
    {
      NSString *nodeName = self.inputText.text;
      Wilddog *cNode;
      if (nodeName.length>0) {
        cNode = [_mServer childByAppendingPath:nodeName];
        [self showMessage:@"已切换子节点" isAppend:NO];
        [self serverRemoveAllObserver:_mServer];
        [self serverAddObserver:cNode];
        _mServer = cNode;
      }else{
        // no node
        [self showMessage:@"未输入子节点名称" isAppend:YES];
      }
    } break;
    case 104: // 删除当前节点
    {
      NSString *nodeName = self.inputText.text;
      if (nodeName.length>0) {
        Wilddog *cNode = [_mServer childByAppendingPath:nodeName];
        if (cNode) {
          [cNode removeValueWithCompletionBlock:^(NSError *error, Wilddog *ref) {
            if (error) {
              [self showMessage:[NSString stringWithFormat:@"删除错误 %@",error] isAppend:YES];
            }else{
              [self showMessage:@"删除成功" isAppend:YES];
            }
          }];
        }
      }else{
        [_mServer removeValueWithCompletionBlock:^(NSError *error, Wilddog *ref) {
          NSLog(@"---- removeValue: error:%@ , ref:%@ -----",error,ref);
          if (error) {
            [self showMessage:[NSString stringWithFormat:@"删除错误 %@",error] isAppend:YES];
          }else{
            [self showMessage:@"删除自节点成功" isAppend:NO];
            self.mServer = ref.parent;
            [self serverAddObserver:self.mServer];
          }
        }];
      }
      

    } break;
    case 105: // 清除全部
    {
      
      Wilddog *rNode = [[Wilddog alloc] initWithUrl:@"https://wsliang.wilddogio.com"];
      [rNode removeValueWithCompletionBlock:^(NSError *error, Wilddog *ref) {
        if (error) {
          [self showMessage:[NSString stringWithFormat:@"清除内容错误 %@",error] isAppend:YES];
        }else{
          [self showMessage:@"清除全部数据 完成" isAppend:NO];
          if (self.mServer) {
            [self serverRemoveAllObserver:self.mServer];
          }
          [self serverAddObserver:rNode];
          self.mServer = rNode;
        }
      }];
      
    } break;
    case 106: // 添加一个节点
    {
      NSString *nodeName = self.inputText.text;
      Wilddog *cNode;
      if (nodeName.length>0) {
        cNode = [_mServer childByAppendingPath:nodeName];
        [self showMessage:@"添指定加子节点 成功" isAppend:NO];
      }else{
        cNode = [_mServer childByAutoId];
        [self showMessage:@"添加子节点 成功" isAppend:NO];
      }
      [self serverRemoveAllObserver:_mServer];
      [self serverAddObserver:cNode];
      [cNode setValue:@""];
      _mServer = cNode;
      
      
      
      
      
      
      
//      Wilddog *child1 = [_mServer childByAutoId];
//      [child1 setValue:@"child1_value1"];
//      
//      NSDictionary *alanisawesome = @{
//                                      @"full_name" : @"Alan Turing",
//                                      @"date_of_birth": @"June 23, 1912"
//                                      };
//      NSDictionary *gracehop = @{
//                                 @"full_name" : @"Grace Hopper",
//                                 @"date_of_birth": @"December 9, 1906"
//                                 };
//      Wilddog *usersRef = [child1 childByAppendingPath: @"testChild"];
//      NSDictionary *users = @{
//                              @"alanisawesome": alanisawesome,
//                              @"gracehop": gracehop
//                              };
//      [usersRef setValue: users];
      
    } break;
    case 107: // 修改 节点 内容
      
    {
      NSString *text = self.inputText.text?:@"";
      [self.mServer setValue:text withCompletionBlock:^(NSError *error, Wilddog *ref) {
        if (error) {
          [self showMessage:[NSString stringWithFormat:@"修改内容错误 %@",error] isAppend:YES];
        }else{
          [self showMessage:@"内容修改完成" isAppend:YES];
        }
      }];

      
//      NSDictionary *gracehop = @{
//                                 @"full_name" : @"Grace Hopper",
//                                 @"date_of_birth": @"December 9, 1906"
//                                 };
//      [_mServer updateChildValues:gracehop withCompletionBlock:^(NSError *error, Wilddog *ref) {
//        
//      }];
      
    } break;
    case 108: // 查询 by key
      
    {
       [self showMessage:@"查询 by key" isAppend:YES];
      NSString *text = self.inputText.text;
      if (text.length>0) {
        [self.mServer queryEqualToValue:nil childKey:text];
      }
//      WQuery *query2 = [_mServer queryLimitedToLast:2];
//      self.showText.text = [NSString stringWithFormat:@"%@ , %@ " , query1,query2];
    } break;
    case 109: // 查询 by value
    {
       [self showMessage:@"查询 by value" isAppend:YES];
      NSString *text = self.inputText.text;
      if (text.length>0) {
        [self.mServer queryEqualToValue:text];
      }
//      WQuery *query1 = [_mServer queryStartingAtValue:@"full"];
      
    } break;
    
    default:
      break;
  }
  
}







@end
