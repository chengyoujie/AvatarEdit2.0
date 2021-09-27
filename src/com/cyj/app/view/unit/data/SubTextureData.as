package com.cyj.app.view.unit.data
{
	public class SubTextureData
	{
		public var x:int;
		public var y:int;
		public var w:int;
		public var h:int;
		public var ox:int;
		public var oy:int;
		/**是否旋转**/
		public var rotated:Boolean;
		/**切图位于图集的索引位置*/
		public var childIndex:int;
		public function SubTextureData(x:int, y:int, w:int, h:int, ox:int, oy:int, rotated:Boolean, childIndex:int)
		{
			this.x = x;
			this.y = y;
			this.w = w;
			this.h = h;
			this.ox = ox;
			this.oy = oy;
			this.rotated = rotated;
			this.childIndex = childIndex;
		}
	}
}