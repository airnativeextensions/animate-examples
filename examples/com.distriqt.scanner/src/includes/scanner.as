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
 * Core features of Scanner ANE
 *
 */

//Define Classes

import com.distriqt.extension.scanner.AuthorisationStatus;
import com.distriqt.extension.scanner.Scanner;
import com.distriqt.extension.scanner.ScannerInfo;
import com.distriqt.extension.scanner.ScannerOptions;
import com.distriqt.extension.scanner.Symbology;
import com.distriqt.extension.scanner.events.AuthorisationEvent;
import com.distriqt.extension.scanner.events.ScannerEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;

var _timeout: int = 0;
var _overlay: Bitmap;




try {
	//App Key
	Scanner.init("KEY GOES HERE");
	trace("Scanner Supported: " + Scanner.isSupported);
	trace("Scanner Version:   " + Scanner.service.version);

	Scanner.service.addEventListener(ScannerEvent.CODE_FOUND, scanner_codeFoundHandler);
	Scanner.service.addEventListener(ScannerEvent.SCAN_START, scanner_startHandler);
	Scanner.service.addEventListener(ScannerEvent.SCAN_STOPPED, scanner_stopHandler);
	Scanner.service.addEventListener(ScannerEvent.CANCELLED, scanner_cancelledHandler);


	var info: ScannerInfo = Scanner.service.getScannerInfo();
	trace("info: " + info.algorithm + " [" + info.version + "]");

	//Custom Overlay image for Scanner
	if (screenWidth > 620 && screenWidth < 650) {
		[Embed(source = "scannerOverlay_640.png")]
		var OverlayImage_640: Class;
		_overlay = new OverlayImage_640();
	}
	if (screenWidth > 700 && screenWidth < 730) {
		[Embed(source = "scannerOverlay_720.png")]
		var OverlayImage_720: Class;
		_overlay = new OverlayImage_720();
	}
	if (screenWidth > 730 && screenWidth < 760) {
		[Embed(source = "scannerOverlay_750.png")]
		var OverlayImage_750: Class;
		_overlay = new OverlayImage_750();
	}
	if (screenWidth > 1000 && screenWidth < 1100) {
		[Embed(source = "scannerOverlay_1080.png")]
		var OverlayImage_1080: Class;
		_overlay = new OverlayImage_1080();
	}

} catch (e: Error) {
	trace("ERROR::" + e.message);
}

//GET PERMISSION FOR CAMERA
function accessScanner(): void {

	trace("Scanner Authorisation Status: " + Scanner.service.authorisationStatus());
	Scanner.service.addEventListener(AuthorisationEvent.CHANGED, authorisationChangedHandler);
	switch (Scanner.service.authorisationStatus()) {
		case AuthorisationStatus.NOT_DETERMINED:
		case AuthorisationStatus.SHOULD_EXPLAIN:
			// REQUEST ACCESS: This will display the permission dialog
			Scanner.service.requestAccess();
			return;

		case AuthorisationStatus.DENIED:
		case AuthorisationStatus.UNKNOWN:
		case AuthorisationStatus.RESTRICTED:
			// ACCESS DENIED: You should inform your user appropriately
			return;

		case AuthorisationStatus.AUTHORISED:
			// AUTHORISED: Scanner will be available
			startScan();
			break;
	}
}

function authorisationChangedHandler(event: AuthorisationEvent): void {
	switch (event.status) {
		case AuthorisationStatus.SHOULD_EXPLAIN:
			// Should display a reason you need this feature
			break;

		case AuthorisationStatus.AUTHORISED:
			// AUTHORISED: Camera will be available
			startScan();
			break;

		case AuthorisationStatus.RESTRICTED:
		case AuthorisationStatus.DENIED:
			// ACCESS DENIED: You should inform your user appropriately
			break;
	}
}


function startScan(): void {
	var options: ScannerOptions = new ScannerOptions();
	options.singleResult = true;
	//options.heading = "CENTER BARCODE IN WINDOW";
	//options.message = "A big message has to be good really really good";
	options.cancelLabel = "CANCEL SCAN";

	options.colour = 0x4863A0;
	options.textColour = 0xFFFFFF;

	options.overlay = _overlay.bitmapData;
	options.overlayAutoScale = false;

	options.x_density = 1;
	options.y_density = 1;

	//SET BARCODE TYPES HERE (Default is all)
	options.symbologies = [];
	//options.symbologies = [ Symbology.QRCODE,Symbology.CODE39 ];

	options.refocusInterval = 0;

	//SET CAMERA TO ACCESS
	options.camera = ScannerOptions.CAMERA_REAR;

	//TURN ON/OFF FLASH
	options.torchMode = ScannerOptions.TORCH_AUTO;

	var success: Boolean = Scanner.service.startScan(options);

	trace("scan started = " + success);

	//			_timeout = setTimeout( stopScan, 10000 );
}


function stopScan(): void {
	clearTimeout(_timeout);

	Scanner.service.removeEventListener(ScannerEvent.CODE_FOUND, scanner_codeFoundHandler);
	Scanner.service.removeEventListener(ScannerEvent.SCAN_START, scanner_startHandler);
	Scanner.service.removeEventListener(ScannerEvent.SCAN_STOPPED, scanner_stopHandler);
	Scanner.service.removeEventListener(ScannerEvent.CANCELLED, scanner_cancelledHandler);

	//Scanner.service.dispose();
}


function activateHandler(event: Event): void {
	trace("activateHandler() ");
}

function deactivateHandler(event: Event): void {
	trace("deactivateHandler() ");
}


//
//	EXTENSION HANDLERS
//


function scanner_startHandler(event: ScannerEvent): void {
	trace(event.type);
}


function scanner_stopHandler(event: ScannerEvent): void {
	trace(event.type);
	stopScan();
}


function scanner_cancelledHandler(event: ScannerEvent): void {
	trace(event.type);
}


function scanner_codeFoundHandler(event: ScannerEvent): void {
	trace("code found: " + event.data + "[" + event.orientation + "] :: (" + event.bounds.toString() + ")");
	barcodeTXT.text = event.data;
}