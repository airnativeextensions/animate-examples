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
 * @author 		"Michael Archbold (ma&#64;distriqt.com)"
 * @copyright	http://distriqt.com/copyright/license.txt
 */

import com.distriqt.extension.camera.Camera;
import com.distriqt.extension.camera.device.CameraDevice;
import com.distriqt.extension.camera.device.CameraDeviceInfo;
import com.distriqt.extension.camera.device.CameraMode;
import com.distriqt.extension.camera.device.CameraParameters;
import com.distriqt.extension.camera.events.CameraEvent;
import com.distriqt.extension.camera.events.AuthorisationEvent;
import com.distriqt.extension.camera.AuthorisationStatus;
import com.distriqt.extension.camera.AuthorisationType;
import com.distriqt.extension.camera.device.CaptureImageRequest;
import com.distriqt.extension.camera.device.CaptureImageResult;
import com.distriqt.extension.camera.events.CameraCaptureEvent;
import com.distriqt.extension.camera.events.CameraEvent;



import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.setTimeout;
import flash.display3D.textures.Texture;
import flash.events.Event;

var Camera = com.distriqt.extension.camera.Camera;

var _device: CameraDevice;
var lastFrameProcessed: Number = -1;
var videoData: ByteArray = new ByteArray();
var bitmapData: BitmapData = new BitmapData(1280, 720, false);
var bitmap: Bitmap;
var S: int = 0;
var fTimer: Timer;



try {
	Camera.init("KEY GOES HERE");
	if (Camera.isSupported) {
		trace("version: " + Camera.instance.version);
	}
} catch (e: Error) {
	trace(e);
	trace(e.message);
}


function getBackCamera() {
	bitmap = new Bitmap(bitmapData);
	bitmap.rotation = 90;
	bitmap.x = bitmap.width;
	bitmap.y = 0;
	settingsWin.camPreviewMC.addChild(bitmap);
	var devices: Array = Camera.instance.getAvailableDevices();
	for each(var deviceInfo: CameraDeviceInfo in devices) {
		if (deviceInfo.position == CameraDeviceInfo.POSITION_BACK) {
			var options: CameraParameters = new CameraParameters();
			options.enableFrameBuffer = true;
			options.previewMode = new CameraMode(CameraMode.PRESET_1280x720);
			options.cameraMode = new CameraMode(CameraMode.PRESET_1280x720);
			_device = Camera.instance.connect(deviceInfo, options);
			if (_device == null) {
				trace("failed to connect");
			} else {
				_device.addEventListener(CameraEvent.VIDEO_FRAME, camera_videoFrameHandler);
			}
		}
	}
}


//PREVIEW 

function camera_videoFrameHandler(event: CameraEvent): void {
	lastFrameProcessed = -1;
	var frame: Number = _device.receivedFrames;
	if (frame != lastFrameProcessed) {
		_device.getFrameBuffer(videoData);
		var rect: Rectangle = new Rectangle(0, 0, 1280, 720);
		if (bitmapData.width != _device.width || bitmapData.height != _device.height) {
			bitmapData = new BitmapData(1280, 720, false);
			bitmap.bitmapData.dispose();
			bitmap.bitmapData = bitmapData;
			bitmap.x = bitmap.width;
			bitmap.y = 0;
		}
		try {
			bitmapData.setPixels(rect, videoData);
		} catch (e: Error) {
			trace("ERROR::setPixels: " + e.message);
		}
		videoData.clear();
		lastFrameProcessed = frame;
	}
}


function disconnect(): void {
	settingsWin.camPreviewMC.removeChild(bitmap);
	try {
		trace("disconnect");
		if (_device != null) {
			_device.removeEventListener(CameraEvent.VIDEO_FRAME, camera_videoFrameHandler);
			var success: Boolean = _device.disconnect();
			trace("disconnect: " + success);
			_device = null;
		}
	} catch (e: Error) {
		trace(e.message);
	}
	closeCameraWin();
}


//
//	CAPTURE
//


