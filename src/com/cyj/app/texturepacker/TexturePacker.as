package com.cyj.app.texturepacker
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.data.PathInfo;
	import com.cyj.app.event.SimpleEvent;
	import com.cyj.app.view.common.Alert;
	import com.cyj.utils.Log;
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
							handleRunPacketCmd(_curItem.dirPath, 1024, _canUseScale);
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
					handleRunPacketCmd(_curItem.dirPath, 1024, newScale);
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
						handleRunPacketCmd(_curItem.dirPath, 1024, newScale);
						return;
					}
					
				}
			}
			_packetInfo.push({path:_curItem.outPath, scale:_curScale});
			ToolsApp.loader.loadSingleRes(ToolsApp.CMD_WORK_PATH+"/out.json", ResLoader.TXT, handleDataLoaded);
			ToolsApp.loader.loadSingleRes(ToolsApp.CMD_WORK_PATH+"/out.png", ResLoader.IMG, handleImageLoaded);
		}
		
		
		
		private function handleRunPacketCmd(dirPath:String, imgMaxSize:int=1024, scale:Number=1):void
		{
			var param:String = " --max-width "+imgMaxSize+" --max-height "+imgMaxSize;
			if(scale!=1)
			{
				param += " --scale "+scale;
			}
			_curScale = scale;
			var rotation:String = "--enable-rotation";
			if(!ToolsApp.data.autoRotation)
			{
				rotation = "--disable-rotation";
			}
			var packetStr:String = '"'+ToolsApp.data.texturePackerPath+"TexturePacker"+'"'+" --sheet out.png --data out.json --format json "+ param +" --texturepath img/testsave --shape-padding 2 --allow-free-size --trim  "+rotation+" "+'"'+dirPath.replace(/\//gi, "\\")+'"';
			
			ToolsApp.cmdOper(packetStr, _curItem.dirPath, true);
		}
		
		private function handleDataLoaded(res:ResData):void
		{
			if(_curItem)
			{
				Log.log("打包配置加载完毕"+_curItem.dirPath);
				_curItem.handleDataLoaded(res.data);
			}
			checkComplete();
		}
		
		private function handleImageLoaded(res:ResData):void
		{
			if(_curItem)
			{
				Log.log("打包图片加载完毕"+_curItem.dirPath);
				_curItem.handleImageLoaded(res.data);
			}
			checkComplete();
		}
		
		/**当前是否正在运行中**/
		public function get isRuning():Boolean
		{
			return _isRuning;
		}
		
		private function checkComplete():void
		{
			if(_curItem.isComplete)
			{
				if(_curItem.outPath)
					ToolsApp.data.addMovie(_curItem.outPath+".json");
				doNext();
			}
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
		
		
		
		
		
	}
}