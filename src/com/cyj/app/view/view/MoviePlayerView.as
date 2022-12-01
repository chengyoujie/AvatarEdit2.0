package com.cyj.app.view.view
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.view.ui.app.MoviePlayerViewUI;
	import com.cyj.app.view.unit.Movie;
	import com.cyj.app.view.unit.data.MovieData;
	import com.cyj.app.view.unit.data.SubTextureData;
	
	import flash.display.Shape;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	public class MoviePlayerView extends MoviePlayerViewUI
	{
		private var _baseLine:Shape;
		private var _mask:Shape;
		
		public function MoviePlayerView()
		{
			super();
			mcContain.removeAllChild();
			_baseLine = new Shape();
			drawBaseLine();
			_mask = new Shape();
			this.addChild(_mask);
			refushMask();
			this.addChildAt(_baseLine, this.getChildIndex(mcContain)-1);
			moviesNumChange();
			App.timer.doFrameLoop(1, handleTick);
			ToolsApp.event.on(SimpleEvent.MOVIE_ADD, handleAddMovie);
			ToolsApp.event.on(SimpleEvent.MOVIE_REMOVE, handleRemoveMovie);
			ToolsApp.event.on(SimpleEvent.MOVIE_SELECT, handleShowMovieInfo)
			this.addEventListener(MouseEvent.MOUSE_DOWN, handlerStarDrag, true);
			App.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		}
		
		private function handleShowMovieInfo(e:SimpleEvent): void {
			var movie:Movie = ToolsApp.data.selectMovie;
			if(movie){
				var data:MovieData = movie.data;
				txtMCInfo.text = "MC: x:"+data.maxRect.x+", y:"+data.maxRect.y+" w:"+data.maxRect.width+" h:"+data.maxRect.height;
				
			}else{
				txtMCInfo.text = "MC信息";
				txtFrameInfo.text = "帧频信息";
			}
		}
		
		public function resize(w:int, h:int):void
		{
			img_bg.width = w;
			img_bg.height = h;
			txtDes.width = w;
			txtDes.y = h/2 - txtDes.height/2;
			mcContain.x = w/2;
			mcContain.y = int(2*h/3);
			drawBaseLine();
			refushMask();
		}
		
		private function drawBaseLine():void
		{
			_baseLine.graphics.clear();
			_baseLine.graphics.lineStyle(1, 0xff0000);
			_baseLine.graphics.moveTo(0, mcContain.y);
			_baseLine.graphics.lineTo(img_bg.width, mcContain.y);
			_baseLine.graphics.moveTo(mcContain.x, 0);
			_baseLine.graphics.lineTo(mcContain.x, img_bg.height);
			_baseLine.graphics.endFill();
		}
		
		private function refushMask():void
		{
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00cc, 0.1);
			_mask.graphics.drawRect(0, 0, img_bg.width, img_bg.height);
			_mask.graphics.endFill();
			mcContain.mask = _mask;
		}
		
		private function handleTick():void
		{
			var movies:Vector.<Movie> = ToolsApp.data.movies;
			for(var i:int=0; i<movies.length; i++)
			{
				movies[i].render();
			}
			var movie:Movie = ToolsApp.data.selectMovie;
			if(movie){
				var data:MovieData = movie.data;
				var frameData:SubTextureData = movie.getFrameData(movie.frame);
				txtFrameInfo.text = "Frame: "+(movie.frame+1)+" time:"+int( (movie.frame+1) * 1000/movie.data.speed)+" x:"+frameData.x+ " y:"+ frameData.y+ " ox:"+frameData.ox+" oy:"+frameData.oy+" w:"+frameData.w+" h:"+frameData.h;
			}
		}
		
		public function handleAddMovie(e:SimpleEvent):void
		{
			var movie:Movie = e.data as Movie;
			if(!movie)return;
			mcContain.addChild(movie);
			moviesNumChange();
		}
		
		
		public function handleRemoveMovie(e:SimpleEvent):void
		{
			var movie:Movie = e.data as Movie;
			if(!movie)return;
			if(mcContain.contains(movie))
			{
				mcContain.removeChild(movie)
			}
			moviesNumChange();
		}
		
		private function moviesNumChange():void
		{
			var movies:Vector.<Movie> = ToolsApp.data.movies;
			if(movies.length>0)
			{
				txtDes.visible = false;
				_baseLine.visible = true;
			}else{
				txtDes.visible = true;
				_baseLine.visible = false;
			}
		}
		
		/**开始拖拽**/
		private function handlerStarDrag(e:MouseEvent):void
		{
			if(e.target is Movie)
			{
				var movie:Movie = e.target as Movie;
				if(ToolsApp.data.selectMovie != movie)
				{
					ToolsApp.data.selectMovie = movie;
				}
				ToolsApp.focus = movie;
				movie.startDrag(false);
			}else{
				var stageX:int = e.stageX;
				var stageY:int = e.stageY;
				var rect:Rectangle = this.getBounds(App.stage);
				if(rect.contains(stageX, stageY))
				{
					ToolsApp.data.selectMovie = null;
				}
			}
			
//			App.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDragMove);
			App.stage.addEventListener(MouseEvent.MOUSE_UP, handleStopDrag);
		}
		
		private function handleKeyDown(e:KeyboardEvent):void
		{
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)return;
			if(ToolsApp.focus != movie)return;
			if(e.keyCode == Keyboard.UP)
			{
				movie.y -= 1;
			}else if(e.keyCode == Keyboard.DOWN)
			{
				movie.y += 1;
			}else if(e.keyCode == Keyboard.LEFT)
			{
				movie.x -= 1;
			}else if(e.keyCode == Keyboard.RIGHT)
			{
				movie.x += 1;
			}else if(e.keyCode == Keyboard.DELETE)
			{
				ToolsApp.data.removeMovie(movie);
			}
			ToolsApp.event.post(SimpleEvent.MOVIE_POS_CHANGE, movie);
		}
		
//		private function handleDragMove(e:MouseEvent):void
//		{
//			var movie:Movie = ToolsApp.data.selectMovie;
//			if(!movie)return;
//			var pos:Point = mcContain.globalToLocal(new Point(e.stageX, e.stageY));
//			movie.x = pos.x;
//			movie.y = pos.y;
//		}
		private function handleStopDrag(e:MouseEvent):void
		{
//			App.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragMove);
			App.stage.removeEventListener(MouseEvent.MOUSE_UP, handleStopDrag);
			var movie:Movie = ToolsApp.data.selectMovie;
			if(!movie)return;
			movie.stopDrag();
			ToolsApp.event.post(SimpleEvent.MOVIE_POS_CHANGE, movie);
//			var pos:Point = mcContain.globalToLocal(new Point(e.stageX, e.stageY));
//			movie.x = pos.x;
//			movie.y = pos.y;
		}
		
	}
}