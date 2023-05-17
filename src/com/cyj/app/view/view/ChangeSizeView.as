package com.cyj.app.view.view
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.view.common.Alert;
	import com.cyj.app.view.ui.app.ChangeSizeUI;
	import com.cyj.utils.Log;
	import com.cyj.utils.file.FileManager;
	import com.cyj.utils.images.JPGEncoder;
	import com.cyj.utils.images.PNGEncoder;
	import com.cyj.utils.load.LoaderManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import morn.core.components.Image;
	import morn.core.components.TextInput;
	
	public class ChangeSizeView extends ChangeSizeUI
	{
		public function ChangeSizeView()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			btnClose.addEventListener(MouseEvent.CLICK, handleClose);
			btnInputDir.addEventListener(MouseEvent.CLICK, handleInputDir);
			btnOutputDir.addEventListener(MouseEvent.CLICK, handleOutputDir);
			btnExport.addEventListener(MouseEvent.CLICK, handleExport);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoadComplete);
		}
		
		private function handleClose(e:MouseEvent):void {
			ChangeSizeView.hide();
		}
		
		private function handleInputDir(e:MouseEvent):void {
			ToolsApp.file.openFile(handleSelectInputFile, true, inputPath.text, [inputPath]);
		}
		
		private function handleOutputDir(e:MouseEvent):void {
			ToolsApp.file.openFile(handleSelectInputFile, true, outputPath.text, [outputPath]);
		}
		
		private function handleSelectInputFile(file:String, text:TextInput):void{
			text.text = file;
		}
		
		
		private function handleExport(e:MouseEvent):void {
			var file:File = new File(inputPath.text);
			if(!file.exists){
				Alert.show("输入路径不存在");
				return;
			}
			if(!outputPath.text){
				Alert.show("输出路径不能为空");
				return;
			}
			var outFile:File = new File(outputPath.text);
			_total = 0;
			_count = 0;
			readDirFiles(file, outFile, file.nativePath);  
		}
		
		
		public function readDirFiles(file:File, outFile:File, path:String):void
		{
			if(file.isDirectory)
			{
				var files:Array = file.getDirectoryListing();
				for(var i:int=0; i<files.length; i++)
				{
					readDirFiles(files[i], outFile, path);
				}
			}else{
				var type:String = file.name.substring(file.name.lastIndexOf(".")+1);
				var ofile:File = new File(file.nativePath.replace(path, outFile.nativePath));
				_total ++;
				var byte:ByteArray = new ByteArray();
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				fileStream.readBytes(byte);
				fileStream.close();
				
				if(type == "png" || type=="jpg"){
					dealImage(file, byte, ofile, type=="png");
				}else{
					var outStream:FileStream = new FileStream();
					outStream.open(ofile, FileMode.WRITE);
					outStream.writeBytes(byte);
					outStream.close();
					_count++;
					checkComplete();
					Log.log("拷贝 "+_count+"/"+_total+"  "+file.nativePath+" -> "+ofile.nativePath);
				}
			}
		}
		
		private function checkComplete():void {
			App.timer.doOnce(1000, toCheckComplete, null, true);
		}
		
		private function toCheckComplete():void{
			if(_count>=_total){
				Alert.show("处理完毕");
				ToolsApp.file.openDir(outputPath.text);
			}
		}
		
		private var _loader:Loader = new Loader();
		private var _waitList:Array = [];
		private var _count:int = 0;
		private var _total:int = 0;
		private function dealImage(file:File, byte:ByteArray, saveFile:File, isPng:Boolean):void {
			_waitList.push({file:file, byte:byte, ofile:saveFile, isPng:isPng});
			if(_waitList.length>1){
				return;
			}
			_loader.loadBytes(byte,null);
		}
		
		private function handleLoadComplete(e:Event):void {
			if(_waitList.length==0)return;
			var info:Object = _waitList.shift();
			var img:BitmapData = Bitmap(_loader.content).bitmapData;
			var size:int = Math.max(img.width, img.height);
			for(var i:int=0; i<12; i++){
				if(size<(1<<i)){
					size = 1<<i;
					break;
				}
			}
			var bd:BitmapData = new BitmapData(size, size, true, 0);
			bd.draw(img);
			var byte:ByteArray;
			if(info.isPng){
				byte = PNGEncoder.encode(bd);
			}else{
				byte = new JPGEncoder().encode(bd);
			}
			var outStream:FileStream = new FileStream();
			outStream.open(info.ofile, FileMode.WRITE);
			outStream.writeBytes(byte);
			outStream.close();
			_count++;
			checkComplete();
			Log.log("拷贝 "+_count+"/"+_total+"  "+info.file.nativePath+" -> "+info.ofile.nativePath);
			if(_waitList.length>0){
				var next:Object = _waitList[0];
				_loader.loadBytes(next.byte,null);
			}
		}
		
		private static var _view:ChangeSizeView;
		public static function show():void{
			if(!_view)_view = new ChangeSizeView();
			App.stage.addChild(_view);
			_view.x = App.stage.width/2-_view.width/2;
			_view.y = App.stage.height/2  - _view.height/2;
		}
		
		public static function hide():void{
			if(App.stage.contains(_view)){
				App.stage.removeChild(_view);
			}
		}
	}
}