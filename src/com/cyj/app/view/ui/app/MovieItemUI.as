/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.app {
	import morn.core.components.*;
	public class MovieItemUI extends View {
		public var txtName:Label = null;
		public var btnRemove:Button = null;
		public var btnShow:Button = null;
		protected static var uiView:XML =
			<View width="180" height="25">
			  <Image skin="png.comp.blank" x="1" y="1" width="180" height="25"/>
			  <Clip skin="png.guidecomp.clip_格子选中" x="1" y="1" width="180" height="24" sizeGrid="5,5,5,5,1" name="selectBox"/>
			  <Label text="name" x="9" width="124" name="label" y="4" height="18" var="txtName" color="0xffffff"/>
			  <Button skin="png.guidecomp.btn_减号_1" x="153" y="1" var="btnRemove"/>
			  <Button label="显" skin="png.guidecomp.btn_小按钮_1" x="130" y="1" width="24" height="23" var="btnShow" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			</View>;
		public function MovieItemUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}