package com.cyj.app.view.view
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.data.PathInfo;
	import com.cyj.app.data.ResType;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.view.common.Alert;
	import com.cyj.app.view.ui.app.AppMainUI;
	import com.cyj.app.view.unit.Movie;
	import com.cyj.utils.Log;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flashx.textLayout.formats.Direction;
	
	import morn.core.handlers.Handler;
	
	public class AppMainView extends AppMainUI
	{
		private var _dragObj:Movie;
		
		public function AppMainView()
		{
			super();
		}
		
		public function initView():void{
			appName.text = ToolsApp.config.appName;
			btnViewLog.clickHandler = new Handler(handleOpenLog);
			btnOpenWeb.clickHandler = new Handler(handleOpenGame);
			boxDir.visible = false;
			ToolsApp.texturePacker.init();
			leftView.initView();
			App.stage.addEventListener(Event.RESIZE, handleSizeChange);
			handleSizeChange();
			leftView.addEventListener(MouseEvent.MOUSE_DOWN, handleStartDrag, true);
		}
		
		
		
		public function onDropFiles(files:Array):void//拖入文件
		{
			var file:File;
			for(var i:int=0; i<files.length; i++)
			{
				checkOnFile(files[i]);	
			}
		}
		
		private function handleOpenLog():void
		{
			var file:File = new File(ToolsApp.data.logPath);
			if(file.exists)
				file.parent.openWithDefaultApplication();
			else{
				Alert.show("日志目录不存在:"+ToolsApp.data.logPath);
			}
		}
		
		private function handleOpenGame():void
		{
			var request:URLRequest = new URLRequest(encodeURI(ToolsApp.data.gameURL));
			request.method = "get";
			navigateToURL(request,"_blank");
		}
		
		
		private function checkOnFile(file:File):void
		{
			if(file.isDirectory)//文件夹的形式
			{
				searchPackFileDir(file, file.nativePath);
			}else{//一堆文件则判断
				if(file.extension == "json")//导入预览功能
				{
					ToolsApp.data.addMovie(file.nativePath);
				}else if(isImage(file.extension)){
					
				}
			}
		}
		
		private function handleSizeChange(e:Event=null):void
		{
			var sw:int = App.stage.stageWidth;
			var sh:int = App.stage.stageHeight;
			var gap:int = 5;
			leftView.resize(leftView.width, sh-leftView.y-txtLog.height);
			rightView.resize(rightView.width, sh-rightView.y-txtLog.height);
			rightView.x = sw - rightView.width;
			moviePlayer.resize(sw-leftView.width-rightView.width - 2*gap, sh-moviePlayer.y-txtLog.height);
			moviePlayer.x = leftView.width + gap;
			boxTools.x = sw - boxTools.width - 10;
			
			
			img_bg.width = sw;
			img_bg.height = sh;
			appName.width = sw;
			appName.x = 0;
			
			txtLog.width = sw;
			txtLog.y = sh-txtLog.height;
			txtAuth.y = sh - txtAuth.height;
			txtAuth.x = sw - txtAuth.width;
		}
		
		private function searchPackFileDir(file:File, parentDir:String):void
		{
			if(!file.isDirectory)return;
			var arr:Array = file.getDirectoryListing();
			var hasAllImg:Boolean = true;
			for(var i:int=0; i<arr.length; i++)
			{
				var f:File = arr[i];
				if(f.isDirectory)
				{
					if(f.getDirectoryListing().length==0)continue;
					searchPackFileDir(f, parentDir);
					hasAllImg = false;
				}else if(!isImage(f.extension)  && !f.isHidden){//兼容  远程文件的目录中含有Thumbs.db
					hasAllImg = false;
				}
			}
			if(hasAllImg)
			{
				var pathInfo:PathInfo = new PathInfo()
				var avaterDir:String = "";
				pathInfo.fileName = file.name;
				var parentDirPathDeep:int = 0;//
				if(isDirName(file.name))
				{
					if(file.nativePath == parentDir)//拖入的是dir目录
					{
						parentDirPathDeep = 3;//
					}
					pathInfo.dirName = file.name;
					if(file.parent && isActName(file.parent.name))
					{
						pathInfo.actName = file.parent.name;
						if(file.parent.nativePath == parentDir)//拖入的是dir目录
						{
							parentDirPathDeep = 2;//
						}
						if(file.parent.parent)
						{
							pathInfo.fileName = file.parent.parent.name;
							if(file.parent.parent.nativePath == parentDir)//拖入的是dir目录
							{
								parentDirPathDeep = 1;
							}
							if(parentDirPathDeep == 1)
							{
								avaterDir = "\\"+pathInfo.actName+"\\"+pathInfo.dirName;
							}else if(parentDirPathDeep == 2)
							{
								avaterDir = "\\"+pathInfo.dirName;;
							}else if(parentDirPathDeep == 3)
							{
//								avaterDir = "\\"+pathInfo.fileName+"\\"+pathInfo.actName+"\\"+pathInfo.dirName;
							}else{
								avaterDir = "\\"+pathInfo.fileName+"\\"+pathInfo.actName+"\\"+pathInfo.dirName;
							}
						}
					}
				}
				if(parentDir)
				{
					pathInfo.addDirName = file.nativePath.replace(parentDir, "").replace(avaterDir, "");
				}
				ToolsApp.texturePacker.run(file.nativePath, handleGet, handleError, pathInfo);	
			}
		}
		
		private function isActName(fileName:String):Boolean
		{
			return fileName.indexOf("act")!=-1 
									||fileName.indexOf("stand")!=-1 
									||fileName.indexOf("move")!=-1 
									||fileName.indexOf("hit")!=-1 
									||fileName.indexOf("die")!=-1//角色avatar
		}
		
		private function isDirName(fileName:String):Boolean
		{
			var dir:int = int(fileName);
			if(fileName == dir.toString())
				return dir>=0&&dir<=7;
			return false;
		}
		
		private function isImage(fileType:String):Boolean
		{
			if(!fileType)return false;
			 fileType = fileType.toLocaleLowerCase();
			 return fileType=="png"
				 || fileType == "jpg"
				 || fileType == "jpeg"
		}
		
		
		
		private function handleGet():void
		{
			trace("complete");	
		}

		
		private function handleError():void
		{
			trace("error");	
		}
		
		private function handleStartDrag(e:MouseEvent):void
		{
			if(e.target is FileItem)
			{
				var fileItem:FileItem = e.target as FileItem;
				var fileItemData:Object = fileItem.dataSource;
				if(fileItemData.isDirectory)return;//点击的是文件加不做处理
				if(fileItemData.type == ResType.JSON)
				{
					var movie:Movie = new Movie();
					_dragObj = movie;
					movie.setData(fileItemData.path);
					_dragObj.x = e.stageX;
					_dragObj.y = e.stageY;
					App.stage.addChild(_dragObj);
				}
			}else{
				return;
			} 
			App.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDragMove);
			App.stage.addEventListener(MouseEvent.MOUSE_UP, handleStopDrag);
			App.stage.addEventListener(Event.ENTER_FRAME, handleRefushMovie);
		}
		
		private function handleRefushMovie(e:Event):void
		{
			if(_dragObj)
			{
				_dragObj.render();
			}else{
				App.stage.removeEventListener(Event.ENTER_FRAME, handleRefushMovie);
			}
		}
		
		
		private function handleDragMove(e:MouseEvent):void
		{
			if(!_dragObj)return;
			_dragObj.x  = e.stageX;
			_dragObj.y  = e.stageY;
		}
		private function handleStopDrag(e:MouseEvent):void
		{
			if(!_dragObj)return;
			var stageX:int = e.stageX;
			var stageY:int = e.stageY;
			var rect:Rectangle = moviePlayer.getBounds(App.stage);
			if(rect.contains(stageX, stageY))
			{
				ToolsApp.data.addMovie(_dragObj.jsonPath);
//				var offsetRect:Rectangle = centerPanel.content.scrollRect;
//				var ox:int = stageX - rect.x + offsetRect.x;
//				var oy:int = stageY - rect.y+ offsetRect.y;
//				var dropRole:Role = centerView.getAddAvtRole(stageX, stageY);
//				if(_dragObj.parent)
//					_dragObj.parent.removeChild(_dragObj);
//				//				var edit:EditDisplayObject = centerView.addEditObj(_dragObj);//new EditDisplayObject(_dragObj as Avatar, centerView.editLayer);
//				if(_dragObj is Avatar)
//				{
//					var avt:Avatar = _dragObj as Avatar;
//					avt.x = ox;
//					avt.y = oy;
//					centerView.addAvatar(avt, dropRole);
//					//					ToolsApp.projectData.avaterRes = avt.avaterRes;
//					//					centerView.editAvater(avt.avaterRes, ox, oy);
//					//					leftView.editAvater(avt.avaterRes);
//					//					avt.dispose();
//				}else{
//					_dragObj.x = ox;
//					_dragObj.y = oy;
//					centerView.addAvatar(_dragObj, dropRole);
//					//					centerView.addChild(_dragObj);
//				}
//				centerPanel.refresh();
			}
			_dragObj.dispose();
			_dragObj = null;
			App.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragMove);
			App.stage.removeEventListener(MouseEvent.MOUSE_UP, handleStopDrag);
			App.stage.removeEventListener(Event.ENTER_FRAME, handleRefushMovie);
		}
		
	}
}