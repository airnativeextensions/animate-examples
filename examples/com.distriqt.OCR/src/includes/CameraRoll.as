import flash.media.MediaPromise;
import flash.events.MediaEvent;
import flash.media.CameraRoll;
import flash.media.CameraUI;
import flash.permissions.PermissionStatus;


var dataSource: IDataInput;
var _filename;

var cameraPicLoader: Loader = new Loader();

var cr: CameraRoll = new CameraRoll();


function addBrowseListeners(): void {

	cr.addEventListener(MediaEvent.SELECT, onImgSelect);
	cr.addEventListener(Event.CANCEL, onCancel);
	cr.addEventListener(ErrorEvent.ERROR, onError);

}

function removeBrowseListeners(): void {

	cr.removeEventListener(MediaEvent.SELECT, onImgSelect);
	cr.removeEventListener(Event.CANCEL, onCancel);
	cr.removeEventListener(ErrorEvent.ERROR, onError);

}


function accessCameraRoll(): void {
	if (CameraRoll.permissionStatus != PermissionStatus.GRANTED) {
		cr.addEventListener(PermissionEvent.PERMISSION_STATUS,
			function (e: PermissionEvent): void {
				if (e.status == PermissionStatus.GRANTED) {
					addBrowseListeners();
					cr.browseForImage();
				} else {
					// permission denied
				}
			});

		try {
			cr.requestPermission();
		} catch (e: Error) {
			// another request is in progress
		}
	} else {
		addBrowseListeners();
		cr.browseForImage();
	}

}


function onCancel(event: Event): void {
	removeBrowseListeners();
}

function onImgSelect(event: MediaEvent): void {
	var promise: MediaPromise = event.data as MediaPromise;
	_filename = "userPic.jpg";

	removeBrowseListeners();

	dataSource = promise.open();
	var eventSource: IEventDispatcher = dataSource as IEventDispatcher;
	eventSource.addEventListener(Event.COMPLETE, onMediaLoaded);

}

function onMediaLoaded(event: Event): void {
	var data: ByteArray = new ByteArray();
	dataSource.readBytes(data);

	cameraPicLoader.loadBytes(data);
	cameraPicLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
}



function onImageLoaded(event: Event): void {
	cameraPicLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageLoaded);
	cameraPicLoader.contentLoaderInfo.removeEventListener(ErrorEvent.ERROR, onError);
	
	var crPicData: BitmapData = Bitmap(event.currentTarget.content).bitmapData;
	image = new Bitmap(crPicData);
	startOCR();
}

function onError(event: ErrorEvent): void {
	trace("Camera Roll Error");
}