//
//  CommandPlugin.h
//  Command
//
//  Created by wuxiaoqing on 16/9/29.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

#import "iflyMSC/IFlyMSC.h"

@interface CommandPlugin : CDVPlugin<IFlyRecognizerViewDelegate>
{
    CDVPluginResult *_pluginResult ;
    CDVInvokedUrlCommand *_command;
    
    UIView *view ;
    
    IFlyRecognizerView      *_iflyRecognizerView;
    
    NSString *text ;
    NSString *app_id ;
    
    //是否已初始化。
    Boolean bInit ;
    
    
}

@property (nonatomic, strong) NSString *grammarType; //语法类型

-(void)init:(CDVInvokedUrlCommand*)command;
-(void)talk:(CDVInvokedUrlCommand*)command;
-(void)destroy:(CDVInvokedUrlCommand*)command;

@end
