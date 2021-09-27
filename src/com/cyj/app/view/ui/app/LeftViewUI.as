/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.app {
	import morn.core.components.*;
	import com.cyj.app.view.view.FileItem;
	import com.cyj.app.view.view.MovieItem;
	public class LeftViewUI extends View {
		public var img_bg:Image = null;
		public var listMovie:List = null;
		public var treeOut:Tree = null;
		public var inputOutPath:TextInput = null;
		public var btnOpenOutDir:Button = null;
		public var btnMovieShow:Button = null;
		public var btnMovieClear:Button = null;
		public var btnSetOutDir:Button = null;
		public var btnRefushOutDir:Button = null;
		public var btnModifyAllSpeed:Button = null;
		public var inputAllSpeed:TextInput = null;
		protected static var uiView:XML =
			<View width="210" height="710">
			  <Image skin="png.guidecomp.框_02" x="0" y="0" sizeGrid="3,3,3,3,1" width="210" height="711" var="img_bg"/>
			  <Label text="Movie显示列表" x="21" y="457" width="99" height="18" color="0xffff99" align="center"/>
			  <List x="2" y="481" vScrollBarSkin="png.comp.vscroll" width="199" height="188" spaceY="2" var="listMovie">
			    <MovieItem x="0" y="0" name="render" runtime="com.cyj.app.view.view.MovieItem"/>
			  </List>
			  <Tree x="2" y="74" width="199" height="378" scrollBarSkin="png.comp.vscroll" spaceBottom="0" var="treeOut">
			    <FileItem name="render" runtime="com.cyj.app.view.view.FileItem" x="0" y="0"/>
			  </Tree>
			  <Label text="导出目录" x="1" y="2" width="210" height="18" color="0xffff99" align="center"/>
			  <TextInput skin="png.guidecomp.textinput_文字输入底框_2" x="4" y="21" width="198" height="22" color="0xff6600" var="inputOutPath" margin="3,2,2,2"/>
			  <Button label="打开" skin="png.guidecomp.btn_小按钮_1" x="161" y="41" width="46" height="30" var="btnOpenOutDir" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			  <Button label="显" skin="png.guidecomp.btn_小按钮_1" x="132" y="456" width="24" height="23" var="btnMovieShow" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			  <Button label="清除" skin="png.guidecomp.btn_小按钮_1" x="158" y="456" width="39" height="23" var="btnMovieClear" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			  <Button label="浏览" skin="png.guidecomp.btn_小按钮_1" x="120" y="43" width="39" height="28" var="btnSetOutDir" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			  <Button label="刷新" skin="png.guidecomp.btn_小按钮_1" x="78" y="43" width="39" height="28" var="btnRefushOutDir" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			  <Button label="保存" skin="png.guidecomp.btn_小按钮_1" x="146" y="673" width="39" height="23" var="btnModifyAllSpeed" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			  <TextInput skin="png.guidecomp.textinput_文字输入底框_2" x="86" y="674" width="50" height="22" color="0xff6600" var="inputAllSpeed" margin="3,2,2,2"/>
			  <Label text="修改所有帧速" y="676" color="0xff9900" stroke="0" x="5"/>
			</View>;
		public function LeftViewUI(){}
		override protected function createChildren():void {
			viewClassMap["com.cyj.app.view.view.FileItem"] = FileItem;
			viewClassMap["com.cyj.app.view.view.MovieItem"] = MovieItem;
			super.createChildren();
			createView(uiView);
		}
	}
}