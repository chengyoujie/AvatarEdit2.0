package com.cyj.app.view.view
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.utils.BindData;
	import com.cyj.app.view.common.Alert;
	import com.cyj.app.view.ui.app.RightViewUI;
	import com.cyj.app.view.unit.Movie;
	import com.cyj.app.view.unit.data.MovieData;
	import com.cyj.app.view.unit.data.SubTextureData;
	import com.cyj.utils.Log;
	import com.cyj.utils.images.PNGEncoder;
	
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import morn.core.handlers.Handler;
	
	public class RightView extends RightViewUI
	{
		private var _bindData:Vector.<BindData> = new Vector.<BindData>();
		private var _bindMovie:Vector.<BindData> = new Vector.<BindData>();
		private var _lastSelectMovie:Movie;
		
		public function RightView()
		{
			super();
			btnSave.clickHandler = new Handler(handleSaveData);
			btnReSetZero.clickHandler = new Handler(handleReSetZero);
			btnOffsetZero.clickHandler = new Handler(handleOffsetZero);
			checkAutoScale.clickHandler = new Handler(handleAutoScaleChange);
			checkSplitImg.clickHandler = new Handler(handleSplitImgChange);
			checkAutoRotation.clickHandler = new Handler(handleAutoRotationChange);
			checkSaveDirStruct.clickHandler = new Handler(handleSaveDirStruct);
			_bindData.push(
				new BindData(inputSpeed, "speed", "text", handleSpeedChange),
				new BindData(txtScale, "scale")
				);
			_bindMovie.push(
				new BindData(txtFileName, "fileName"),
				new BindData(inputOffX, "x"),
				new BindData(inputOffY, "y"));
			ToolsApp.event.on(SimpleEvent.MOVIE_SELECT, handleMovieSelectChange);
			ToolsApp.event.on(SimpleEvent.MOVIE_POS_CHANGE, handleMoviePosChange);
			
			btnPlay.clickHandler = new Handler(handleMoviePlay);
			btnPre.clickHandler = new Handler(handleMoviePre);
			btnNext.clickHandler = new Handler(handleMovieNext);
			btnExportImg.clickHandler = new Handler(handleExportImage);
			btnExportSelectDir.clickHandler = new Handler(handleExportSelectDir);
			btnExportOpenDir.clickHandler = new Handler(handleExportOpenDir);
			checkExportImgScale.clickHandler = new Handler(handleExportImgScaleChange);
		}
		
		public function initView():void
		{
			checkAutoScale.selected = ToolsApp.data.autoScale;
			checkSplitImg.visible = !checkAutoScale.selected;
			checkSplitImg.selected = ToolsApp.data.splitImg;
			checkAutoRotation.selected = ToolsApp.data.autoRotation;
			checkSaveDirStruct.selected = ToolsApp.data.saveDirStruct;
			inputExportImg.text = ToolsApp.data.outImgPath;
			checkExportImgScale.selected = ToolsApp.data.outImgSaveScale;
			
		}
		
		
		public function resize(w:int, h:int):void
		{
			img_bg.width = w;
			img_bg.height = h;
			boxBottom.y = h- boxBottom.height;
		}
		
		private function handleSaveData():void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)
			{
				Alert.show("当前没有选中Movie");
				return;
			}
			movie.data.setOffSet(movie.x, movie.y);
			movie.x = 0;
			movie.y = 0;
			BindData.toBind(_bindMovie, movie);
			ToolsApp.file.saveFile(movie.jsonPath, movie.data.toJson());
		}
		
		private function handleReSetZero():void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)
			{
				Alert.show("当前没有选中Movie");
				return;
			}
			movie.data.resetOffset();
			movie.x = 0;
			movie.y = 0;
		}
		
		private function handleMovieSelectChange(e:SimpleEvent):void
		{
//			var data:Movie = e.data;
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)
			{
				BindData.unBind(_bindData);
				BindData.unBind(_bindMovie);
				txtTotalFrame.text = "";
				txtTotalTime.text = "";
				return;
			}
			if(_lastSelectMovie)
			{
				_lastSelectMovie.addEventListener(Movie.EVENT_FRAME_CHANGE, handleMovieFrameChange);
			}
			BindData.toBind(_bindData, movie.data);
			BindData.toBind(_bindMovie, movie);
			movie.addEventListener(Movie.EVENT_FRAME_CHANGE, handleMovieFrameChange);
			_lastSelectMovie = movie;
			txtTotalFrame.text = "/"+movie.data.sub.length;
			refushMovieState();
			handleSpeedChange();
			Log.log("选中 "+movie.jsonPath);
		}
		
		private function handleSpeedChange():void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)return;
			txtTotalTime.text = Math.round((1000/movie.data.speed*movie.data.sub.length)*100)/100+"ms";
		}
		
		private function handleMoviePosChange(e:SimpleEvent):void
		{
			var movie:Movie = e.data as Movie;
			if(!movie)return;
			var selectMovie:Movie = ToolsApp.data.selectMovie;
			if(movie != selectMovie)return;
			BindData.toBind(_bindMovie, selectMovie);
		}
		
		private function handleOffsetZero():void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(movie)
			{
				movie.x = 0;
				movie.y = 0;
				BindData.toBind(_bindMovie, movie);
			}
		}
		
		private function handleAutoScaleChange():void
		{
			ToolsApp.data.autoScale = checkAutoScale.selected;
			checkSplitImg.visible = !checkAutoScale.selected;
		}
		
		private function handleSplitImgChange():void{
			ToolsApp.data.splitImg = checkSplitImg.selected;
		}
		
		private function handleAutoRotationChange():void
		{
			ToolsApp.data.autoRotation = checkAutoRotation.selected;
		}
		
		private function handleSaveDirStruct():void
		{
			ToolsApp.data.saveDirStruct = checkSaveDirStruct.selected;
		}
		
		
		private function handleMovieFrameChange(e:SimpleEvent):void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(movie)
			{
				txtFrame.text = (movie.frame+1)+"";
			}
		}
		
		private function handleMoviePlay():void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)return;
			movie.pause = !movie.pause;
			refushMovieState();
		}
		
		private function refushMovieState():void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)return;
			if(movie.pause)
			{
				btnPlay.label = "播放";
			}else{
				btnPlay.label = "暂停";
			}
			
		}
		
		private function handleMoviePre():void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)return;
			movie.setFrame(movie.frame-1);
		}
		private function handleMovieNext():void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)return;
			movie.setFrame(movie.frame+1);
			
		}
		
		private function handleExportImgScaleChange():void
		{
			ToolsApp.data.outImgSaveScale = checkExportImgScale.selected;
		}
		
		private function handleExportOpenDir():void
		{
			if(!inputExportImg.text)
			{
				Alert.show("请先设置导出目录");
				return;
			}
			var file:File = new File(inputExportImg.text);
			if(!file.exists)
			{
				Alert.show("当前目录不存在"+inputExportImg.text);
				return;
			}
			file.openWithDefaultApplication();
		}
		
		private function handleExportSelectDir():void
		{
			ToolsApp.file.openFile(handleOnExportSelectPath, true, ToolsApp.data.outImgPath);
		}
		
		private function handleOnExportSelectPath(filePath:String):void
		{
			inputExportImg.text = filePath;
			ToolsApp.data.outImgPath = filePath;
		}
		
		private function handleExportImage():void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)
			{
				Alert.show("当前没有选中要导出的特效");
				return;
			}
			if(!inputExportImg.text)
			{
				Alert.show("请先设置导出目录");
				return;
			}
			var file:File = new File(inputExportImg.text);
			if(!file.exists)
			{
				Alert.show("当前目录不存在"+inputExportImg.text);
				return;
			}
			var len:int = movie.totalFrame;
			var data:MovieData = movie.data;
			var saveScale:Boolean = checkExportImgScale.selected;
			if(!data)
			{
				Alert.show("当前影片没有数据");
				return;
			}
			var baseOffX:int = 0;
			var baseOffY:int = 0;
			if(data.sub.length>0)
			{
				var maxRectSize:int = 0;
				for(var j:int=0; j<data.sub.length; j++)
				{
					var firstSub:SubTextureData = data.sub[j];
					var size:int = Math.abs(firstSub.ox*firstSub.oy);
					if(size > maxRectSize)
					{
						maxRectSize = size;
						baseOffX = firstSub.ox+firstSub.w/2;
						baseOffY = firstSub.oy+firstSub.h/2;
					}
				}
//				var firstSub:SubTextureData = data.sub[0];
//				baseOffX = firstSub.ox+firstSub.w/2;
//				baseOffY = firstSub.oy+firstSub.h/2;
			}
			var scale:Number = 1;
			if(data.scale)
				scale = 1/data.scale;
			for(var i:int=0; i<len; i++)
			{
				var bd:BitmapData = movie.getSubImg(i);
				var frameData:SubTextureData = data.sub[i];
				if(bd)
				{
					var w:int = Math.max(800, bd.width, bd.height);
					var outBd:BitmapData = new BitmapData(w, w, true, 0);
					var ox:Number = frameData.ox - baseOffX;
					var oy:Number = frameData.oy - baseOffY;
					if(saveScale && scale!=1)
					{
						outBd.draw(bd, new Matrix(scale, 0, 0, scale,scale*ox+w/2,oy+w/2));	
					}else{
						outBd.copyPixels(bd,new Rectangle(0, 0, bd.width, bd.height), new Point(ox+w/2,oy+w/2));	
					}
//					outBd.copyPixels(bd,new Rectangle(0, 0, bd.width, bd.height), new Point(w/2+ox,w/2+oy));//new Point(w/2-ox, w/2-oy));
					var byte:ByteArray = PNGEncoder.encode(outBd);
					var outPath:String = file.nativePath+"\\"+movie.fileName+"\\000"+i+".png";
					ToolsApp.file.saveByteFile(outPath, byte);
					Log.log("导出图片："+outPath);
				}
			}
			Alert.show("导出完毕\n"+outPath);
		}
		
	}
}