/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.app {
	import morn.core.components.*;
	public class RightViewUI extends View {
		public var img_bg:Image = null;
		public var boxBottom:Box = null;
		public var checkAutoScale:CheckBox = null;
		public var checkAutoRotation:CheckBox = null;
		public var checkSaveDirStruct:CheckBox = null;
		public var checkSplitImg:CheckBox = null;
		public var boxTop:Box = null;
		public var inputOffX:TextInput = null;
		public var inputOffY:TextInput = null;
		public var inputSpeed:TextInput = null;
		public var btnSave:Button = null;
		public var btnOffsetZero:Button = null;
		public var txtScale:Label = null;
		public var txtFileName:Label = null;
		public var txtFrame:Label = null;
		public var btnPre:Button = null;
		public var btnPlay:Button = null;
		public var btnNext:Button = null;
		public var txtTotalFrame:Label = null;
		public var txtTotalTime:Label = null;
		public var btnExportImg:Button = null;
		public var inputExportImg:TextInput = null;
		public var btnExportSelectDir:Button = null;
		public var checkExportImgScale:CheckBox = null;
		public var btnExportOpenDir:Button = null;
		public var btnReSetZero:Button = null;
		public var checkExportImgOldSize:CheckBox = null;
		protected static var uiView:XML =
			<View width="230" height="710">
			  <Image skin="png.guidecomp.框_02" x="0" y="0" sizeGrid="3,3,3,3,1" width="230" height="711" var="img_bg"/>
			  <Box x="1" y="624" var="boxBottom">
			    <CheckBox label="使用自动缩放至1024" skin="png.guidecomp.checkbox_单选" x="2" y="51" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0" var="checkAutoScale" selected="true"/>
			    <CheckBox label="是否使用旋转" skin="png.guidecomp.checkbox_单选" y="26" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0" var="checkAutoRotation" selected="true"/>
			    <CheckBox label="是否保留目录" skin="png.guidecomp.checkbox_单选" x="1" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0" var="checkSaveDirStruct" selected="true"/>
			    <CheckBox label="分图集" skin="png.guidecomp.checkbox_单选" x="146" y="51" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0" var="checkSplitImg" selected="true"/>
			  </Box>
			  <Box x="2" y="33" var="boxTop">
			    <TextInput skin="png.guidecomp.textinput_文字输入底框_2" x="59" y="193" width="50" height="22" color="0xff6600" var="inputOffX" margin="3,2,2,2"/>
			    <Label text="偏移X：" y="193" color="0xff9900" stroke="0" x="7"/>
			    <TextInput skin="png.guidecomp.textinput_文字输入底框_2" x="59" y="220" width="50" height="22" color="0xff6600" var="inputOffY" margin="3,2,2,2"/>
			    <Label text="偏移Y：" x="7" y="220" color="0xff9900" stroke="0"/>
			    <TextInput skin="png.guidecomp.textinput_文字输入底框_2" x="59" y="165" width="50" height="22" color="0xff6600" var="inputSpeed" margin="3,2,2,2"/>
			    <Label text="帧速:" x="23" y="165" color="0xff9900" stroke="0"/>
			    <Button label="保存" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnSave" labelStroke="0" width="61" height="32" x="69" y="258"/>
			    <Button label="置零" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnOffsetZero" labelStroke="0" width="50" height="28" x="117" y="215"/>
			    <Label skin="png.comp.textarea" x="59" y="132" width="100" height="22" color="0xff6600" var="txtScale" margin="3,2,2,2"/>
			    <Label text="缩放:" x="23" y="132" color="0xff9900" stroke="0"/>
			    <Label skin="png.comp.textarea" x="59" y="99" width="100" height="22" color="0xff6600" var="txtFileName" margin="3,2,2,2"/>
			    <Label text="文件名:" x="11" y="100" color="0xff9900" stroke="0"/>
			    <Label skin="png.comp.textarea" x="59" width="73" height="22" color="0xff6600" var="txtFrame" margin="3,2,2,2" y="72"/>
			    <Label text="当前帧:" x="11" y="73" color="0xff9900" stroke="0"/>
			    <Button label="上一帧" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnPre" labelStroke="0" width="58" height="28" x="21"/>
			    <Button label="暂停" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnPlay" labelStroke="0" width="58" height="28" x="82"/>
			    <Button label="下一帧" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnNext" labelStroke="0" width="58" height="28" x="145"/>
			    <Label text="/12" x="137" y="74" color="0xff9900" var="txtTotalFrame"/>
			    <Label skin="png.comp.textarea" x="59" width="100" height="22" color="0xff6600" var="txtTotalTime" margin="3,2,2,2" y="42"/>
			    <Label text="总时间:" x="11" y="43" color="0xff9900" stroke="0"/>
			    <Button label="导出散图" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnExportImg" labelStroke="0" width="57" height="32" x="97" y="521"/>
			    <TextInput skin="png.guidecomp.textinput_文字输入底框_2" x="57" y="500" width="169" height="22" color="0xff6600" var="inputExportImg" margin="3,2,2,2"/>
			    <Label text="导出路径：" x="0" y="500" color="0xff9900" stroke="0"/>
			    <Button label="浏览" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnExportSelectDir" labelStroke="0" width="38" height="32" x="153" y="521"/>
			    <CheckBox label="是否缩放导出" skin="png.guidecomp.checkbox_单选" x="-3" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0" selected="true" y="526" var="checkExportImgScale"/>
			    <Button label="打开" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnExportOpenDir" labelStroke="0" width="38" height="32" x="191" y="521"/>
			    <Button label="置于原点" skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" var="btnReSetZero" labelStroke="0" width="55" height="28" x="170" y="215"/>
			    <CheckBox label="是否原尺寸导出" skin="png.guidecomp.checkbox_单选" x="-2" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0" var="checkExportImgOldSize" selected="true" y="549"/>
			  </Box>
			</View>;
		public function RightViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}