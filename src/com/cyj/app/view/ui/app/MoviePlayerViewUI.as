/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.app {
	import morn.core.components.*;
	public class MoviePlayerViewUI extends View {
		public var img_bg:Image = null;
		public var txtDes:Label = null;
		public var mcContain:Box = null;
		public var txtMCInfo:Label = null;
		public var txtFrameInfo:Label = null;
		protected static var uiView:XML =
			<View width="567" height="640">
			  <Image skin="png.comp.blank" x="0" y="0" width="567" height="640" var="img_bg"/>
			  <Label text="拖入文件夹生成或拖入json预览" x="1" y="312" color="0x999999" stroke="0" width="567" height="32" align="center" size="18" var="txtDes" isHtml="true"/>
			  <Box x="279" y="408" width="44" height="42" var="mcContain">
			    <Image skin="png.comp.blank" x="0" y="0" width="44" height="42"/>
			  </Box>
			  <Label text="MC信息" x="0" y="621" color="0x999999" stroke="0" width="233" height="18" align="left" size="12" var="txtMCInfo" isHtml="true" bottom="5"/>
			  <Label text="帧信息" x="233" y="622" color="0x999999" stroke="0" width="333" height="18" align="right" size="12" var="txtFrameInfo" isHtml="true" bottom="5"/>
			</View>;
		public function MoviePlayerViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}