/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.app {
	import morn.core.components.*;
	public class MoviePlayerViewUI extends View {
		public var img_bg:Image = null;
		public var txtDes:Label = null;
		public var mcContain:Box = null;
		protected static var uiView:XML =
			<View width="567" height="640">
			  <Image skin="png.comp.blank" x="0" y="0" width="567" height="640" var="img_bg"/>
			  <Label text="拖入文件夹生成或拖入json预览" x="1" y="312" color="0x999999" stroke="0" width="567" height="32" align="center" size="18" var="txtDes" isHtml="true"/>
			  <Box x="291" y="544" width="44" height="42" var="mcContain">
			    <Image skin="png.comp.blank" x="0" y="0" width="44" height="42"/>
			  </Box>
			</View>;
		public function MoviePlayerViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}