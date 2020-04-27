package com.cyj.app.view.view
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.view.ui.app.MovieItemUI;
	import com.cyj.app.view.unit.Movie;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	public class MovieItem extends MovieItemUI
	{
		private var _movie:Movie;
		public function MovieItem()
		{
			super();
			btnRemove.addEventListener(MouseEvent.CLICK, handleRemoveMovie);
			btnShow.addEventListener(MouseEvent.CLICK, handleShowHide);
			ToolsApp.event.on(SimpleEvent.MOVIE_VISIBLE_CHANGE, handleVisilbeChange);
		}
		
		override public function set dataSource(value:Object):void
		{
			_movie = value as Movie;
			_dataSource = _movie;
			if(!_movie)return;
			var file:File = new File(_movie.jsonPath);
			txtName.text = file.name.substring(0, file.name.lastIndexOf("."));//+(_movie.data.scale!=1?"("+int(_movie.data.scale*100)/100+")":"");
			refushShowHide();
		}
		
		private function  handleRemoveMovie(e:MouseEvent):void
		{
			ToolsApp.data.removeMovie(_movie);
		}
		private function handleShowHide(e:MouseEvent):void
		{
			_movie.visible = !_movie.visible;
			refushShowHide();
		}
		
//		public function setVisible(value:Boolean):void
//		{
//			_movie.visible = value;
//			refushShowHide();
//		}
		
		private function handleVisilbeChange(e:SimpleEvent):void
		{
			refushShowHide();
		}
		
		private function refushShowHide():void
		{
			if(!_movie)return;
			if(_movie.visible)
			{
				btnShow.label = "显";
			}else{
				btnShow.label = "隐";
			}
		}
		
	}
}