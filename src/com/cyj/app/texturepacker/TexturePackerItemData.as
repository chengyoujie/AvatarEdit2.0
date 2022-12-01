package com.cyj.app.texturepacker
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.data.PathInfo;
	import com.cyj.app.view.common.Alert;
	import com.cyj.app.view.unit.data.MovieData;
	import com.cyj.utils.Log;
	import com.cyj.utils.images.PNGEncoder;
	import com.cyj.utils.load.ResData;
	import com.cyj.utils.load.ResLoader;
	
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class TexturePackerItemData
	{
		public var dirPath:String;
		public var onComplete:Function;
		public var onError:Function;
		private var _data:MovieData;
		private var _pathInfo:PathInfo;
		private var _isComplete:Boolean= false;
		private var _outPath:String;
		private var _type:int = 0;
		private var _typeParam:Number = 0;
		private var _fileName:String;
		private var _onComplete:Function;
		private var _loadNum:int = 0;
		private var _curLoadNum:int = 0;
		
		public function TexturePackerItemData(dirPath:String, onComplete:Function, onError:Function, pathInfo:PathInfo)
		{
			this.dirPath = dirPath;
			this.onComplete = onComplete;
			this.onError = onError;
			_pathInfo = pathInfo;
			_isComplete = false;
			var saveFileName:String = _pathInfo.fileName;
			if(_pathInfo.actName)
				saveFileName = saveFileName+"/"+saveFileName + "_"+_pathInfo.actName+"_"+_pathInfo.dirName;
			_outPath = ToolsApp.data.outPath+"/"+(_pathInfo.addDirName?_pathInfo.addDirName:"")+"/"+saveFileName;
			_outPath = _outPath.replace(/\/+/gi, "\\").replace(/\\+/gi, "\\");
			_data = new MovieData();
		}
		
		public function setParam(type:int, param:Number):void{
			_type = type;
			_typeParam= param;
		}
		
		public function startLoad(fileName:String, onComplete:Function):void{
			_fileName = fileName;
			_onComplete = onComplete;
			_loadNum = 2;
			if(_type==1)_loadNum += (_typeParam-1)*2;
			ToolsApp.loader.loadSingleRes(ToolsApp.CMD_WORK_PATH+"/"+fileName+".json", ResLoader.TXT, handleDataLoaded, null, handleLoadError);
			ToolsApp.loader.loadSingleRes(ToolsApp.CMD_WORK_PATH+"/"+fileName+".png", ResLoader.IMG, handleImageLoaded, null, handleLoadError);
			if(_type==1)
			{
				for(var i:int=1; i<_typeParam; i++)
				{
					ToolsApp.loader.loadSingleRes(ToolsApp.CMD_WORK_PATH+"/"+fileName+"_"+i+".json", ResLoader.TXT, handleDataLoaded, null, handleLoadError, i);
					ToolsApp.loader.loadSingleRes(ToolsApp.CMD_WORK_PATH+"/"+fileName+"_"+i+".png", ResLoader.IMG, handleImageLoaded, null, handleLoadError, i);
				}
			}
		}
		
		private function handleLoadError(res:ResData=null, msg:String=null):void
		{
			Alert.show("打包临时文件加载错误"+res.resPath+" 信息：");
			_curLoadNum++;
			checkEnd();
		}
		
		public function handleDataLoaded(res:ResData):void{
			var jsonData:Object = JSON.parse(res.data);
			Log.log("打包配置加载完毕"+dirPath);
			var data:String = res.data;
			var childIndex:int = res.param;
			var json:Object = JSON.parse(data);
			var keyArr:Array = [];
			var idx:int = childIndex;
			var regNum:RegExp = new RegExp(/.*?(\d+)/gi);
			var isAllHasNum:Boolean = true;
			for(var key:String in json.frames)
			{
				var frame:Object = json.frames[key];
				var item:Object = frame.frame;
				var ox:int;
				var oy:int;
				ox = frame.spriteSourceSize.x - frame.sourceSize.w/2;
				oy = frame.spriteSourceSize.y - frame.sourceSize.h/2;
				var numStr:String = key.replace(/\D/gi, "");
				if(isAllHasNum){
					isAllHasNum = numStr.length>0;
				}
				keyArr.push({"key":key, num:int(numStr), "x":item.x, "y":item.y, "w":item.w, "h":item.h, "ox":ox, "oy":oy, rotated:frame.rotated, childIndex:childIndex})
			}
			if(isAllHasNum){
				keyArr.sortOn("num", Array.NUMERIC);	
			}else{
				keyArr.sortOn("key");			
			}
			for(var i:int=0; i<keyArr.length; i++)
			{
				var subItem:Object = keyArr[i];
				trace(subItem.key);
				_data.addMainTexture(idx, subItem.x, subItem.y, subItem.w, subItem.h, subItem.ox, subItem.oy, subItem.rotated, subItem.childIndex);
				if(_type ==1)
				{
					idx += _typeParam;
				}else{
					idx ++;
				}
			}
			if(json.meta.scale!=1)
			{
				_data.scale = json.meta.scale;
			}
			if(_type == 1)
			{
				_data.imgLen = _typeParam;
			}
			_curLoadNum ++;
			checkEnd();
		}
		
		public function handleImageLoaded(res:ResData):void
		{
			Log.log("打包图片加载完毕"+dirPath);
			var img:BitmapData = res.data as BitmapData;
			var childIndex:int = res.param;
			var pngByte:ByteArray = PNGEncoder.encode(img);
			var imgPath:String =_outPath+".png";
			if(childIndex>0)
			{
				imgPath = _outPath+"_"+childIndex+".png";
			}
			ToolsApp.file.saveByteFile(imgPath, pngByte);
			ToolsApp.cmdOper(File.applicationDirectory.nativePath+"/bin/pngquant --nofs --force --ext .png "+imgPath, " PNG_ENCODING "+_pathInfo.fileName);
			_curLoadNum ++;
			checkEnd();
		}
		
		private function checkEnd():void
		{
			if(_curLoadNum>=_loadNum)
			{
				ToolsApp.data.addMovie(outPath+".json");
				_isComplete = true;
				if(_onComplete != null)
				{
					_onComplete();
					ToolsApp.file.saveFile(_outPath+".json", _data.toJson());
				}
				if(onComplete!= null)
				{
					onComplete();
				}
			}
		}
		
		public function get outPath():String
		{
			return _outPath;
		}
		
		
		public function handleError():void
		{
			_isComplete = true;
			if(onError!=null)
			{
				onError();
			}
		}
		
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
	}
}