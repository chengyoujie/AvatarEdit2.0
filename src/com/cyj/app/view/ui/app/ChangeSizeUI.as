/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.app {
	import morn.core.components.*;
	public class ChangeSizeUI extends View {
		public var btnClose:Button = null;
		public var btnExport:Button = null;
		public var inputPath:TextInput = null;
		public var outputPath:TextInput = null;
		public var btnInputDir:Button = null;
		public var btnOutputDir:Button = null;
		protected static var uiView:XML =
			<View width="424" height="277">
			  <Image skin="png.guidecomp.通用面板_2" x="0" y="0" width="424" height="277" sizeGrid="30,80,20,20"/>
			  <Button skin="png.guidecomp.btn_关闭_1" x="396" y="15" var="btnClose"/>
			  <Button label="转换" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnExport" labelStroke="0" width="98" height="47" x="163" y="189"/>
			  <TextInput skin="png.guidecomp.textinput_文字输入底框_2" x="79" y="82" width="265" height="22" color="0xffffff" var="inputPath"/>
			  <Label text="输入路径" x="18" y="87" color="0xff9900" stroke="0"/>
			  <TextInput skin="png.guidecomp.textinput_文字输入底框_2" x="81" y="127" width="263" height="22" color="0xffffff" var="outputPath"/>
			  <Label text="输出路径" x="16" y="129" color="0xff9900" stroke="0"/>
			  <Button label="浏览" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnInputDir" labelStroke="0" width="59" height="28" x="350" y="80"/>
			  <Button label="浏览" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnOutputDir" labelStroke="0" width="59" height="28" x="349" y="127"/>
			  <Label text="图片转换2次幂" x="158" y="8" color="0xff9900" stroke="0" width="109" height="18" align="center"/>
			</View>;
		public function ChangeSizeUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}