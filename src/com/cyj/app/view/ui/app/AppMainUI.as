/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.app {
	import morn.core.components.*;
	import com.cyj.app.view.view.LeftView;
	import com.cyj.app.view.view.MoviePlayerView;
	import com.cyj.app.view.view.RightView;
	public class AppMainUI extends View {
		public var img_bg:Image = null;
		public var appName:Label = null;
		public var txtLog:Label = null;
		public var txtAuth:Label = null;
		public var moviePlayer:MoviePlayerView = null;
		public var boxDir:Box = null;
		public var btnUp:Button = null;
		public var btnUpRight:Button = null;
		public var btnRight:Button = null;
		public var btnRightDown:Button = null;
		public var btnDown:Button = null;
		public var btnLeftDown:Button = null;
		public var btnLeft:Button = null;
		public var btnLeftUp:Button = null;
		public var leftView:LeftView = null;
		public var rightView:RightView = null;
		public var boxTools:Box = null;
		public var btnViewLog:Button = null;
		public var btnOpenWeb:Button = null;
		protected static var uiView:XML =
			<View width="1024" height="800">
			  <Image skin="png.comp.blank" x="0" y="0" width="1024" height="800" var="img_bg"/>
			  <Label text="应用界面" x="10" y="3" color="0xff9900" stroke="0" width="1013" height="32" align="center" size="18" var="appName" isHtml="true"/>
			  <Label text="日志" x="2" y="752" width="1025" height="49" color="0x33ff00" var="txtLog" wordWrap="true"/>
			  <Label text="made by cyj 2020.04.20" x="891" y="777" color="0x666666" var="txtAuth"/>
			  <MoviePlayerView x="215" y="90" var="moviePlayer" runtime="com.cyj.app.view.view.MoviePlayerView"/>
			  <Box x="699" y="-3" var="boxDir">
			    <Button label="↑" skin="png.guidecomp.btn_小按钮_1" x="20" width="20" height="22" var="btnUp" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			    <Button label="↗" skin="png.guidecomp.btn_小按钮_1" x="40" width="20" height="22" var="btnUpRight" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			    <Button label="→" skin="png.guidecomp.btn_小按钮_1" x="41" y="23" width="20" height="25" var="btnRight" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			    <Button label="↘" skin="png.guidecomp.btn_小按钮_1" x="40" y="49" width="20" height="22" var="btnRightDown" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			    <Button label="↓" skin="png.guidecomp.btn_小按钮_1" x="20" y="49" var="btnDown" width="20" height="22" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			    <Button label="↙" skin="png.guidecomp.btn_小按钮_1" y="49" var="btnLeftDown" width="20" height="22" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			    <Button label="←" skin="png.guidecomp.btn_小按钮_1" y="23" width="20" height="25" var="btnLeft" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			    <Button label="↖" skin="png.guidecomp.btn_小按钮_1" width="20" height="22" var="btnLeftUp" labelColors="0xc79a84,0xe0a98d,0x93827a"/>
			  </Box>
			  <LeftView x="0" y="39" runtime="com.cyj.app.view.view.LeftView" var="leftView"/>
			  <RightView x="789" y="48" runtime="com.cyj.app.view.view.RightView" var="rightView"/>
			  <Box x="930" y="8" var="boxTools">
			    <Button label="Log" skin="png.guidecomp.btn_小按钮_1" x="41" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0x0" var="btnViewLog" width="43" height="32" sizeGrid="10,"/>
			    <Button skin="png.guidecomp.btn_小按钮_1" labelColors="0xc79a84,0xe0a98d,0x93827a" labelStroke="0x0" var="btnOpenWeb" width="43" height="32" sizeGrid="10," label="Web"/>
			  </Box>
			</View>;
		public function AppMainUI(){}
		override protected function createChildren():void {
			viewClassMap["com.cyj.app.view.view.LeftView"] = LeftView;
			viewClassMap["com.cyj.app.view.view.MoviePlayerView"] = MoviePlayerView;
			viewClassMap["com.cyj.app.view.view.RightView"] = RightView;
			super.createChildren();
			createView(uiView);
		}
	}
}