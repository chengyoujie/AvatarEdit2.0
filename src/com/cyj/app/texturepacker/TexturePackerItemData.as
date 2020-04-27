package com.cyj.app.texturepacker
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.data.PathInfo;
	import com.cyj.app.view.unit.data.MovieData;
	import com.cyj.utils.images.PNGEncoder;
	
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class TexturePackerItemData
	{
		public var dirPath:String;
		public var onComplete:Function;
		public var onError:Function;
		private var _data:MovieData;
		private var _img:BitmapData;
		private var _pathInfo:PathInfo;
		private var _isComplete:Boolean= false;
		private var _outPath:String;
		
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
		}
		
		public function handleDataLoaded(data:*):void{
//			_data = DataAdapter.converData(data, "json");
			_data = new MovieData();
			var json:Object = JSON.parse(data);
//			var idx:int = 0;//如果图片没有按照规则命名则使用默认的index
//			var regNum:RegExp = /[0-9]/gi;
			var keyArr:Array = [];
			for(var key:String in json.frames)
			{
				var frame:Object = json.frames[key];
				var item:Object = frame.frame;
				var ox:int;
				var oy:int;
//				if(frame.rotated)
//				{
//					ox = frame.spriteSourceSize.y - frame.sourceSize.w/2;
//					oy = frame.spriteSourceSize.x - frame.sourceSize.h/2;
//				}else{
					ox = frame.spriteSourceSize.x - frame.sourceSize.w/2;
					oy = frame.spriteSourceSize.y - frame.sourceSize.h/2;
//				}
				keyArr.push({"key":key, "x":item.x, "y":item.y, "w":item.w, "h":item.h, "ox":ox, "oy":oy, rotated:frame.rotated})
			}
			keyArr.sortOn("key");
			for(var i:int=0; i<keyArr.length; i++)
			{
				var subItem:Object = keyArr[i];
				_data.addSubTexture(subItem.x, subItem.y, subItem.w, subItem.h, subItem.ox, subItem.oy, subItem.rotated);
			}
			if(json.meta.scale!=1)
			{
				_data.scale = json.meta.scale;
			}
			checkEnd();
		}
		
		public function handleImageLoaded(data:Object):void
		{
			_img = data as BitmapData;
			checkEnd();
		}
		
		private function checkEnd():void
		{
			if(_data && _img)
			{
				_isComplete = true;
				if(onComplete!= null)
				{
					//todo 放到onComplete中
					
					ToolsApp.file.saveFile(_outPath+".json", _data.toJson());
					var pngByte:ByteArray = PNGEncoder.encode(_img);
					var imgPath:String =_outPath+".png";
					ToolsApp.file.saveByteFile(imgPath, pngByte);
					ToolsApp.cmdOper(File.applicationDirectory.nativePath+"/bin/pngquant --nofs --force --ext .png "+imgPath, " PNG_ENCODING "+_pathInfo.fileName);
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