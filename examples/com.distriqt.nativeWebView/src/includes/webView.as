/**
 *        __       __               __
 *   ____/ /_ ____/ /______ _ ___  / /_
 *  / __  / / ___/ __/ ___/ / __ `/ __/
 * / /_/ / (__  ) / / /  / / /_/ / /
 * \__,_/_/____/_/ /_/  /_/\__, /_/
 *                           / /
 *                           \/
 * http://distriqt.com
 *
 * Core features of Native WebView ANE
 *
 */

//Define Classes
import com.distriqt.extension.nativewebview.CachePolicy;
import com.distriqt.extension.nativewebview.NativeWebView;
import com.distriqt.extension.nativewebview.PrintOptions;
import com.distriqt.extension.nativewebview.WebView;
import com.distriqt.extension.nativewebview.WebViewOptions;
import com.distriqt.extension.nativewebview.events.NativeWebViewEvent;
import com.distriqt.extension.nativewebview.browser.BrowserView;
import com.distriqt.extension.nativewebview.events.BrowserViewEvent;
import flash.filesystem.File;


try {
	//APP KEY HERE
	NativeWebView.init("YOUR KEY HERE");
	if (NativeWebView.isSupported) {
		trace("NativeWebView Supported: " + NativeWebView.isSupported);
		trace("NativeWebView Version:   " + NativeWebView.service.version);
		trace("BrowserView Supported:   " + NativeWebView.service.browserView.isSupported);
	}
} catch (e: Error) {
	trace(e);
}

var urlID: String = "http://airnativeextensions.com";
var contentType: String = "Online";


//Use Native Mobile Web Browser for 3rd party links if available
if (NativeWebView.service.browserView.isSupported) {
	NativeWebView.service.browserView.addEventListener(BrowserViewEvent.READY, browserView_readyHandler);
	NativeWebView.service.browserView.prepare();
}

function browserView_readyHandler(event: BrowserViewEvent): void {
	NativeWebView.service.browserView.removeEventListener(BrowserViewEvent.READY, browserView_readyHandler);
	// Browser views are now ready to be used in your application
}


function openBrowserView(): void {
	NativeWebView.service.browserView.openWithUrl(urlID);
}


//WebView
var _webView: WebView = null;
var file: File;
var _bitmap: Bitmap;
var barHeight: int;


function openWebView(): void {

	trace("Creating web view");


	barHeight = screenHeight / stage.stageHeight * 90;
	var viewPort: Rectangle = new Rectangle(0, barHeight, screenWidth, screenHeight - barHeight);
	trace("Browser Loaded");





	//graphics.beginFill( 0xFF0000 );
	//graphics.drawRect( viewPort.x, viewPort.y, viewPort.width, viewPort.height );
	//graphics.endFill();

	var options: WebViewOptions = new WebViewOptions();
	options.allowInlineMediaPlayback = true;
	options.bounces = true;
	options.mediaPlaybackRequiresUserAction = false;
	options.allowZooming = true;

	options.backgroundColour = 0xCED2D0;
	options.backgroundEnabled = false;

	//options.disableLongPressGestures = true;
	
	//LOAD_NO_CACHE, LOAD_DEFAULT
	//options.cachePolicy = CachePolicy.LOAD_NO_CACHE;
	//options.useWebKitIfAvailable = false;


	_webView = NativeWebView.service.createWebView(viewPort, options);

	_webView.addEventListener(NativeWebViewEvent.LOCATION_CHANGING, webView_locationChangingHandler);
	_webView.addEventListener(NativeWebViewEvent.LOCATION_CHANGE, webView_locationChangeHandler);
	_webView.addEventListener(NativeWebViewEvent.COMPLETE, webView_completeHandler);
	_webView.addEventListener(NativeWebViewEvent.ERROR, webView_errorHandler);
	_webView.addEventListener(NativeWebViewEvent.JAVASCRIPT_RESPONSE, webView_javascriptResponseHandler);
	_webView.addEventListener(NativeWebViewEvent.JAVASCRIPT_MESSAGE, webView_javascriptMessageHandler);
	_webView.addEventListener(TouchEvent.TOUCH_TAP, webView_tapHandler);

	if (contentType == "Online") {
		loadFromUrl();
	}

	if (contentType == "Local") {
		loadPackagedFile();
	}

	if (contentType == "HTMLString") {
		loadFromAString();
	}

}

function captureScreenshot(): void {
	var bd: BitmapData = new BitmapData(_webView.width, _webView.height);
	_webView.drawViewPortToBitmapData(bd);
}


function removeWebView(): void {
	_webView.removeEventListener(NativeWebViewEvent.LOCATION_CHANGING, webView_locationChangingHandler);
	_webView.removeEventListener(NativeWebViewEvent.LOCATION_CHANGE, webView_locationChangeHandler);
	_webView.removeEventListener(NativeWebViewEvent.COMPLETE, webView_completeHandler);
	_webView.removeEventListener(NativeWebViewEvent.ERROR, webView_errorHandler);
	_webView.removeEventListener(NativeWebViewEvent.JAVASCRIPT_RESPONSE, webView_javascriptResponseHandler);
	_webView.removeEventListener(NativeWebViewEvent.JAVASCRIPT_MESSAGE, webView_javascriptMessageHandler);
	_webView.removeEventListener(TouchEvent.TOUCH_TAP, webView_tapHandler);
	_webView.dispose();
	_webView = null;
	closeWebWin();
}



