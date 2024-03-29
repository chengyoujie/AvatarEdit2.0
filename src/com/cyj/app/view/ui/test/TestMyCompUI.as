/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.test {
	import morn.core.components.*;
	public class TestMyCompUI extends View {
		public var bg:Image = null;
		public var txtTitle:Label = null;
		public var btnXmlPath:Button = null;
		public var btnClose:Button = null;
		public var inputXmlPath:TextInput = null;
		public var combUnitAction:ComboBox = null;
		public var checkCarmeraCur:CheckBox = null;
		public var btnOpenGame:Button = null;
		protected static var uiView:XML =
			<View width="600" height="400">
			  <Image skin="png.guidecomp.通用面板_2" x="18" y="6" width="419" height="346" sizeGrid="160,40,160,40,1" var="bg"/>
			  <Label text="设置" x="145" y="16" width="168" height="18" align="center" color="0xccff00" stroke="0x0" var="txtTitle"/>
			  <Button label="浏览" skin="png.guidecomp.btn_四字常规_1" x="341" y="47" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0x0" var="btnXmlPath"/>
			  <Button skin="png.guidecomp.btn_关闭_1" x="410" y="21" var="btnClose"/>
			  <TextInput skin="png.guidecomp.textinput_文字输入底框_2" x="119" y="58" width="216" height="22" color="0xff6600" var="inputXmlPath" margin="3,2,2,2"/>
			  <Label text="导出配置路径" x="34" y="59" color="0xff9900" stroke="0"/>
			  <ComboBox skin="png.guidecomp.combobox" x="158" y="96" var="combUnitAction" width="115" height="23" visibleNum="15" scrollBarSkin="png.guidecomp.vscroll" itemColors="0x262626,0xffe0ce,0xff861a,0x885202,0x3d3d3d" labelColors="0xf4a339,0xfedcaf,0xe0e0e0" labels="待机,走路,死亡" selectedIndex="0"/>
			  <CheckBox label="使用当前镜头位置" skin="png.guidecomp.checkbox_单选" x="99" y="279" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0" var="checkCarmeraCur"/>
			  <Button label="打开游戏" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnOpenGame" labelStroke="0" width="58" height="28" x="392" y="181"/>
			</View>;
		public function TestMyCompUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}