function capture(): void {
	trace("capture");
	if (_device != null) {
		var request: CaptureImageRequest = new CaptureImageRequest();
		request.saveToCameraRoll = true;
		request.waitForAdjustments = true;

		_device.addEventListener( CameraCaptureEvent.COMPLETE, captureComplete_Handler );
		_device.addEventListener(CameraCaptureEvent.ERROR, captureHandler);
		_device.addEventListener(CameraCaptureEvent.IMAGE_SAVE_COMPLETE, captureHandler);
		_device.addEventListener(CameraCaptureEvent.IMAGE_SAVE_ERROR, captureHandler);

		_device.captureImage(request);
	}
}

function captureNoAdjustments(): void {
	trace("captureNoAdjustments");
	if (_device != null) {
		var request: CaptureImageRequest = new CaptureImageRequest();
		request.saveToCameraRoll = true;
		request.waitForAdjustments = false;

		_device.addEventListener( CameraCaptureEvent.COMPLETE, captureComplete_Handler );
		_device.addEventListener(CameraCaptureEvent.ERROR, captureHandler);
		_device.addEventListener(CameraCaptureEvent.IMAGE_SAVE_COMPLETE, captureHandler);
		_device.addEventListener(CameraCaptureEvent.IMAGE_SAVE_ERROR, captureHandler);

		_device.captureImage(request);
	}
}

function captureHandler(event: CameraCaptureEvent): void {
	trace("captureHandler( " + event.type + " )");
}

//CAPTURED IMAGE TO DISPLAY

function captureComplete_Handler( event:CameraCaptureEvent ):void
		{
			trace( "captureComplete_Handler( " + event.type +" )" );
			
			var result:CaptureImageResult = _device.captureImageResult();
			if (result != null && result.data != null)
			{
				trace( "captured: "+result.data.width +"x"+result.data.height + " ["+result.orientation+"]" );
				
					//if (result.data.width < 2048 && result.data.height < 2048)
					//{
						//_imageTexture = (result.data);
						//_image = new Image( _imageTexture );
						//addChildAt( _image, 0 );
					//}
				//else if (_imageTexture.width != result.data.width || _imageTexture.height != result.data.height)
				//{
					//if (contains(_image)) removeChild(_image);
					//_imageTexture.dispose();
					//_image.dispose();
					
					//_imageTexture = (result.data);
					//_image = new Image( _imageTexture );
					//addChildAt( _image, 0 );
				//}
				//else 
				//{
					//
				//}
			}
		}


//
//	PARAMETERS
//	

function flashModeTorch(): void {
	if (_device != null) {
		if (_device.isTorchSupported()) {
			_device.setFlashMode(CameraParameters.FLASH_MODE_TORCH);
		}
	}
}

function flashModeAuto(): void {
	if (_device != null) {
		if (_device.isFlashSupported()) {
			_device.setFlashMode(CameraParameters.FLASH_MODE_AUTO);
		}
	}
}

function flashModeOn(): void {
	if (_device != null) {
		if (_device.isFlashSupported()) {
			_device.setFlashMode(CameraParameters.FLASH_MODE_ON);
		}
	}
}

function flashModeOff(): void {
	if (_device != null) {
		if (_device.isFlashSupported()) {
			_device.setFlashMode(CameraParameters.FLASH_MODE_OFF);
		}
	}
}

function exposureAuto(): void {
	if (_device != null) {
		if (_device.isExposureSupported(CameraParameters.EXPOSURE_MODE_AUTO)) {
			_device.setExposureMode(CameraParameters.EXPOSURE_MODE_AUTO);
		}
	}
}

function exposureLocked(): void {
	if (_device != null) {
		if (_device.isExposureSupported(CameraParameters.EXPOSURE_MODE_LOCKED)) {
			_device.setExposureMode(CameraParameters.EXPOSURE_MODE_LOCKED);
		}
	}
}

function exposureContinuous(): void {
	if (_device != null) {
		if (_device.isExposureSupported(CameraParameters.EXPOSURE_MODE_CONTINUOUS)) {
			_device.setExposureMode(CameraParameters.EXPOSURE_MODE_CONTINUOUS);
		}
	}
}