//CONETENT EXAMPLES
function loadFromAString(): void {
	//
	//	Load from a string
	trace("Load from a string");

	if (appType == "android") {
		// Android: Copy the application packaged files to an accessible location			
		var packagedWWWRoot: File = File.applicationDirectory.resolvePath("www");
		var destination: File = File.applicationStorageDirectory.resolvePath("www");
		packagedWWWRoot.copyTo(destination, true);
	}

	var html: String = '<video id="video1" width="100%" height="100%" controls autoplay webkit-playsinline> \
					<source src="www/videos/big_buck_bunny.mp4" type="video/mp4"> \
					Your browser does not support HTML5 video. \
				</video>';

	_webView.loadString(html, "text/html", "file://" + File.applicationStorageDirectory.nativePath + "/");
}


function loadFromUrl(): void {
	//
	//	Load urls
	trace("Load Url");

	_webView.loadURL(urlID);
	//			_webView.loadURL( "data:image/png;base64,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" );
	//			_webView.loadURL( "http://html5demos.com/video" );
	//			_webView.loadURL( "http://www.quirksmode.org/html5/tests/video.html" );
	//			_webView.loadURL( "http://labsdownload.adobe.com/pub/labs/flashruntimes/shared/air18_flashplayer18_releasenotes.pdf" );

	//			_webView.loadURL( "http://airnativeextensions.com" );

	//			_webView.loadURL( "https://google-developers.appspot.com/maps/documentation/javascript/examples/full/map-simple" );

	//			_webView.loadURL( "https://www.youtube.com/watch?v=7bDLIV96LD4" );

}

function loadPackagedFile(): void {
	//
	//	Load an application packaged file, in a 'www' directory
	trace("Load packaged file");

	var file: File;
	if (appType == "android") {
		// Android: Copy the application packaged files to an accessible location			
		var packagedWWWRoot: File = File.applicationDirectory.resolvePath("www");
		var destination: File = File.applicationStorageDirectory.resolvePath("www");
		packagedWWWRoot.copyTo(destination, true);
		//	Grab the file url
		file = File.applicationStorageDirectory.resolvePath("www/example.html");
		urlID = "file://" + file.nativePath;
	} else {
		// iOS:
		file = File.applicationDirectory.resolvePath("www/example.html");
		urlID = "file://" + file.nativePath;
	}

	trace(urlID);

	_webView.loadURL(urlID);

}


function drawBitmap(): void {
	//
	//	Draw to bitmap
	trace("Draw to bitmap");

	var bd: BitmapData = new BitmapData(_webView.width, _webView.height);
	_webView.drawViewPortToBitmapData(bd);
	_bitmap.bitmapData = bd;
}

function javascript(): void {
	//
	//	Javascript examples
	trace("Javascript example");

	//			_webView.evaluateJavascript( "document.body.style.backgroundColor='#f00';" );
	//			_webView.evaluateJavascript( "alert( 'test' )" );
	//			_webView.evaluateJavascript( "document.documentElement.outerHTML" );
	//			_webView.evaluateJavascript( "(function() { document.getElementsByTagName('video')[0].play(); })()" );

	_webView.evaluateJavascript("window.location.href");

	// Alternative method (will not trigger response event)
	//			_webView.loadURL( "javascript:alert('test')" );
}


function airPrint(): void {
	//
	// 	iOS AirPrint
	trace("Print example");

	if (_webView.isPrintSupported) {
		trace("Printing");
		var po: PrintOptions = new PrintOptions();
		_webView.print(po);
	}
}


function webView_locationChangingHandler(event: NativeWebViewEvent): void {
	trace("location changing: " + event.data);
	webWin.loaderMC.visible = true;
	webWin.printMC.visible = false;

	// Cancel this operation by calling `event.preventDefault()'
	// event.preventDefault();
}

function webView_locationChangeHandler(event: NativeWebViewEvent): void {
	trace("location change: " + event.data);
	webWin.printMC.visible = false;
}

function webView_completeHandler(event: NativeWebViewEvent): void {
	trace("COMPLETE:: " + event.data);
	webWin.loaderMC.visible = false;
	webWin.titleTXT.text = event.data;
	if(appType == "iOS"){
	webWin.printMC.visible = true;
	}

	trace("Location:   " + _webView.location);
	trace("UserAgent:  " + _webView.userAgent);
	trace("StatusCode: " + _webView.statusCode);
	trace("HTML: " + _webView.htmlSource);
}

function webView_errorHandler(event: NativeWebViewEvent): void {
	trace("ERROR:: " + event.data);
	trace("Location:   " + _webView.location);
	webWin.loaderMC.visible = false;
	webWin.printMC.visible = false;
}

function webView_javascriptResponseHandler(event: NativeWebViewEvent): void {
	trace("Javascript Response: " + event.data);
	webWin.loaderMC.visible = false;
	webWin.printMC.visible = false;
}

function webView_javascriptMessageHandler(event: NativeWebViewEvent): void {
	trace("Javascript Message: " + event.data);
	webWin.loaderMC.visible = false;
	webWin.printMC.visible = false;
}

function webView_tapHandler(event: TouchEvent): void {
	trace("Tap: " + event.localX + "x" + event.localY);
}

function keyDownHandler(event: KeyboardEvent): void {
	trace("keyDownHandler(): " + event.keyCode);
	webWin.loaderMC.visible = false;
	webWin.printMC.visible = false;
	switch (event.keyCode) {
		case Keyboard.BACK:
			event.preventDefault();
			event.stopImmediatePropagation();
			break;
	}
}