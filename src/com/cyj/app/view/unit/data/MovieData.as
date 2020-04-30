package com.cyj.app.view.unit.data
{
	import com.cyj.app.view.common.Alert;
	import com.cyj.utils.Log;
	
	import flash.geom.Rectangle;

	public class MovieData
	{
		public var sub:Array = [];//Vector.<SubTextureData> = new Vector.<SubTextureData>();
//		public var act:String;
//		public var len:int = 0;
		public var speed:int= 12;
		
		public var scale:Number = 1;
//		public var resName:String;
//		public var dir:int = 0;
//		private var _offX:int = 0;
//		private var _offY:int = 0;
		
		private var _maxRect:Rectangle = new Rectangle();
		
		
		public function MovieData()
		{
		}
		
		public function addSubTexture(x:int, y:int, w:int, h:int, ox:int, oy:int, rotated:Boolean):void
		{
//			sub[index] = [x, y, w, h, ox, oy];
			var subData:SubTextureData = new SubTextureData(x, y, w, h, ox, oy, rotated);
			sub.push(subData);
//			len = sub.length;
			refushMaxRect();
		}
		
		private function refushMaxRect():void
		{
			_maxRect.setEmpty();
			_maxRect.x = Number.MAX_VALUE;
			_maxRect.y = Number.MAX_VALUE;
			for(var i:int=0; i<sub.length; i++)
			{
				var subData:SubTextureData = sub[i];
				if(subData.ox<_maxRect.x)_maxRect.x = subData.ox;
				if(subData.oy<_maxRect.y)_maxRect.y = subData.oy;
				if(subData.w>_maxRect.width)_maxRect.width  = subData.w;
				if(subData.h>_maxRect.height)_maxRect.height = subData.h;
			}
		}
		
		public function get maxRect():Rectangle
		{
			return _maxRect;
		}
		
//		public function getFrameData(frame:int):SubTextureItemData
//		{
//			return sub[getKey(frame)];
//		}
		
//		public function getKey(frame:int):String
//		{
//			var keyIndex:String = this.dir+"";
//			if(frame<10)
//				keyIndex += "0"+frame;
//			else
//				keyIndex += frame;
//			return keyIndex;
//		}
		
//		public function set offX(value:int):void
//		{
//			_offX = value;
//			for(var i:int=0; i<sub.length; i++)
//			{
//				var item:SubTextureData = sub[i];
//				item.ox += offX;
//			}
//		}
//		
//		public function get offX():int
//		{
//			return _offX;
//		}
//		public function set offY(value:int):void
//		{
//			_offY = value;
//			for(var i:int=0; i<sub.length; i++)
//			{
//				var item:SubTextureData = sub[i];
//				item.oy += offY;
//			}
//		}
//		
//		public function get offY():int
//		{
//			return _offY;
//		}
		public function setOffSet(offX:int, offY:int):void
		{
			for(var i:int=0; i<sub.length; i++)
			{
				var item:SubTextureData = sub[i];
				item.ox += offX * this.scale;
				item.oy += offY * this.scale;
			}
			refushMaxRect();
		}
		
		
			
		public static function getMovieData(jsonStr:String):MovieData
		{
			var json:Object = JSON.parse(jsonStr);
			if(!json.sub)
			{
				return null;
			}
			var movie:MovieData = new MovieData();
			var arr:Array = json.sub;
			var i:int=0;
			while(arr.length>i)
			{
				var size:int = arr[i];
				var rotated:Boolean = false;
				if(size>=7)
					rotated = arr[i+7];
				if(size>=6)
					movie.addSubTexture(arr[i+1], arr[i+2], arr[i+3], arr[i+4], arr[i+5], arr[i+6], rotated);
				if(size<0)
				{
					Alert.show("当前json数据格式有误");
					Log.log("当前json数据格式有误");
					break;
				}
				i = i+ size+1;//加上size自身占位
			}
			movie.speed = json.speed;
			if(json.scale)
			{
				movie.scale = json.scale;
			}
			return movie;
		}
		
		public function toJson():String
		{
			var obj:Object = {};
			obj.speed = this.speed;
			obj.sub = [];
			for(var i:int=0; i<this.sub.length; i++)
			{
				var sub:SubTextureData = this.sub[i];
				var params:Array = [sub.x, sub.y, sub.w, sub.h, sub.ox, sub.oy];
				if(sub.rotated)
					params.push(sub.rotated?1:0);
//				var size:int = 6;//数据的长度
				obj.sub.push(params.length);
				obj.sub = obj.sub.concat(params);
			}
			if(this.scale!=1)
			{
				obj.scale = this.scale;
			}
			return JSON.stringify(obj);
		}
		
	}
}