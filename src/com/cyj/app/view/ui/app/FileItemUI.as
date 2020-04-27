/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.app {
	import morn.core.components.*;
	public class FileItemUI extends View {
		public var txtName:Label = null;
		protected static var uiView:XML =
			<View width="180" height="25">
			  <Clip skin="png.comp.clip_selectBox" x="12" y="1" clipY="2" name="selectBox" left="12" right="0" height="24" width="108" mouseEnabled="false"/>
			  <Clip skin="png.comp.clip_tree_folder" x="17" y="5" clipY="3" name="folder" clipX="1" mouseEnabled="false"/>
			  <Label text="treeItem" x="43" color="0xffffff" name="label" y="5" width="150" height="22" left="33" right="0" var="txtName" backgroundColor="0xffffff"/>
			  <Clip y="4" clipY="2" name="arrow" x="-2" skin="png.comp.clip_tree_arrow" width="19" height="18"/>
			</View>;
		public function FileItemUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}