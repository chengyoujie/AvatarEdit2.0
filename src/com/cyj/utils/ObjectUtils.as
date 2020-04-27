package com.cyj.utils
{
	import flash.net.getClassByAlias;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;

	public class ObjectUtils
	{
		public function ObjectUtils()
		{
		}
		
		public static function getObjProps(object:Object):Array
		{
			var describe:XML = describeType(object);
			var vars:XMLList = describe["variable"];
			var props:Array = [];
			for(var i:int=0; i<vars.length(); i++)
			{
				props.push(vars[i].@name+"");
			}
			if(describe.@isDynamic == "true")
			{
				for(var pop:String in object)
				{
					props.push(pop);
				}
			}
			return props;
		}
		
		/**clone副本*/
		public static function clone(source:*):* {
			if(source==null)return;
			var clsName:String = getQualifiedClassName(source);//getQualifiedSuperclassName(source);//getQualifiedClassName(source);
			clsName = clsName.replace("::", ".");
			var cls:Class = getDefinitionByName(clsName) as Class;//  getClassByAlias(clsName);
			var obj:* ;
			if(cls)
			{
				obj = new cls();
				var pops:Array = getObjProps(source);
				for each(var prop:* in pops)
				{
					if(source[prop] is String || source[prop] is Number || source[prop]==null || source[prop]==undefined)
					{
						obj[prop] = source[prop];
					}else{
						obj[prop] = clone(source[prop]);
					}
				}
			}
			return obj;
		}
		
	
//		/**clone副本*/
//		public static function clone(source:*):* {
//			var bytes:ByteArray = new ByteArray();
//			bytes.writeObject(source);
//			bytes.position = 0;
//			return bytes.readObject();
//		}
		
	}
}