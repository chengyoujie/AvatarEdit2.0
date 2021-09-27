package com.cyj.app.texturepacker
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.data.PathInfo;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.view.common.Alert;
	import com.cyj.utils.Log;
	import com.cyj.utils.file.FileManager;
	import com.cyj.utils.load.ResData;
	import com.cyj.utils.load.ResLoader;
	
	import flash.events.Event;
	import flash.filesystem.File;

	public class TexturePacker
	{
		private static const CHECK_TEXTURE_PACKER:String = "CheckTexturePacker";
		
		private var _waitList:Vector.<TexturePackerItemData> = new Vector.<TexturePackerItemData>();
		private var _isRuning:Boolean = false;
		private var _curItem:TexturePackerItemData;
		/**如果预设的尺寸过小 尝试多少次方大最大宽高   1024<<_pakckNum**/
		private var _packSizeNum:int = 1;
		/**如果是自动缩放  尝试的缩放次数**/
		private var _packScaleNum:int = 1;
		private var _curScale:Number = 1;
		private var _lastScale:Number = 1;
		private var _canUseScale:Number = 0;
		private var _packetInfo:Array = [];
		/**texture导出文件的唯一索引**/
		private var _outIndex:int = 0;
		
		public function TexturePacker()
		{
		}
		
		public function init():void{
			var packetStr:String = '"'+ToolsApp.data.texturePackerPath+"TexturePacker"+'"';
			ToolsApp.event.on(CHECK_TEXTURE_PACKER, handleCheckTextureCanUse);
			ToolsApp.cmdOper(packetStr, CHECK_TEXTURE_PACKER, true);
		}
		
		private function handleCheckTextureCanUse(e:SimpleEvent):void
		{
			var outString:String = e.data as String;
			if(outString.indexOf("不是内部或外部命令，也不是可运行的程序") != -1 || outString.indexOf("You must agree to the license agreement before using") != -1)
			{
				Log.log("当前没有注册TexturePacker命令行");
				Alert.show("当前没有注册TexturePacker命令行，\n 点击打开"+ToolsApp.data.texturePackerPath+"TexturePackerGUI.exe 后同意协议即可", "提示", Alert.ALERT_OK, handleSuerAgree, "打开");
			}else{
				Log.log("已注册TexturePacker命令行,可以正常打包");
			}
		}
		
		
		private function handleSuerAgree(ok:int):void
		{
			if(ok == Alert.ALERT_OK)
			{
				var file:File = new File(ToolsApp.data.texturePackerPath+"TexturePackerGUI.exe");
				file.openWithDefaultApplication();
			}
		}
		
		
		public function run(dirPath:String, onComplete:Function, onError:Function, pathInfo:PathInfo):void
		{
			var item:TexturePackerItemData = new TexturePackerItemData(dirPath, onComplete, onError, pathInfo);
			_waitList.push(item);
			if(!_isRuning)
			{
				_packetInfo.length = 0;
				doNext();
			}else{
//				Alert.show("当前正在打包中...");
				Log.log("正在打包中...");
				return;
			}
		}
		
		private function doNext():void
		{
			if(_waitList.length == 0)
			{
				_packetInfo.sortOn("scale", Array.NUMERIC);
				var alertStr:String = "";
				for(var i:int=0; i<_packetInfo.length; i++)
				{
					if(_packetInfo[i].scale<1)
					{
						alertStr += "缩小："+(_packetInfo[i].scale)+"  路径"+_packetInfo[i].path+"\n";
					}
				}
				Alert.show("打包结束\n"+alertStr);
				Log.log("打包结束");
				FileManager.deleteFiles(ToolsApp.CMD_WORK_PATH);
				_isRuning = false;
				ToolsApp.event.post(SimpleEvent.PACKET_END);
				return;
			}
			var item:TexturePackerItemData = _waitList.shift();
			_curItem = item;
			_isRuning = true;
			_packSizeNum = 0;
			_packScaleNum = 0;
			_curScale = 1;
			_lastScale = 1;
			_canUseScale = 0;
			var imgMaxSize:int = 1024<<_packSizeNum;
			Log.log("开始打包:"+_curItem.dirPath);
			ToolsApp.event.on(item.dirPath, handleDealRes);
			handleRunPacketCmd(_curItem.dirPath, imgMaxSize);
		}
		
		private function handleDealRes(e:SimpleEvent):void
		{
			if(!_curItem)return;
			var outString:String = e.data as String;
			var newScale:Number = 1;
			if(outString.indexOf("error: Illegal value for") != -1 || outString.indexOf("TexturePacker:: error: Not all sprites could be packed into the texture!")!=-1)
			{
				if(ToolsApp.data.autoScale)//使用缩放打包
				{
					_packScaleNum ++;
					if(_packScaleNum>5)//最多尝试5次缩放失败
					{
						if(_canUseScale)
						{
							handleRunPacketCmd(_curItem.dirPath, 1024, 0, _canUseScale);
						}else{
							Alert.show("当前图片较大 尝试缩放多次无效，已放弃");	
						}
						return;
					}
					_lastScale = _curScale;
					if(_canUseScale)
					{
						newScale = (_curScale - _canUseScale)/2 + _canUseScale ;	
					}else{
						newScale = _curScale/2;	
					}
					Log.log("当前图片较大 尝试缩放"+_curScale);
					handleRunPacketCmd(_curItem.dirPath, 1024, 0, newScale);
				}else if(ToolsApp.data.splitImg){//使用分图集
					_packScaleNum ++;
					_lastScale = _curScale;//分图集的数目
					_curScale ++;
					handleRunPacketCmd(_curItem.dirPath, 1024, 1, _curScale);
				}else{//不适用缩放打包
					_packSizeNum ++;
					if(_packSizeNum>3)
					{
						handleError(null, "图片尺寸超过最大值");
					}else{
						var imgMaxSize:int = 1024<<_packSizeNum;
						Log.log("当前图片较大，尝试使用"+imgMaxSize+"进行第"+(_packSizeNum+1)+"次打包");
						handleRunPacketCmd(_curItem.dirPath, imgMaxSize);
					}	
				}
				return;
			}else if(outString.indexOf("TexturePacker:: error") != -1)
			{
				handleError(null, "打包错误："+outString);
				return;
			}else if(outString.indexOf("Resulting sprite sheet is") != -1)
			{
				var reg:RegExp = /Resulting\s+sprite\s+sheet\s+is\s+(\d+)x(\d+)/gi;
				var arr:Array = reg.exec(outString);
				if(arr && arr.length>2)
				{
					var w:int = arr[1];
					var h:int = arr[2];
					Log.log("当前图片尺寸: width: "+w+" height:"+h);
				}
				_canUseScale = Math.ceil(_curScale*10000)/10000;//可以使用的值
				if(ToolsApp.data.autoScale && _curScale != 1)//使用缩放打包
				{
					if(Math.abs(_lastScale - _curScale)>0.01 && _packScaleNum<5)//缩放的最小阀值    如果大于该值则表示  还有可以缩放的空间
					{
						newScale = (_lastScale - _curScale)/2 + _curScale;
						Log.log("当前图片尺寸: width: "+w+" height:"+h+"  尝试使用：scale="+newScale+" 打包图片");
						_packScaleNum++;
						handleRunPacketCmd(_curItem.dirPath, 1024, 0, newScale);
						return;
					}
				}
			}
			var packetInfo:Object = {path:_curItem.outPath, scale:1};
			if(ToolsApp.data.autoScale){
				packetInfo.scale = _curScale;
				_curItem.setParam(0, _curScale);
			}else if(ToolsApp.data.splitImg){
				packetInfo.split = _curScale;
				_curItem.setParam(1, _curScale);
			}
			_packetInfo.push(packetInfo);
			_curItem.startLoad("out"+_outIndex, doNext);
		}
		
		
		/**
		 * 图集打包
		 * @param dirPath 文件路径
		 * @param imgMaxSize 最大尺寸
		 * @param type   打包类型  0 如果超出进行缩放， 1如果超过进行拆分
		 * @param param  打包参数
		 */
		private function handleRunPacketCmd(dirPath:String, imgMaxSize:int=1024, type:Number=0, scale:Number=1):void
		{
			var param:String = " --max-width "+imgMaxSize+" --max-height "+imgMaxSize;
			var packetStr:String;
			_outIndex ++;
			
			var rotation:String = "--enable-rotation";
			if(!ToolsApp.data.autoRotation)
			{
				rotation = "--disable-rotation";
			}
			if(type == 1)//超过进行拆分
			{
				if(scale == 1)//1个图集的时候不用管
				{
					packetStr = '"'+ToolsApp.data.texturePackerPath+"TexturePacker"+'"'+" --sheet out"+_outIndex+".png --data out"+_outIndex+".json --format json "+ param +" --texturepath "+_outIndex+" --shape-padding 2 --allow-free-size --trim  "+rotation+" "+'"'+dirPath.replace(/\//gi, "\\")+'"';
				}else{
					var dirFile:File = new File(dirPath);
					var allFiles:Array = dirFile.getDirectoryListing();
					var files:Array = [];
					var idx:int = 0;
					for(var i:int=0; i<allFiles.length; i++)
					{
						var file:File = allFiles[i];
						if(ToolsApp.view.isImage(file.extension))
						{
							if(!files[idx])files[idx]=[];
							files[idx].push(file.nativePath);
							idx++;
							idx = (idx)%scale;
						}
					}
					packetStr = "";
					for(i=0; i<files.length; i++){
						if(files[i].length<=1)
						{
							Alert.show("当前图片某个图片超过了1024，已放弃分图集");
							return;
						}
						var packName:String = "out"+_outIndex+"_"+i;
						if(i==0)packName = "out"+_outIndex;
						packetStr += '\n"'+ToolsApp.data.texturePackerPath+"TexturePacker"+'"'+" --sheet "+packName+".png --data "+packName+".json --format json "+ param +" --texturepath "+_outIndex+" --shape-padding 2 --allow-free-size --trim  "+rotation+" "+'"'+(files[i].join('" "')+"").replace(/\//gi, "\\")+'"';
					}
				}
				_curScale = scale;
			}else{
				if(scale!=1)
				{
					param += " --scale "+scale;
				}
				_curScale = scale;
				packetStr = '"'+ToolsApp.data.texturePackerPath+"TexturePacker"+'"'+" --sheet out"+_outIndex+".png --data out"+_outIndex+".json --format json "+ param +" --texturepath "+_outIndex+" --shape-padding 2 --allow-free-size --trim  "+rotation+" "+'"'+dirPath.replace(/\//gi, "\\")+'"';
			}
			
			
			ToolsApp.cmdOper(packetStr, _curItem.dirPath, true);
		}
		
		private function handleError(res:ResData=null, msg:String=null):void
		{
			if(_curItem)
			{
				Alert.show("打包错误"+_curItem.dirPath+" 信息："+msg);
				Log.log("打包错误"+_curItem.dirPath+" 信息："+msg);
				_curItem.handleError();
			}
			if(_curItem.isComplete)
			{
				doNext();
			}
		}
		
		
		/**当前是否正在运行中**/
		public function get isRuning():Boolean
		{
			return _isRuning;
		}
		
		
		
		
		
		
		
	}
}