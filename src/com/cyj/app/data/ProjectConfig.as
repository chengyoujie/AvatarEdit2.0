package com.cyj.app.data
{
	import com.cyj.utils.ObjectUtils;
	import com.cyj.utils.XML2Obj;
	
	import flash.filesystem.File;

	public class ProjectConfig
	{
		public static const ENCRYPT_NORMAL:int = 0;
		public static const ENCRYPT_MD5:int = 1;
		public static const ENCRYPT_WEBP:int = 2;
		
		
		public var name:String;
		public var id:String;
		public var svnroot:String;
		public var svncmd:String;
		public var svnoutingoredic:String;
		public var updir:String;
		public var resdicpath:String;
		public var res50path:String;
		public var encryptMap:int;
		public var mapkey:String;
		public var mapextion:String;
		public var weburl:String;
		
		public function ProjectConfig()
		{
			
		}
		
		public function initVar():void
		{
			var props:Array = ObjectUtils.getObjProps(this);
			var reg:RegExp = /\{\$(.*?)\}/gi;
			for(var i:int=0; i<props.length; i++)
			{
				var arr:Array;
				while(arr = reg.exec(this[props[i]]))
				{
					if(this.hasOwnProperty(arr[1]))
						this[props[i]] = this[props[i]].replace(arr[0], this[arr[1]]);
					else if(props[i] == "apppath")
					{
						this[props[i]] = this[props[i]].replace(arr[0], File.applicationDirectory.nativePath);
					}else
						this[props[i]] = this[props[i]].replace(arr[0], "");
					reg.lastIndex = 0;
				}
			}
		}
	}
}