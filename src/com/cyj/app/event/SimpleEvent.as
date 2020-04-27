package com.cyj.app.event
{
	import flash.events.Event;
	
	
	
	public class SimpleEvent extends Event
	{
		/**添加movie**/
		public static const MOVIE_ADD:String = "movieAdd";
		/**移除movie*/
		public static const MOVIE_REMOVE:String = "movieRemove";
		/**选中Movie**/
		public static const MOVIE_SELECT:String = "movieSelect";
		/**影片位置移动**/
		public static const MOVIE_POS_CHANGE:String = "moviePosChange";
		
		/**影片的显示/隐藏  属性改变**/
		public static const MOVIE_VISIBLE_CHANGE:String = "movieVisibleChange";
		
		/**打包结束**/
		public static const PACKET_END:String = "packetEnd";
		
		/**点击左侧导出列表的文件**/
		public static const CLICK_TREE_OUT_ITEM:String = "clickTreeOutItem";
		
		
		public var data:Object;
		public function SimpleEvent(type:String, $data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = $data;
			super(type, bubbles, cancelable);
		}
	}
}