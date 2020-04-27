package com.cyj.app.utils
{
	import com.cyj.app.ToolsApp;
	import com.cyj.app.data.cost.Sex;
	
	import flash.filesystem.File;
	import flash.geom.Point;

	public class ComUtill
	{
		 
		public static function getAvtResIdByPath(path:String):String
		{
			path = commonPath(path);
			var resId:String = getResCfg(path);
			if(resId)return resId;
			else return path.substr(path.lastIndexOf("/")+1);
		}
		
		private static var _onlyId:int=new Date().time;
		public static function getOnlyId():int
		{
			return _onlyId++;
		}
		
		public static function commonPath(path:String):String
		{
			return path.replace(/[\\\/]+/gi, "/");
		}
		
		public static function getAvtResPath(resId:*, sex:int = Sex.Male): Object {
			if (!resId) return {path:'', isDirRes:false};
			var root:String = ToolsApp.localCfg.localWebPath+"/avatarres/";
			root = root.replace(/[\\\/]+/gi, "/");
			var cfgs:Array = ToolsApp.projectData.config.resBody;
			if (String(resId).indexOf('/') >= 0) return {path:String(resId), isDirRes:false};
			var cfg:* = getCfg(cfgs, "id", resId);
			if (!cfg)
			{
				var p:String = root +'effect/' + resId;
				var f:File = new File(p+".json");
				if(!f.exists)
				{
					p = root +'effect2/' + resId;
				}
				return  {path:p, isDirRes:false};
			}
			var res:String = cfg.res1;
			if (sex == Sex.Female && cfg.res2) res = cfg.res2;
			return {path:root +cfg.resMenu + '/' + res, isDirRes:true};// + '/' + res + '_{0}_{1}';
		}
		
		public static function getCfg(list:Array, key:String, value:*):*
		{
			for(var i:int=0; i<list.length; i++)
			{
				if(list[i][key] == value)
				{
					return list[i];			
				}
			}
			return null;
		}
		
		public static function getResCfg(path:String):String
		{
			var cfgs:Array = ToolsApp.projectData.config.resBody;
			path = commonPath(path);
			var root:String = ToolsApp.localCfg.localWebPath+"/avatarres/";
			for(var i:int=0; i<cfgs.length; i++)
			{
				var p1:String = commonPath(root + cfgs[i].resMenu+"/"+cfgs[i].res1);
				if(p1 == path)
				{
					return cfgs[i].id;			
				}else{
					p1 =  commonPath(root + cfgs[i].resMenu+"/"+cfgs[i].res2);
					if(p1 == path)
					{
						return cfgs[i].id;			
					}
				}
			}
			return null;
		}
		
		/**获取Body的配置**/
		public static function getResCfgByPath(path:String):Object
		{
			var cfgs:Array = ToolsApp.projectData.config.resBody;
			path = commonPath(path);
			var root:String = ToolsApp.localCfg.localWebPath+"/avatarres/";
			for(var i:int=0; i<cfgs.length; i++)
			{
				var p1:String = commonPath(root + cfgs[i].resMenu+"/"+cfgs[i].res1);
				if(p1 == path)
				{
					return cfgs[i];			
				}else{
					p1 =  commonPath(root + cfgs[i].resMenu+"/"+cfgs[i].res2);
					if(p1 == path)
					{
						return cfgs[i];			
					}
				}
			}
			return null;
		}
		
		/** 通过两点获得角度 */
		public static function  getAngle(pointA:*, pointB:*):Number {//通过两点获得角度
			var mx:Number = pointA.x;
			var my:Number = pointA.y;
			var px:Number = pointB.x;
			var py:Number = pointB.y;
			var x:Number = Math.abs(px - mx);
			var y:Number = Math.abs(py - my);
			var z:Number = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
			var cos:Number = y / z;
			var angle:Number = Math.acos(cos);//用反三角函数求弧度
			var pi:Number = Math.PI;
			if (mx > px && my > py) {//目标点在第四象限
				angle = pi - angle;
			}
			
			if (mx == px && my > py) {//目标点在y轴负方向上
				angle = pi;
			}
			
			if (mx > px && my == py) {//目标点在x轴正方向上
				angle = pi / 2;
			}
			
			if (mx < px && my > py) {//目标点在第三象限
				angle = pi + angle;
			}
			
			if (mx < px && my == py) {//目标点在x轴负方向
				angle = pi * 3 / 2;
			}
			
			if (mx < px && my < py) {//目标点在第二象限
				angle = 2 * pi - angle;
			}
			angle = angle + pi / 2;
			if (angle > 2 * pi) angle = angle - 2 * pi;
			return angle;
		}
		
		/**
		 * 获取两点之间的距离
		 * @param startP起始坐标
		 * @param targetP目标坐标
		 * @param isSqrt是否进行平方根计算，平方根计算后的距离才是两点间的真实距离
		 *  */
		public static function getDistance(startP: *, targetP: *, isSqrt: Boolean = true): Number {
			var dis: Number;
			var m: Number = targetP.x - startP.x;
			var n: Number = targetP.y - startP.y;
			if (isSqrt) {
				dis = Math.sqrt(m * m + n * n);
			} else {
				dis = m * m + n * n;
			}
			return Math.floor(dis);
		}

		
		public function ComUtill()
		{
		}
	}
}