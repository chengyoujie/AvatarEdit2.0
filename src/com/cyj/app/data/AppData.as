package com.cyj.app.data
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.view.common.Alert;
	import com.cyj.app.view.unit.Movie;
	
	import flash.filesystem.File;

	public class AppData
	{
		
		private var _movies:Vector.<Movie> = new Vector.<Movie>();
		private var _selectMovie:Movie;
		public var autoScale:Boolean = true;
		public var autoRotation:Boolean = true;
		public var saveDirStruct:Boolean = false;
		public var outPath:String = File.applicationDirectory.nativePath+"/资源导出/";
		public var logPath:String = File.applicationDirectory.nativePath+"/res/data/log.txt";
		public var texturePackerPath:String = File.applicationDirectory.nativePath+"/bin/texturepacker/";
		public var gameURL:String = "http://172.18.2.61/web/";
		public var localJsonPath:String = File.userDirectory.nativePath+"/AvatarEdit2.0/local.json";
		public var outImgPath:String = "D:/";
		public var outImgSaveScale:Boolean = true;
		
		public function AppData()
		{
			
		}
		
		public function getLocalJson():String
		{
			var obj:Object = {};
			obj.outPath = this.outPath;
			obj.autoScale = this.autoScale;
			obj.autoRotation = this.autoRotation;
			obj.saveDirStruct = this.saveDirStruct;
			obj.outImgPath = this.outImgPath;
			obj.outImgSaveScale = this.outImgSaveScale;
			return JSON.stringify(obj);
		}
		
		public function setLocalJson(str:String):void
		{
			if(!str)return;
			var obj:Object = JSON.parse(str);
			this.outPath  = obj.outPath;
			this.autoScale = obj.autoScale ;
			this.autoRotation = obj.autoRotation;
			this.saveDirStruct = obj.saveDirStruct;
			this.outImgPath = obj.outImgPath;
			this.outImgSaveScale = obj.outImgSaveScale;
		}
		
		
		public function addMovie(jsonPath:String, checkSame:Boolean=true):void
		{
			if(checkSame && hasMovie(jsonPath))
			{
				Alert.show("当前已有相同资源是否重复导入", "提示", Alert.ALERT_OK_CANCLE, handleAlertAddSameJson, "导入", "取消", jsonPath);
				return;
			}
			var movie:Movie = new Movie();
			movie.setData(jsonPath);
			_movies.push(movie);
			ToolsApp.event.post(SimpleEvent.MOVIE_ADD, movie);
		}
		
		private function handleAlertAddSameJson(ok:int, jsonPath:String):void
		{
			if(ok == Alert.ALERT_OK)
			{
				addMovie(jsonPath, false);
			}
		}
		
		public function hasMovie(jsonPath:String):Boolean
		{
			jsonPath = jsonPath.replace(/\\+/gi, "\\").replace(/\/+/gi, "\\");
			for(var i:int=_movies.length-1; i>=0; i--)
			{
				if(_movies[i].jsonPath == jsonPath)
				{
					return true;
				}
			}
			return false;
		}
		
		
		public function removeMovie(movie:Movie):void
		{
			for(var i:int=_movies.length-1; i>=0; i--)
			{
				if(_movies[i] == movie)
				{
					_movies.splice(i,1);
					ToolsApp.event.post(SimpleEvent.MOVIE_REMOVE, movie);
					if(movie == _selectMovie)//
					{
						selectMovie = null;
					}
				}
			}
		}
		
		public function set selectMovie(movie:Movie):void
		{
			if(_selectMovie)
				_selectMovie.select = false;
			_selectMovie = movie;
			if(_selectMovie)
				_selectMovie.select = true;
			ToolsApp.event.post(SimpleEvent.MOVIE_SELECT, _selectMovie);
		}
		
		public function removeAllMovie():void
		{
			for(var i:int=_movies.length-1; i>=0; i--)
			{
				var movie:Movie = _movies[i];
				_movies.splice(i,1);
				ToolsApp.event.post(SimpleEvent.MOVIE_REMOVE, movie);
			}
		}
		
		public function get selectMovie():Movie
		{
			return _selectMovie;
		}
		
		
		
		public function get movies():Vector.<Movie>
		{
			return _movies;
		}
		
		
	}
}