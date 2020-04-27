package com.cyj.app.view.view
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.utils.BindData;
	import com.cyj.app.view.common.Alert;
	import com.cyj.app.view.ui.app.RightViewUI;
	import com.cyj.app.view.unit.Movie;
	import com.cyj.utils.Log;
	
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
			btnOffsetZero.clickHandler = new Handler(handleOffsetZero);
			checkAutoScale.clickHandler = new Handler(handleAutoScaleChange);
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
			checkAutoScale.selected = ToolsApp.data.autoScale;
			checkAutoRotation.selected = ToolsApp.data.autoRotation;
			checkSaveDirStruct.selected = ToolsApp.data.saveDirStruct;
			
			btnPlay.clickHandler = new Handler(handleMoviePlay);
			btnPre.clickHandler = new Handler(handleMoviePre);
			btnNext.clickHandler = new Handler(handleMovieNext);
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
		
	}
}