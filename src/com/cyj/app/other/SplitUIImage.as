package com.cyj.app.other
{
	import com.cyj.app.ToolsApp;
	import com.cyj.utils.Log;
	import com.cyj.utils.images.JPGEncoder;
	import com.cyj.utils.images.PNGEncoder;
	import com.cyj.utils.load.ResData;
	import com.cyj.utils.load.ResLoader;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class SplitUIImage
	{
		private var _json:Object;
		private var _img:BitmapData;
		private var _url:String;
		
		public function SplitUIImage(url:String)
		{
			_url = url;
			Log.log("开始导出资源: "+url);
			ToolsApp.loader.loadSingleRes(url, ResLoader.TXT, handleJSONLoaded);
			ToolsApp.loader.loadSingleRes(url.replace(".json", ".png"), ResLoader.IMG, handleImageLoaded);
		}
		
		private function handleJSONLoaded(res:ResData):void
		{
			_json = JSON.parse(res.data);
			checkStartSplit();
		}
		
		private function handleImageLoaded(res:ResData):void
		{
			_img = res.data;
			checkStartSplit();
		}
		
		private function checkStartSplit():void
		{
			var outUrl:String = _url.replace(".json", "");
			if(_json && _img)
			{
				for(var key:String in _json.frames)
				{
					var item:Object = _json.frames[key];
					var lastIndex:int = key.lastIndexOf("_");
					var fileType:String = key.substr(lastIndex+1);
					var outFile:String = outUrl+"/"+(lastIndex!=-1?(key.substr(0, lastIndex)+"."+fileType):key);
					var bd:BitmapData = new BitmapData(item.w, item.h, true, 0);
					bd.copyPixels(_img, new Rectangle(item.x, item.y, item.w, item.h), new Point());
					var byte:ByteArray;
					if(fileType == "jpg")
					{
						byte = new JPGEncoder().encode(bd);
					}else{
						byte = PNGEncoder.encode(bd);
					}
					
					ToolsApp.file.saveByteFile(outFile, byte);
					Log.log("导出完毕："+outFile);
				}
				Log.log("导出完毕");
			}
		}
	}
}