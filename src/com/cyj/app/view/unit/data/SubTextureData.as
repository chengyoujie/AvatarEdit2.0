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
		public function SubTextureData(x:int, y:int, w:int, h:int, ox:int, oy:int, rotated:Boolean)
		{
			this.x = x;
			this.y = y;
			this.w = w;
			this.h = h;
			this.ox = ox;
			this.oy = oy;
			this.rotated = rotated;
		}
	}
}