package com.cyj.app
{
	import com.cyj.app.data.AppData;
	import com.cyj.app.data.ProjectConfig;
	import com.cyj.app.data.ToolsConfig;
	import com.cyj.app.event.EventManager;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.texturepacker.TexturePacker;
	import com.cyj.app.view.common.Alert;
	import com.cyj.app.view.ui.common.AlertUI;
	import com.cyj.app.view.view.AppMainView;
	import com.cyj.utils.Log;
	import com.cyj.utils.XML2Obj;
	import com.cyj.utils.cmd.CMDManager;
	import com.cyj.utils.cmd.CMDStringParser;
	import com.cyj.utils.file.FileManager;
	import com.cyj.utils.ftp.SimpleFTP;
	import com.cyj.utils.load.LoaderManager;
	import com.cyj.utils.load.ResData;
	import com.cyj.utils.load.ResLoader;
	import com.cyj.utils.md5.MD5;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragManager;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import morn.core.events.UIEvent;

	/**
	 * 应用入口
	 * @author cyj
	 * 
	 */	
	public class ToolsApp
	{
		public static var view:AppMainView;
		public static var loader:LoaderManager = new LoaderManager();
		public static var file:FileManager = new FileManager();
		public static var config:ToolsConfig;
		public static var event:EventManager = new EventManager();
		public static var projects:Vector.<ProjectConfig> = new Vector.<ProjectConfig>();
		public static var data:AppData = new AppData();
		public static var focus:DisplayObject;
		
		public static var texturePacker:TexturePacker = new TexturePacker();
//		public static var localCfg:LocalConfig = new LocalConfig();
		
		public static var VERSION:String = "1.0.1";
		public static const CMD_WORK_PATH:String = File.applicationDirectory.nativePath+"/res/temp";

		public function ToolsApp()
		{
		}
		
		public static function start():void
		{
			loader.loadManyRes(["res/comp.swf", "res/guidecomp.swf"], handleSwfLoaded, null, handleLoadError);
		}
		
		private static function handleSwfLoaded():void
		{
			view = new AppMainView();
			App.stage.addChild(view);
			startDoDrag();
			exitAppEvent();
			var file:File = new File(data.localJsonPath);
			if(file.exists)
			{
				loader.loadSingleRes(file.nativePath, ResLoader.TXT, handleLocalJsonLoaded);
			}else{
				handleLocalJsonLoaded();
			}
		}
		
		private static function handleLocalJsonLoaded(res:ResData=null):void
		{
			if(res)
			{
				data.setLocalJson(res.data);
			}
			loader.loadSingleRes("res/config.xml", ResLoader.TXT, handleConfigLoaded, null, handleLoadError);
		}
		
		
		private static function handleConfigLoaded(res:ResData):void
		{
			XML2Obj.registerClass("toolsconfig", ToolsConfig);
//			XML2Obj.registerClass("project", ProjectConfig);
//			XML2Obj.registerClass("local", LocalConfig);
			config = XML2Obj.readXml(res.data) as ToolsConfig;
			VERSION = config.version;
//			loader.loadSingleRes(config.projectpath, ResLoader.TXT, handleProjectConfigLoaded, null, handleLoadError);
			App.stage.nativeWindow.title = config.title+"@"+VERSION;
			
			Log.initLabel(view.txtLog);
			
			try{
				var file:File = new File(CMD_WORK_PATH);
				if(!file.exists)
				{
					file.createDirectory();
				}
				CMDManager.startCmd(CMD_WORK_PATH);
				CMDManager.addParser(new CMDStringParser(), handleCmdResult);
				//				ToolsApp.cmdOper("net use \\\\"+ToolsApp.config.upip+" "+ToolsApp.config.uppass+" /user:\""+ToolsApp.config.upname+"\"");
			}catch(e:*){
				Alert.show("当前不支持CMD命令行\n"+e);
			}
			
			view.initView();
			
			
			Log.log("系统启动成功");
		}
		
//		private static function handleProjectConfigLoaded(res:ResData):void
//		{
//			
//			var pros:XML = new XML(res.data);
//			var plist:XMLList = pros.project;
//			for(var i:int=0; i<plist.length(); i++)
//			{
//				var p:ProjectConfig = XML2Obj.readXml(plist[i]) as ProjectConfig;
//				p.initVar();
//				projects.push(p);
//			}
//			loader.loadSingleRes("res/local.xml", ResLoader.TXT, handleLocalConfigLoaded, null, handleLoadError);
//			
//		}
		
//		private static function handleLocalConfigLoaded(res:ResData):void
//		{
//			
//			localCfg = XML2Obj.readXml(res.data) as LocalConfig;
//			Log.initLabel(view.txtLog);
//			view.initView();
//			try{
//				CMDManager.startCmd();
//				CMDManager.addParser(new CMDStringParser(), handleCmdResult);
////				ToolsApp.cmdOper("net use \\\\"+ToolsApp.config.upip+" "+ToolsApp.config.uppass+" /user:\""+ToolsApp.config.upname+"\"");
//			}catch(e:*){
//				Alert.show("当前不支持CMD命令行\n"+e);
//			}
//			Log.log("系统启动成功");
////			loader.loadSingleRes(config.versionconfig, ResLoader.TXT, handleVersionConfigLoaded, null, null);
//		}
		
		private static function handleVersionConfigLoaded(res:ResData):void
		{
			var versiontxt:String = res.data;
			var versionReg:RegExp = /[\n\r]*\[(.*?)\][\n\r]*/gi;
			var obj:Object= {};
			var arr:Array= versionReg.exec(versiontxt);
			var lastIndex:int = 0;
			var lastProp:String;
			while(arr)
			{
				if(lastProp)
				{
					obj[lastProp] = versiontxt.substring(lastIndex, versionReg.lastIndex-arr[0].length);
					lastIndex = versionReg.lastIndex;
				}
				lastProp = arr[1];
				lastIndex = versionReg.lastIndex;
				arr = versionReg.exec(versiontxt);
			}
			if(lastProp)
			{
				obj[lastProp] = versiontxt.substring(lastIndex, versiontxt.length);
			}
			if(obj.version != VERSION)
			{
				Alert.show("<font color='#FF0000'>当前版本<font color='#00FF00'>"+VERSION+"</font>最新版本:<font color='#00FF00'>"+obj.version+"</font></font>\n<p align='left'><font color='#FFFF00'>更新内容</font>\n"+obj.desc.replace(/\r\n/gi, "\n")+"</p>", "更新提醒");
			}
			
		}
		
//		private static var logMsgReg:RegExp = /-{72,}\s+r([0-9]+)\s+\|\s+(\w+)\s+\|\s+([0-9]{4}-[0-9]{2}-[0-9]{2}\s+[0-9]{2}:[0-9]{2}:[0-9]{2}).*?\s+Changed paths:\s+(.*[^\s][\r\n])+/gi;
		
		
		public static function getTimeId(day:String, time:String):Number
		{
			var n:Number = 0;
			var days:Array = day.split("-");
			var nstr:String = "";
			if(days.length>0)
				nstr = getLenStr(days[0], 4, "", "0");
			if(days.length>1)
				nstr += getLenStr(days[1], 2);
			if(days.length>2)
				nstr += getLenStr(days[2], 2);
			var times:Array = time.split(":");
			if(times.length>0)
				nstr += getLenStr(times[0], 2, "", "0");
			if(times.length>1)
				nstr += getLenStr(times[1], 2, "", "0");
			if(times.length>2)
				nstr += getLenStr(times[2], 2, "", "0");
			n = Number(nstr);
			return n;
		}
		public static function getLenStr(str:String, len:int, addstr:String="0", endstr:String=""):String
		{
			if(!addstr)
				addstr = " ";
			for(var i:int=str.length; i<len; i++)
			{
				str = addstr+str+endstr;
			}
			return str;
		}
		
//		public static function svnOper(oper:String, endTag:String=null, isClear:Boolean=true):void
//		{
//			if(oper)
//			{
//				var svnop:String  = ToolsApp.config.svnpath+" "+oper+" --username chengyoujie --password chengyoujie   --no-auth-cache";
//			}
//			cmdOper(svnop, endTag, isClear);
//		}
		
		public static function cmdOper(oper:String, endTag:String=null, isClear:Boolean=true):void
		{
			if(oper)
			{
				CMDManager.runStringCmd(oper);
//				Log.log(oper);
			}
			if(endTag)
				CMDManager.runStringCmd("|TAG|"+endTag+"|TAG|");
			if(isClear)
				cmdClear();
		}
		
		public static function cmdClear():void
		{
			CMDManager.runStringCmd("cls");
		}
		
		private static var _catchCmd:String = "";
		private static function handleCmdResult(type:int, cmd:String):void
		{
			_catchCmd += cmd;
			cmd = cmd.replace(/--username .*? --password .*?\s+/gi, "--username ****** --password ****** ");
			trace(cmd);
			Log.log(cmd, false);
			
//			var reg2:RegExp = /Export complete/gi;
//			var arr2:Array = reg2.exec(cmd);
//			while(arr2)
//			{
//				cmd = cmd.substr(reg2.lastIndex);
//				view.expleteComplete();
//				arr2 = reg2.exec(cmd);
//			}
//			
//			
//			var reg3:RegExp = /Saving file (.*?\.webp)/gi;
//			var arr3:Array = reg3.exec(cmd);
//			while(arr3)
//			{
//				cmd = cmd.substr(reg3.lastIndex);
//				view.expleteOneWebP(arr3[1]);
//				arr3 = reg3.exec(cmd);
//			}
			
			
			if(_catchCmd.indexOf("|TAG|") != -1)
			{
//				view.outzip();
//				var reg:RegExp = /[\S\s]*?\s*\|TAG\|(.*?)\|TAG\|[\S\s]*?\s*$/;
				var reg:RegExp = /\|TAG\|(.*?)\|TAG\|/gi;
				var arr:Array = reg.exec(_catchCmd);
				while(arr)
				{
//					_catchCmd.replace(arr[1], "");
					var data:String = _catchCmd.substr(0, reg.lastIndex);
					_catchCmd = _catchCmd.substr(reg.lastIndex);
					event.post(arr[1], data);
					arr = reg.exec(_catchCmd);
					cmdClear();
				}
//				event.dispatchEvent(new UIEvent( cmd.replace(/[\S\s]*?\s*\|TAG\|(.*?)\|TAG\|[\S\s]*?\s*$/gi, "$1")      ));//   /^\s*.*?\|TAG\|(.*?)\|TAG\|.*?\s*$/gi
			}
		}
		
		 
//		private static function handleGetFtpList(res:*, msg:*):void
//		{
//			Log.log(res);
//		}
		
		
		public static function handleLoadError(res:ResData, msg:*):void
		{
			Alert.show("资源加载错误"+res.resPath+"\nerror : "+msg, "加载错误");
		}
		
		private static function startDoDrag():void
		{
			App.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, handleDragEnter);
			App.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, handleDropEvent);
			App.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, handleDropExit);
		}
		
		private static function handleDragEnter(e:NativeDragEvent):void
		{
			var clipBoard:Clipboard = e.clipboard;
			if(clipBoard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{
				NativeDragManager.acceptDragDrop(App.stage);
			}
		}
		
		private static  function handleDropEvent(e:NativeDragEvent):void
		{
			var clip:Clipboard = e.clipboard;
			if(clip.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{
				var arr:Array = clip.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				view.onDropFiles(arr);
//				var file:File;
//				for(var i:int=0; i<arr.length; i++)
//				{
//					file = arr[i];
//					if(file.isDirectory==false)
//					{
//						var type:String = file.name.substr(file.name.lastIndexOf("."));
//						if(type == ".dat")
//						{
//							
//						}
//					}
//					trace("拖入文件"+file.name);
					//file.namefile.name.lastIndexOf(".")
//				}
			}
		}
		
		private static  function handleDropExit(e:NativeDragEvent):void
		{
			//trace("Exit Drop");
		}
		
		private static function exitAppEvent():void
		{
			App.stage.nativeWindow.addEventListener(Event.CLOSING, handleCloseApp);
		}
		
		private static function handleCloseApp(e:Event):void
		{
			Log.log("退出系统");
			Log.refushLog();
			file.saveFile(data.localJsonPath, data.getLocalJson());
			//取消默认关闭
//			e.preventDefault();
//			NativeApplication.nativeApplication.activeWindow.visible = true;
			//关闭
			App.stage.nativeWindow.close();
		}
		
		
	}
}