package com.cyj.app.view.view
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.data.ResType;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.view.common.Alert;
	import com.cyj.app.view.ui.app.LeftViewUI;
	import com.cyj.app.view.unit.Movie;
	import com.cyj.utils.file.FileManager;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.filesystem.File;
	
	import morn.core.handlers.Handler;

	public class LeftView extends LeftViewUI
	{
		private var _allShow:Boolean = true;
		
		public function LeftView()
		{
			ToolsApp.event.on(SimpleEvent.MOVIE_ADD, handleAddMovie);
			ToolsApp.event.on(SimpleEvent.MOVIE_REMOVE, handleRemoveMovie);
			listMovie.selectHandler = new Handler(handleMovieSelectChange);
			inputOutPath.addEventListener(FocusEvent.FOCUS_OUT, handleOutPathFocusOut);
			btnMovieClear.clickHandler = new Handler(handleClearAllMovie);
			btnMovieShow.clickHandler = new Handler(handleMovieShow);
			
			btnOpenOutDir.clickHandler = new Handler(handleOpenOutDir);
			btnSetOutDir.clickHandler = new Handler(handleSetOutDir);
			
			btnRefushOutDir.clickHandler = new Handler(handleRefushTreeOut);
			ToolsApp.event.on(SimpleEvent.PACKET_END, handleRefushTreeOut);
			ToolsApp.event.on(SimpleEvent.MOVIE_SELECT, handleMovieSelected);
			
		}
		
		public function initView():void
		{
			inputOutPath.text = ToolsApp.data.outPath;
			var file:File = new File(ToolsApp.data.outPath);
			if(!file.exists)
			{
				file.createDirectory();
			}
			handleRefushTreeOut();
			refushList();
		}
		
		public function resize(w:int, h:int):void
		{
			img_bg.width = w;
			img_bg.height = h;
			listMovie.height = h - listMovie.y;
		}
		
		private function handleOutPathFocusOut(e:FocusEvent):void
		{
			var filePath:String = inputOutPath.text;
			if(ToolsApp.texturePacker.isRuning)
			{
				Alert.show("当前正在打包中, 请稍后修改");
				inputOutPath.text = ToolsApp.data.outPath;
				return;
			}
			var file:File = new File(filePath);
			if(!file.exists)
			{
				Alert.show("路径不存在,请先检查路径是否正确："+filePath);
				inputOutPath.text = ToolsApp.data.outPath;
				return;
			}
			ToolsApp.data.outPath = filePath;
			handleRefushTreeOut();
		}
		
		private function handleClearAllMovie():void
		{
			ToolsApp.data.removeAllMovie();	
		}
		
		private function handleMovieShow():void
		{
			_allShow = !_allShow;
			if(_allShow)
			{
				btnMovieShow.label = "显";
			}else{
				btnMovieShow.label = "隐";
			}
			var movies:Vector.<Movie> =ToolsApp.data.movies;
			for(var i:int=0; i<movies.length; i++)
			{
//				var item:MovieItem = listMovie.getCell(i) as MovieItem;
//				if(item)
//				{
//					item.setVisible(_allShow);
//				}
				movies[i].visible = _allShow;
			}
			ToolsApp.event.post(SimpleEvent.MOVIE_VISIBLE_CHANGE);
		}
		
		public function handleAddMovie(e:SimpleEvent):void
		{
			refushList();
		}
		
		private function handleOpenOutDir():void
		{
			var file:File = new File(ToolsApp.data.outPath);
			if(file.exists)
			{
				file.openWithDefaultApplication();
			}else{
				Alert.show("当前目录不存在"+file.nativePath);
			}
		}
		private function handleSetOutDir():void
		{
			ToolsApp.file.openFile(handleOnSelectOutPath, true, ToolsApp.data.outPath);
		}
		
		private function handleOnSelectOutPath(filePath:String):void
		{
			inputOutPath.text = filePath;
			ToolsApp.data.outPath = filePath;
			handleRefushTreeOut();
		}
		
		public function handleRemoveMovie(e:SimpleEvent):void
		{
			refushList();
		}
		
		
		private function refushList():void
		{
			var arr:Array = [];
			var movies:Vector.<Movie> =ToolsApp.data.movies;
			for(var i:int=0; i<movies.length; i++)
			{
				arr.push(movies[i]);
			}
			listMovie.dataSource = arr;
		}
		
		
		private function handleMovieSelectChange(index:int):void
		{
			var movie:Movie = listMovie.selectedItem as Movie;
			ToolsApp.data.selectMovie = movie;
		}
		
		private function handleMovieSelected(e:SimpleEvent):void
		{
			var movie:Movie = e.data as Movie;
			var allMovies:Vector.<Movie> = ToolsApp.data.movies;
			var index:int = allMovies.indexOf(movie);
			if(index != listMovie.selectedIndex)
			{
				listMovie.selectedIndex = index;
			}
		}
		
		
		private function handleRefushTreeOut(e:Event=null):void
		{
			
			var file:File = new File(ToolsApp.data.outPath);
			var xml:String = "<root>";
			xml += getFileXml(file, ResType.JSON, true);
			xml += "</root>";
			treeOut.dataSource = new XML(xml);
			
		}
		
		public function getFileXml(file:File, type:String, isRoot:Boolean = false):String
		{
			var child:String = "";
			if(file.isDirectory)
			{
				if(!isRoot)
					child += "<dir  type='"+ResType.DIR+"'  name='"+file.name+"' path='"+file.nativePath+"'>";
				var files:Array = file.getDirectoryListing();
				for(var i:int=0; i<files.length; i++)
				{
					child += getFileXml(files[i], type);
				}
				if(!isRoot)
					child += "</dir>";
			}else if(file.name.indexOf(".json") != -1 && type == ResType.JSON){
				var fileName:String = file.name.replace(".json", "");
				var filePath:String = file.nativePath;
				child += "<file type='"+type+"' name='"+fileName+"' path='"+filePath+"' />";
			}
			return child;
		}
		
	}
}