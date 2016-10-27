#import "CommandPlugin.h"

@implementation CommandPlugin

-(void)init:(CDVInvokedUrlCommand*)command{
    _command = command ;
    
    if (bInit) {
        _pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"初始化成功"];
        [self.commandDelegate sendPluginResult:_pluginResult callbackId:_command.callbackId];
        
        return ;
    }
    
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    app_id = infoDictionary[@"CFBundleURLTypes"][@"app_id"];
    
    if(app_id == nil || app_id == NULL){
        _pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"找不到app_id"];
        [self.commandDelegate sendPluginResult:_pluginResult callbackId:_command.callbackId];
        return;
    }
    
    
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",app_id];
    
    [IFlySpeechUtility createUtility:initString];
    
    
    [self initRecognizer] ;
    
    bInit = true ;

    _pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"初始化成功"];
    [self.commandDelegate sendPluginResult:_pluginResult callbackId:_command.callbackId];
    
}


-(void)initRecognizer{
    
    if(_iflyRecognizerView == nil){
        
        view = [self getCurrentVC].view ;
        _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:view.center];
        
        _iflyRecognizerView.delegate = self ;
        
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        [_iflyRecognizerView setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
        
        [_iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        [_iflyRecognizerView setParameter:@"6000" forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        
       
        [_iflyRecognizerView setParameter: @"cloud" forKey:[IFlySpeechConstant ENGINE_TYPE]];
        
        
        [_iflyRecognizerView setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
    }
    
}


- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}


-(void)talk:(CDVInvokedUrlCommand*)command{
    _command = command ;
    
    if (!bInit) {
        _pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"未初始化"];
        [self.commandDelegate sendPluginResult:_pluginResult callbackId:_command.callbackId];
        
        return ;
    }
    text = @"" ;
    
    [_iflyRecognizerView start];
    
}


- (void)onResult: (NSArray *)resultArray isLast:(BOOL) isLast
{
    
    
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSDictionary *dic = resultArray[0];
    
    for (NSString *key in dic) {
        
        [result appendFormat:@"%@",key];
        
        NSString * resultFromJson =  [self stringFromABNFJson:result];
        
        [resultString appendString:resultFromJson];
        
    }
    text = [text stringByAppendingString:resultString];
    
    if (isLast) {
        
        NSLog(@"result is:%@",text);
        // Raymond: shall we callback here?
        //_pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:text];
        //[self.commandDelegate sendPluginResult:_pluginResult callbackId:_command.callbackId];
        
    }
    
    
    
}


-(NSString *)stringFromABNFJson:(NSString*)params
{
    
    if (params == NULL) {
        return nil;
    }
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:
                                [params dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    NSArray *wordArray = [resultDic objectForKey:@"ws"];
    for (int i = 0; i < [wordArray count]; i++) {
        NSDictionary *wsDic = [wordArray objectAtIndex: i];
        NSArray *cwArray = [wsDic objectForKey:@"cw"];
        
        NSDictionary *wDic = [cwArray objectAtIndex:0];
        NSString *str = [wDic objectForKey:@"w"];
        [tempStr appendString: str];
        
    }
    return tempStr;
}


- (void)onError: (IFlySpeechError *) error
{
    if (error.errorCode ==0 ) {
        if(text.length == 0){
            _pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"没有听见你说什么."];
            // shall call error callback
            [self.commandDelegate sendPluginResult:_pluginResult callbackId:_command.callbackId];
        }else{
            // Raymond: shall we callback in OnResult?
            _pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:text];
            [self.commandDelegate sendPluginResult:_pluginResult callbackId:_command.callbackId];
        }
        
    }
    else {
        // shall call error callback
        _pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:error.errorCode];
        [self.commandDelegate sendPluginResult:_pluginResult callbackId:_command.callbackId];
    }
    
}

-(void)destroy:(CDVInvokedUrlCommand*)command{
    
    _command = command ;
    
    if (_iflyRecognizerView != nil) {
        [_iflyRecognizerView cancel];
        _iflyRecognizerView = nil;
        bInit = false ;
    }
    
    _pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:_pluginResult callbackId:_command.callbackId];
    
    
}

@end
