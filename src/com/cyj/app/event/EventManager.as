package com.cyj.app.event
{
	import flash.events.EventDispatcher;

	public class EventManager
	{
		private var _event:EventDispatcher = new EventDispatcher();
		
		public function EventManager()
		{
		}
		
		public function on(event:String, handleFun:Function):void
		{
			_event.addEventListener(event, handleFun);
		}
		
		public function post(event:String, data:*=null):void
		{
			_event.dispatchEvent(new SimpleEvent(event, data));
		}
	}
}