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

import com.distriqt.extension.camerarollextended.Asset;
import com.distriqt.extension.camerarollextended.AssetRepresentation;
import com.distriqt.extension.camerarollextended.AuthorisationStatus;
import com.distriqt.extension.camerarollextended.CameraRollExtended;
import com.distriqt.extension.camerarollextended.CameraRollExtendedBrowseOptions;
import com.distriqt.extension.camerarollextended.events.AssetFileEvent;
import com.distriqt.extension.camerarollextended.events.AuthorisationEvent;
import com.distriqt.extension.camerarollextended.events.CameraRollExtendedEvent;


var _bitmap: Bitmap;
var _assets: Array;

try {
	CameraRollExtended.init("APP KEY HERE");
	if (CameraRollExtended.isSupported) {
		trace("CameraRollExtended Version:     " + CameraRollExtended.service.version);
		CameraRollExtended.service.addEventListener(AuthorisationEvent.CHANGED, authorisationStatus_changedHandler);

		CameraRollExtended.service.addEventListener(CameraRollExtendedEvent.CANCEL, cameraRoll_cancelHandler);
		CameraRollExtended.service.addEventListener(CameraRollExtendedEvent.SELECT, cameraRoll_selectHandler);
		CameraRollExtended.service.addEventListener(CameraRollExtendedEvent.LOADED, cameraRoll_loadedHandler);
		CameraRollExtended.service.addEventListener(CameraRollExtendedEvent.ASSET_LOADED, cameraRoll_assetLoadedHandler);
		CameraRollExtended.service.addEventListener(CameraRollExtendedEvent.ASSET_ERROR, cameraRoll_assetErrorHandler);

		CameraRollExtended.service.addEventListener(AssetFileEvent.FILE_FOR_ASSET_COMPLETE, fileForAssetCompleteHandler);
	}
} catch (e: Error) {
	trace(e);
}


function checkAndRequestAuthorisation(): void {
	switch (CameraRollExtended.service.authorisationStatus()) {
		case AuthorisationStatus.SHOULD_EXPLAIN:
		case AuthorisationStatus.NOT_DETERMINED:
			// REQUEST ACCESS: This will display the permission dialog
			CameraRollExtended.service.requestAccess();
			trace("CameraRollExtended Auth Status: " + CameraRollExtended.service.authorisationStatus());
			return;

		case AuthorisationStatus.DENIED:
		case AuthorisationStatus.UNKNOWN:
		case AuthorisationStatus.RESTRICTED:
			// ACCESS DENIED: You should inform your user appropriately
			return;

		case AuthorisationStatus.AUTHORISED:
			// AUTHORISED: CameraRoll will be available
			break;
	}
}

function authorisationStatus_changedHandler(event: AuthorisationEvent): void {
	trace("authorisation status changed: " + event.status);
}




function openCameraRoll(): void {
	trace("Browse");
	var options: CameraRollExtendedBrowseOptions = new CameraRollExtendedBrowseOptions();

	//options.minimumCount = 2;
	options.maximumCount = 1;
	options.type = Asset.IMAGE;

	if (appType == "iOS") {
		options.useNativePicker = false;
		options.autoCloseOnCountReached = true;
	}

	if (appType == "android") {
		trace("use native picker");
		options.useNativePicker = true;
		options.autoCloseOnCountReached = true;
	}

	CameraRollExtended.service.browseForAsset(options);
}



function cameraRoll_cancelHandler(event: CameraRollExtendedEvent): void {
	trace("camera roll cancelled");
}


function cameraRoll_selectHandler(event: CameraRollExtendedEvent): void {
	trace("camera roll select");
	_assets = event.assets;
	for each(var asset: Asset in event.assets) {
		trace(asset.toString());

		// Attempt to get a File reference
		CameraRollExtended.service.getFileForAssetAsync(asset);

		// Load the image asset // AssetRepresentation.FULL_RESOLUTION // ASPECT_RATIO_THUMBNAIL // THUMBNAIL
		if (asset.type == Asset.IMAGE) {
			CameraRollExtended.service.loadAssetByURL(asset.url, AssetRepresentation.THUMBNAIL);
		}
	}
}


function cameraRoll_loadedHandler(event: CameraRollExtendedEvent): void {
	trace("camera roll loaded");
	for each(var asset: Asset in event.assets) {
		trace(asset.toString());
	}
}


function cameraRoll_assetLoadedHandler(event: CameraRollExtendedEvent): void {
	trace("camera roll asset loaded");

	var asset: Asset = event.assets[0];

	trace("asset orientation: " + asset.orientation);

	if (_bitmap != null) {
		removeChild(_bitmap);
		if (_bitmap.bitmapData != null) _bitmap.bitmapData.dispose();
		_bitmap = null;
	}

	_bitmap = new Bitmap(asset.bitmapData);
	_bitmap.y = 200;
	if (_bitmap.width > stage.stageWidth * 0.5) {
		_bitmap.width = stage.stageWidth * 0.5;
		_bitmap.scaleY = _bitmap.scaleX;
	}
	addChild(_bitmap);
}


function cameraRoll_assetErrorHandler(event: CameraRollExtendedEvent): void {
	var asset: Asset = event.assets[0];
	trace("camera roll asset error: " + asset.filename + " :: " + event.message);
}

function fileForAssetCompleteHandler(event: AssetFileEvent): void {
	trace("fileForAssetCompleteHandler");
	if (event.file != null) {
		trace("file: " + event.file.nativePath);
	}
}