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
		/**字图片的个数**/
		public var imgLen:int=1;
		
		
		public function MovieData()
		{
		}
		
		public function addMainTexture(id:int,x:int, y:int, w:int, h:int, ox:int, oy:int, rotated:Boolean, childIndex:int):void
		{
//			sub[index] = [x, y, w, h, ox, oy];
			var subData:SubTextureData = new SubTextureData(x, y, w, h, ox, oy, rotated, childIndex);
			sub[id] = subData;
//			len = sub.length;
			refushMaxRect();
		}
		
		
		public function parseTexturePackData(json:Object):void {
			var keyArr:Array = [];
			var idx:int = 0;
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
				keyArr.push({"key":key, num:int(numStr), "x":item.x, "y":item.y, "w":item.w, "h":item.h, "ox":ox, "oy":oy, rotated:frame.rotated, childIndex:0})
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
				addMainTexture(idx, subItem.x, subItem.y, subItem.w, subItem.h, subItem.ox, subItem.oy, subItem.rotated, subItem.childIndex);
				idx ++;
			}
			if(json.meta.scale!=1)
			{
				scale = json.meta.scale;
			}
		}
		
		private function refushMaxRect():void
		{
			_maxRect.setEmpty();
			_maxRect.x = Number.MAX_VALUE;
			_maxRect.y = Number.MAX_VALUE;
			for(var i:int=0; i<sub.length; i++)
			{
				var subData:SubTextureData = sub[i];
				if(!subData)continue;
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
		
		public function resetOffset():void
		{
			if(sub.length==0)return;
			var offX:Number = -sub[0].ox;//-sub[0].w/2;
			var offY:Number = -sub[0].oy;//-sub[0].h/2;
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
			if(json.subtexture)//旧版的数据格式
			{
				var newJson:Object = {};
				newJson.speed = json.speed;
				newJson.sub = [];
				for(var key:String in json.subtexture)
				{
					var spliteItem:Object = json.subtexture[key];
//					var spliteArr:Array = newJson.sub[int(key)-1] = [];
					newJson.sub.push(6, spliteItem[0], spliteItem[1], spliteItem[2], spliteItem[3], spliteItem[4], spliteItem[5]);
				}
				json = newJson;
			}else if(json.frames && json.file)//图集的
			{
				var newJson2:Object = {};
				newJson2.speed = json.speed || 12;
				newJson2.sub = [];
				for(var key2:String in json.frames)
				{
					var spliteItem2:Object = json.frames[key2];
					//x:int, y:int, w:int, h:int, ox:int, oy:int, rotated:Boolean
//					var offsetX2:int = (spliteItem2.sourceW - spliteItem2.w)/2;
//					var offsetY2:int = (spliteItem2.sourceH - spliteItem2.h)/2;
					newJson2.sub.push(6, spliteItem2.x, spliteItem2.y, spliteItem2.w, spliteItem2.h, spliteItem2.offX, spliteItem2.offY);
				}
				json = newJson2;
			}else if(json.frames && json.meta && json.meta.app){//texturepacker打包的
//				var newJson3:Object = {};
//				newJson3.speed =  12;
//				newJson3.sub = [];
//				for(var key3:String in json.frames)
//				{
//					var spliteItem3:Object = json.frames[key3];
//					var splitInfo3:Object = 
//					newJson2.sub.push(6, spliteItem3.x, spliteItem3.y, spliteItem3.w, spliteItem3.h, spliteItem3.offX, spliteItem3.offY);
//				}
//				json = newJson2;
				var mv:MovieData = new MovieData();
				mv.parseTexturePackData(json);
				return mv;
			}
			if(!json.sub)
			{
				return null;
			}
			
			var movie:MovieData = new MovieData();
			var arr:Array = json.sub;
			var i:int=0;
			var idx:int = 0;
			while(arr.length>i)
			{
				var size:int = arr[i];
				var rotated:Boolean = false;
				var childIndex:int = 0;
				if(size>=7)
					rotated = arr[i+7];
				if(size>=8)
					childIndex = arr[i+8];
				if(size>=6)
					movie.addMainTexture(idx, arr[i+1], arr[i+2], arr[i+3], arr[i+4], arr[i+5], arr[i+6], rotated, childIndex);
				if(size<0)
				{
					Alert.show("当前json数据格式有误");
					Log.log("当前json数据格式有误");
					break;
				}
				idx ++;
				i = i+ size+1;//加上size自身占位
			}
			movie.speed = json.speed;
			movie.imgLen = json.imgLen||1;
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
					params[6]=(sub.rotated?1:0);
				if(sub.childIndex>0)
					params[7]=(sub.childIndex);
//				var size:int = 6;//数据的长度
				obj.sub.push(params.length);
				obj.sub = obj.sub.concat(params);
			}
			if(this.scale!=1)
			{
				obj.scale = this.scale;
			}
			if(this.imgLen>1)obj.imgLen = this.imgLen;
			return JSON.stringify(obj);
		}
		
	}
}