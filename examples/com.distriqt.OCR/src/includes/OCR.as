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
 * Core features of OCR ANE
 *
 */


//Define Classes
import com.distriqt.extension.ocr.OCR;
import com.distriqt.extension.ocr.OCROptions;
import com.distriqt.extension.ocr.events.OCREvent;

//Set up Application Key
OCR.init("KEY GOES HERE");


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;

var imageType: String;

[Embed(source = "image_sample.jpg")]
var Image: Class;

var imageLocal: Bitmap = new Image() as Bitmap;

var image: Bitmap = new Image() as Bitmap;


// Core OCR function
function startOCR(): void {
	OCR.service.addEventListener(OCREvent.RECOGNISE, ocr_recogniseHandler);
	OCR.service.addEventListener(OCREvent.RECOGNISE_ERROR, ocr_recogniseErrorHandler);

	//OCR Options
	var options: OCROptions = new OCROptions();
	options.language = "eng"; // LANGUAGES
	//options.whitelist = "0123456789.,€$";  //WHITELIST CHARACTERS

	//Analyze Bitmap Data from embedded image
	if (imageType == "sample") {
		OCR.service.recognise(imageLocal.bitmapData, options);
		if (mediaMC.numChildren > 0) {
			mediaMC.removeChildAt(0);
		}
		imageLocal.height = (imageLocal.bitmapData.height / imageLocal.bitmapData.width * 410);
		imageLocal.width = 410;
		mediaMC.addChild(imageLocal);
	}
	
	//Analyze Bitmap Data from Camera Roll image
	if (imageType == "cameraRoll") {
		OCR.service.recognise(image.bitmapData, options);
		if (mediaMC.numChildren > 0) {
			mediaMC.removeChildAt(0);
		}
		image.height = (image.bitmapData.height / image.bitmapData.width * 410);
		image.width = 410;
		mediaMC.addChild(image);
	}
}


//Text recognized!
function ocr_recogniseHandler(event: OCREvent): void {
	trace("RECOGNIZED: ");
	trace(event.text);
	//Make sure you embed font for text field.
	OCR_txt.text = event.text;
}

//Errors
function ocr_recogniseErrorHandler(event: OCREvent): void {
	trace("An Error occurred");
	OCR_txt.text = "An error occurred";
}