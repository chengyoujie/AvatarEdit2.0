package com.cyj.app.view.unit
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.view.common.Alert;
	import com.cyj.app.view.unit.data.MovieData;
	import com.cyj.app.view.unit.data.SubTextureData;
	import com.cyj.utils.Log;
	import com.cyj.utils.load.ResData;
	import com.cyj.utils.load.ResLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	public class Movie extends Sprite
	{
		public static const EVNET_POS_CHANGE:String = "posChagne";
		public static const EVENT_FRAME_CHANGE:String = "frameChange";
		
		private var _jsonFilePath:String;
		private var _data:MovieData;
//		private var _img:BitmapData;
		private var _bd:Bitmap;
		private var _frame:int;
		private var _cacheImg:Object;
		private var _selectBorder:Shape;
		private var _fileName:String;
//		private var _centerShape:Shape;
		private var _pause:Boolean = false;
		private var _imgs:Object = {};//index->img:BitmapData
		
		public function Movie()
		{
			_selectBorder = new Shape();
			this.addChild(_selectBorder);
			_bd = new Bitmap();
			this.addChild(_bd);
			_selectBorder.alpha = 0;
			this.mouseChildren = false;
//			_centerShape = new Shape();
//			this.addChild(_centerShape);
//			_centerShape.graphics.clear();
//			_centerShape.graphics.beginFill(0x00ff00, 1);
//			_centerShape.graphics.drawCircle(-2, -2, 2);
//			_centerShape.graphics.endFill();
		}
		
		
		public function setData(jsonFilePath:String):void
		{
			_jsonFilePath = jsonFilePath;
			_data = null;
			_imgs = {};
			_frame = -1;
			_cacheImg = {};
			var file:File = new File(_jsonFilePath);
			_fileName = file.name.replace("."+file.extension, "");
			ToolsApp.loader.loadSingleRes(_jsonFilePath, ResLoader.TXT, handleDataLoaded, null, handleLoadError);
			ToolsApp.loader.loadSingleRes(_jsonFilePath.replace(".json", ".png"), ResLoader.IMG, handleImageLoaded, null, handleLoadError);
		}
		
		private function handleLoadError(res:ResData, msg:String):void
		{
			Alert.show("加载错误"+res.resPath+"\n"+msg);
			Log.log("加载错误"+res.resPath+"\n"+msg);
		}
		
		
		private function handleDataLoaded(res:ResData):void
		{
			_data = MovieData.getMovieData(res.data);
			if(!_data)
			{
				Alert.show("数据格式不正确"+_jsonFilePath);
				ToolsApp.data.removeMovie(this);
				return;
			}
			if(_data.imgLen>1)
			{
				for(var i:int=1; i<_data.imgLen; i++)	
				{
					ToolsApp.loader.loadSingleRes(_jsonFilePath.replace(".json", "_"+i+".png"), ResLoader.IMG, handleImageLoaded, null, handleLoadError, i);
				}
			}
			refushSelectRect();
			if(_data && _data.scale && _data.scale!=1)
			{
				_bd.scaleX = _bd.scaleY = 1/_data.scale;
			}else{
				_bd.scaleX = _bd.scaleY = 1;
			}
		}
		
		private function handleImageLoaded(res:ResData):void
		{
			var childIndex:int = res.param;
			_imgs[childIndex] = res.data as BitmapData;
		}
		
		public function get jsonPath():String
		{
			return _jsonFilePath;
		}
		
		public function get fileName():String
		{
			return _fileName;
		}
		
		public function render():void
		{
			if(!_data || !_imgs || _pause)return;//等数据完成后在开始
			var now:int = getTimer();
			var frame:int = now%(1000/_data.speed*_data.sub.length)/(1000/_data.speed);
			setFrame(frame);
		}
			
		public function setFrame(frame:int):void
		{
			if(frame<0)
			{
				frame = _data.sub.length - 1;
			}else{
				frame = frame%_data.sub.length;
			}
			var frameData:SubTextureData = _data.sub[frame];
			var img:BitmapData = _imgs[frameData.childIndex];
			if(!img)return;
			if(!_cacheImg[frame] && frameData)
			{	//0, x,  1.y   2w, 3,h   4,ox  5oy
				var bd:BitmapData;
//				bd.copyPixels(_img, new Rectangle(frameData.x, frameData.y, frameData.w, frameData.h), new Point());
				if(frameData.rotated)
				{
					bd = new BitmapData(frameData.w, frameData.h, true, 0);
					var matrix:Matrix = new Matrix(0, -1, 1,0, -frameData.y, frameData.x+frameData.h);
//					matrix.translate(-frameData.y, frameData.x+frameData.h);
					bd.draw(img, matrix, null, null);
				}else{
					bd = new BitmapData(frameData.w, frameData.h, true, 0);
					bd.copyPixels(img, new Rectangle(frameData.x, frameData.y, frameData.w, frameData.h), new Point());
				}
				_cacheImg[frame] = bd;
			}
			_bd.bitmapData = _cacheImg[frame];
			if(frameData)
			{
				var scale:Number = 1;
				if(_data.scale)
					scale = 1/_data.scale;
				_bd.x = frameData.ox *scale;
				_bd.y = frameData.oy *scale;
			}
			if(_selectBorder.alpha)
			{
				refushSelectRect();
			}
			if(_frame != frame)
			{
				_frame = frame;
				this.dispatchEvent(new SimpleEvent(Movie.EVENT_FRAME_CHANGE, this));
			}
		}
		
		public function getFrameData(frame:int):SubTextureData{
			if(frame<0)
			{
				frame = _data.sub.length - 1;
			}else{
				frame = frame%_data.sub.length;
			}
			return _data.sub[frame];
		}
		
		public function set pause(value:Boolean):void
		{
			_pause = value;
		}
		
		public function get pause():Boolean
		{
			return _pause;
		}
		
		private function refushSelectRect():void
		{
			if(!_data)return;
			var scale:Number = 1/_data.scale
			var rect:Rectangle = _data.maxRect;
			_selectBorder.graphics.clear();
			_selectBorder.graphics.lineStyle(1, 0xffff00);
			_selectBorder.graphics.beginFill(0xffffff, 0.1);
			_selectBorder.graphics.drawRect(0, 0,rect.width*scale, rect.height*scale);
			_selectBorder.graphics.endFill();
			_selectBorder.x = rect.x*scale;
			_selectBorder.y = rect.y*scale;
		}
		
		public function get frame():int
		{
			return _frame;
		}
		
		public function get totalFrame():int
		{
			if(_data)
				return _data.sub.length;
			return 0;
		}
		
		public function getSubImg(frame:int):BitmapData
		{
//			if(frame<0)
//			{
//				frame = _data.sub.length - 1;
//			}else{
//				frame = frame%_data.sub.length;
//			}
			return _cacheImg[frame];
		}
		
		public function get data():MovieData
		{
			return _data;
		}
		
		private var _select:Boolean = false;
		public function set select(value:Boolean):void
		{
			_select = value;
			_selectBorder.alpha = _select?1:0;
			
		}
		public function get select():Boolean
		{
			return _select;
		}
		
		public function dispose():void
		{
			if(this.parent)
			{
				this.parent.removeChild(this);
			}
		}
		
		
	}
}