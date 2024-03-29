package com.cyj.app.view.common
{
	
	
	import flash.media.H264Level;
	
	import morn.core.handlers.Handler;

	public class Alert
	{
		private static var view:AlertPanel = new AlertPanel();
		public static var ALERT_OK:int = 1;//0001
		public static var ALERT_CANCLE:int = 2;//0010
		public static var ALERT_OK_CANCLE:int = 3;//0011
		private static var _alertDataList:Array = [];
		private static var _isShow:Boolean = false;
		public function Alert()
		{
		}
		
		public static function show(content:String, title:String="提示", showBtn:int=1, clickBtn:Function=null, okLabel:String="确定", cancleLabel:String="取消", param:Object=null):void
		{
			_alertDataList.push(new AlertData(content, title, showBtn, clickBtn, okLabel, cancleLabel, param));
			if(!_isShow)
				showView();
		}
		
		private static function showView():void
		{
			if(_alertDataList.length == 0)
			{
				if(App.stage.contains(view))
					App.stage.removeChild(view);
				_isShow = false;
				return;
			}
			var alertData:AlertData = _alertDataList.shift();
			App.stage.addChild(view);
			view.x = (App.stage.stageWidth-view.width)/2;
			view.y = (App.stage.stageHeight-view.height)/2;
			setData(alertData);
			_isShow = true;
		}
		
		public static function closeAll():void
		{
			_alertDataList.length = 0;
			showView();
		}
		
		public static function close():void
		{
			showView();
		}
		
		
		private static function setData(alertData:AlertData):void
		{
			if(alertData)
			{
				view.ui.txtContent.text = alertData.content;
				view.ui.txtTitle.text = alertData.title?alertData.title:"提示";
				view.ui.btnOK.clickHandler = new Handler(function():void{showView();alertData.execClickFun(ALERT_OK)});
				view.ui.btnCancle.clickHandler = new Handler(function():void{showView();alertData.execClickFun(ALERT_CANCLE)});
				view.ui.btnClose.clickHandler = new Handler(showView);
				if(alertData.showBtn == ALERT_OK_CANCLE)
				{
					view.ui.btnOK.x = 75;
					view.ui.btnCancle.x = 178;
				}else{
					view.ui.btnOK.x = 130;
					view.ui.btnCancle.x= 130;
				}
				view.ui.btnOK.label = alertData.okLabel;
				view.ui.btnCancle.label = alertData.cancleLabel;
				view.ui.btnOK.visible = (alertData.showBtn & ALERT_OK)!=0;
				view.ui.btnCancle.visible = (alertData.showBtn&ALERT_CANCLE)!=0;
			}else{
				showView();
			}
		}
	}
}

import morn.core.handlers.Handler;

class AlertData{
	
	public var content:String;
	public var title:String;
	public var showBtn:int=3;
	public var clickBtn:Function;
	public var okLabel:String;
	public var cancleLabel:String;
	public var param:Object;
	
	public function AlertData($content:String, $title:String="提示", $showBtn:int=3, $clickBtn:Function=null, $okLabel:String="确定", $cancleLabel:String="取消", param:Object=null)
	{
		content = $content;
		title = $title;
		showBtn = $showBtn;
		clickBtn = $clickBtn;
		okLabel = $okLabel;
		cancleLabel = $cancleLabel;
		this.param = param;
	}
	
	public function execClickFun(btn:int):void
	{
		if(clickBtn!=null)
		{
			if(param)
				clickBtn.apply(this, [btn, param]);
			else
				clickBtn.apply(this, [btn]);
		}
	}
}