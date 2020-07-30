package com.cyj.app.view.view
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.view.ui.app.FileItemUI;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	public class FileItem extends FileItemUI
	{
		
		private var _data:Object;
		
		public function FileItem()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			this.addEventListener(MouseEvent.CLICK, this.handleClick);
			this.addEventListener(MouseEvent.RIGHT_CLICK, this.handleRightClick);
		}
		
		private function handleClick(e:MouseEvent):void
		{
			if(_data && !_data.isDirectory)
				ToolsApp.event.post(SimpleEvent.CLICK_TREE_OUT_ITEM, _data);
//				this.dispatchEvent(new SimpleEvent(EVENT_CLICK, _data));
		}
		
		private function handleRightClick(e:MouseEvent):void
		{
			if(_data)
			{
				var file:File = new File(_data.path);
				if(file.exists)
				{
					if(!file.isDirectory)
						file = file.parent;
					file.openWithDefaultApplication();
				}	
			}
		}
		
		override public function set dataSource(value:Object):void
		{
			if(!value)return;
			txtName.text = value.name;
			var txtColor:int = 0xffffff;
			var file:File = new File(value.path);
			if(!file.exists)
				txtColor = 0xff0000;
			txtName.color = txtColor;
			_data = value;
			if(_data.isDirectory)
			{
				this.mouseChildren = true;
			}else{
				this.mouseChildren = false;
			}
			super.dataSource = value;	
		}
	}
}