package org.apache.cordova.command;

import com.iflytek.cloud.ErrorCode;
import com.iflytek.cloud.InitListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechUtility;
import com.iflytek.cloud.ui.RecognizerDialog;
import com.iflytek.cloud.ui.RecognizerDialogListener;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;

import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

public class CommandPlugin extends CordovaPlugin {

    private  String res = "" ;
    private CallbackContext callbackContext ;
    private RecognizerDialog mDialog = null ;
    private boolean bInitialized = false;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

    
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext ;
    
        if (action.equals("init")){
            
            if ( bInitialized ) {
                callbackContext.success("已初始化");
                return true;
            }
            
            int id = cordova.getActivity().getResources().getIdentifier("app_id", "string", cordova.getActivity().getPackageName());
            String appid = cordova.getActivity().getString(id) ;
            SpeechUtility utility = SpeechUtility.createUtility(cordova.getActivity(),"appid=" + appid);
           
            if ( utility != null ) {
                bInitialized = true;
                callbackContext.success("初始化成功");
            }else {
                bInitialized = false;
                callbackContext.error("初始化失败");
            }
            return true ;
        }else if (action.equals("talk")){
            
            if ( ! bInitialized ) {
                callbackContext.error("未初始化!");
                return true;
            }else{
                cordova.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        res = "";
                        showDialog();
                    }
                });
                return true ;
            }
        }else if (action.equals("destroy")){
            if (mDialog != null){
                mDialog.cancel();
                mDialog.destroy() ;
                mDialog = null;
            }
            return true ;
        }
        return false ;

    }

    private void showDialog(){

        
        mDialog = new RecognizerDialog(cordova.getActivity(), new InitListener() {
            @Override
            public void onInit(int code) {
                if(code != ErrorCode.SUCCESS){
                    callbackContext.error("初始化失败,错误码：" + code);
                }
            }
        });

        
        mDialog.setParameter(SpeechConstant.ENGINE_TYPE, "cloud");
        mDialog.setParameter(SpeechConstant.SUBJECT, "asr");

        mDialog.setListener(mRecognizerDialogListener);
        mDialog.show();
    }

    private RecognizerDialogListener mRecognizerDialogListener = new RecognizerDialogListener(){

        @Override
        public void onError(SpeechError arg0) {
            mDialog.cancel();
            callbackContext.error("error:" + arg0.getErrorCode());

        }

        @Override
        public void onResult(RecognizerResult result, boolean isLast) {
            res += parseIatResult(result.getResultString());
            if (isLast){
                callbackContext.success(res);
            }
        }

    };


    public String parseIatResult(String json) {
        StringBuffer ret = new StringBuffer();
        try {
            JSONTokener tokener = new JSONTokener(json);
            JSONObject joResult = new JSONObject(tokener);

            JSONArray words = joResult.getJSONArray("ws");
            for (int i = 0; i < words.length(); i++) {
                JSONArray items = words.getJSONObject(i).getJSONArray("cw");
                JSONObject obj = items.getJSONObject(0);
                ret.append(obj.getString("w"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ret.toString();
    }

    
    @Override
    public void onDestroy() {
        super.onDestroy();

        if (mDialog != null){
            mDialog.cancel();
            mDialog.destroy() ;
            mDialog = null;
        }
    }
}
