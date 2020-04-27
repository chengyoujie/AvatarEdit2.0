package com.cyj.app.utils
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.view.common.Alert;
	import com.cyj.utils.Log;
	import com.cyj.utils.cmd.CMDManager;
	
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public class SvnOper
	{
		private static var _operId:int = 0;
		private static var _operId2Fun:Dictionary = new Dictionary();
		public function SvnOper()
		{
		}
		
		
		public static function svnCommit(path:String, completeFun:Function):void
		{
			svnUpdata(path, function(success:Boolean):void{
				if(!success)
				{
					completeFun(false);
					return;
				}
				svnOper("commit  "+path +"  -m 特效编辑器上传", function (stdout:String):void{
					completeFun(true);
				});
			});
		}
		
		public static function svnUpdata(path:String, completeFun:Function):void
		{
			svnOper("stat "+path, function (stdout:String):void{
				if(checkConfilt(stdout,path)){completeFun(false);return;}
				svnOper("update "+path, function(stdout:String):void{
					if(checkConfilt(stdout, path)){completeFun(false);return;}
					completeFun(true);
				});
			});
		}
		
		private static function checkConfilt(stdout:String, path:String):Boolean
		{
			var cofReg:RegExp = /C\s+(.*?)\s*[\r\n]/g;
			var cofArr:Array = cofReg.exec(stdout);
			if(cofArr)
			{
				var rect:String = "";
				while(cofArr)
				{
					rect += cofArr[1];
					Log.log("<font color='#ff0000'>冲突文件： "+cofArr[1]+"</font>");
					cofArr = cofReg.exec(stdout);
				}
				if(path)
				{
					Alert.show("检测到有冲突文件，更新失败\n"+rect, "提示", Alert.ALERT_OK_CANCLE, handleClickConfiilt, "打开文件夹", "关闭", path);
				}else{
					Alert.show("检测到有冲突文件，更新失败\n"+rect);	
				}
				return true;
			}
			return false;
		}
		
		private static function handleClickConfiilt(del:int, param:String):void
		{
			if(del == Alert.ALERT_OK)
			{
				var file:File = new File(param);
				if(file.exists)
				{
					file.openWithDefaultApplication();
				}
			}
		}
		
		public static function svnOper(oper:String, completeFun:Function=null, isClear:Boolean=true):void
		{
			if(oper)
			{
				var svnop:String  = ToolsApp.config.svnpath+" "+oper;//+" --username chengyoujie --password chengyoujie   --no-auth-cache";
			}
			cmdOper(svnop, completeFun, isClear);
		}
		
		public static function cmdOper(oper:String, completeFun:Function=null, isClear:Boolean=true):void
		{
			if(oper)
			{
				CMDManager.runStringCmd(oper);
			}
			if(completeFun != null)
			{
				_operId ++;
				_operId2Fun[_operId] = completeFun;
				CMDManager.runStringCmd("|TAG|"+_operId+"|TAG|");
			}
			if(isClear)
				cmdClear();
		}
		
		
		private static var _catchCmd:String = "";
		public static function handleCmdResult(type:int, cmd:String):void
		{
			trace(cmd);
			_catchCmd += cmd;
			if(_catchCmd.indexOf("|TAG|") != -1)
			{
				var reg:RegExp = /\|TAG\|(.*?)\|TAG\|/gi;
				var arr:Array = reg.exec(_catchCmd);
				while(arr)
				{
					var data:String = _catchCmd.substr(0, reg.lastIndex);
					var stdout:String = _catchCmd.substr(0, reg.lastIndex);
					_catchCmd = _catchCmd.substr(reg.lastIndex);
					var fun:Function = _operId2Fun[arr[1]];
					if(fun != null)
					{
						fun.apply(null, [stdout]);
					}
					arr = reg.exec(_catchCmd);
					cmdClear();
				}
			}
		}
		
		public static function cmdClear():void
		{
			CMDManager.runStringCmd("cls");
		}
	}
}