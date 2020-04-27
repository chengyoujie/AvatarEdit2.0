package com.cyj.app.utils
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	
	import morn.core.components.TextInput;
	
	public class BindData
	{
		private var _bindUI:*;
		private var _uiProp:String;
		private var _data:Object;
		private var _prop:String;
		private var binded:Boolean = false;
		private var _onChangeFun:Function;
		private var _checkFun:Function;
		private var _listenerChange:Boolean = true;
		/***ui到data的转换**/
		private var _setDataFun:Function;
		/**data到ui的转换**/
		private var _getDataFun:Function;
		
		public function BindData(bindUI:*, prop:String, uiProp:String="text", onChangeFun:Function=null, checkFun:Function=null, setDataFun:Function=null, getDataFun:Function=null)
		{
			_bindUI = bindUI;
			_uiProp = uiProp;
			_prop = prop;
			_checkFun = checkFun;
			_onChangeFun = onChangeFun;
			_setDataFun = setDataFun;
			_getDataFun = getDataFun;
		}
		
		public function bind(data:Object):void
		{
			if(binded)
				unBind();
			_data = data;
			binded = true;
			initData();
			//			_text.addEventListener(FocusEvent.FOCUS_OUT, handleFouceOut);
			_bindUI.addEventListener(Event.CHANGE, handleFouceOut);
		}
		
		public function initData():void
		{
			if(_data==null)return;
			if(_getDataFun ==null)
				_bindUI[_uiProp] = _data[_prop];
			else
				_bindUI[_uiProp] = _getDataFun(_data[_prop]);
		}
		
		public function unBind():void
		{
			if(_bindUI)
			{
				//				_text.removeEventListener(FocusEvent.FOCUS_OUT, handleFouceOut);
				_bindUI.removeEventListener(Event.CHANGE, handleFouceOut);
			}
			_data = null;
			binded = false;
			//			_onChangeFun = null;
		}
		
		private function handleFouceOut(e:Event):void
		{
			if(!_listenerChange)return;
			if(_checkFun != null)
			{
				if(!_checkFun(_bindUI[_uiProp]))//检测是否可以使用
				{
					_listenerChange = false;
					_bindUI[_uiProp] = _data[_prop];
					_listenerChange = true;
					return;
				}
			}
			if(_data)
			{
				if(_setDataFun == null)
					_data[_prop] = _bindUI[_uiProp];
				else
					_data[_prop] = _setDataFun(_bindUI[_uiProp]);
			}
			if(_onChangeFun !=null)
				_onChangeFun.apply();
		}
		
		
		
		public static function toBind(list:Vector.<BindData>, data:Object):void
		{
			for(var i:int=0; i<list.length; i++)
			{
				list[i].bind(data);
			}
		}
		
		public static function unBind(list:Vector.<BindData>):void
		{
			for(var i:int=0; i<list.length; i++)
			{
				list[i].unBind();
			}
		}
		
	}
}