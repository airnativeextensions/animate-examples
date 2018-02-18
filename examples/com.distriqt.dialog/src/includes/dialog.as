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
 * @author 		"Michael Archbold"
 * @copyright	http://distriqt.com/copyright/license.txt
 */

import com.distriqt.extension.dialog.Dialog;
import com.distriqt.extension.dialog.Gravity;
import com.distriqt.extension.dialog.DateTimeDialogView;
import com.distriqt.extension.dialog.DialogTheme;
import com.distriqt.extension.dialog.DialogType;
import com.distriqt.extension.dialog.DialogView;
import com.distriqt.extension.dialog.ProgressDialogView;
import com.distriqt.extension.dialog.builders.AlertBuilder;
import com.distriqt.extension.dialog.builders.ActivityBuilder;
import com.distriqt.extension.dialog.builders.PickerDialogBuilder;
import com.distriqt.extension.dialog.builders.ProgressDialogBuilder;
import com.distriqt.extension.dialog.builders.DateTimeDialogBuilder;
import com.distriqt.extension.dialog.objects.DialogAction;
import com.distriqt.extension.dialog.objects.DateTimePickerOptions;
import com.distriqt.extension.dialog.objects.DialogData;
import com.distriqt.extension.dialog.objects.DialogParameters;
import com.distriqt.extension.dialog.events.DialogViewEvent;
import com.distriqt.extension.dialog.events.DialogDateTimeEvent;
import com.distriqt.extension.dialog.events.DialogEvent;

import flash.utils.clearInterval;
import flash.utils.setInterval;



try {
	Dialog.init("YOUR KEY HERE");
	if (Dialog.isSupported) {
		trace("Dialog Supported: " + Dialog.isSupported);
		trace("Dialog Version:   " + Dialog.service.version);

	}
} catch (e: Error) {
	trace(e);
}






var _state: int = 0;

function startDialogEvents(): void {
	Dialog.service.setDefaultTheme(new DialogTheme(DialogTheme.DEVICE_DEFAULT));
	switch (_state) {
		case 0:
			{

				showToast();
				actionBTN.btnUI.btnTxt.txt.text = "ALERT DIALOG";
				break;
			}

		case 1:
			{
				showAlertDialog();
				actionBTN.btnUI.btnTxt.txt.text = "MULTIPLE CHOICE";
				break;
			}

		case 2:
			{
				showMultipleChoiceDialog();
				actionBTN.btnUI.btnTxt.txt.text = "LOADING DIALOG";
				break;
			}

		case 3:
			{
				showLoadingDialog();
				actionBTN.btnUI.btnTxt.txt.text = "PROGRESS DIALOG";
				break;
			}

		case 4:
			{
				showProgressDialog();
				actionBTN.btnUI.btnTxt.txt.text = "PICKER";
				break;
			}

		case 5:
			{
				showPicker();
				actionBTN.btnUI.btnTxt.txt.text = "DATE PICKER";
				break;
			}

		case 6:
			{
				showDateTime();
				actionBTN.btnUI.btnTxt.txt.text = "TOAST DIALOG";
				break;
			}


		default:
			{
				_state = 0;
				showToast();
				actionBTN.btnUI.btnTxt.txt.text = "TOAST DIALOG";
			}
	}
	_state++;
}



//TIMED MESSAGE
function showToast(): void {
	trace("Dialog.service.toast( 'mesage', duration, color, position );");
	Dialog.service.toast("This is a toast", Dialog.LENGTH_SHORT, 0x333333, Gravity.MIDDLE);
}


//ALERTS
function showAlertDialog(): void {
	var view: DialogView = Dialog.service.create(
		new AlertBuilder()
		.setTitle("test")
		.setMessage("message")
		.setCancelLabel("Cancel")
		.addOption("OK", DialogAction.STYLE_POSITIVE, 0)
		.build()
	);

	view.show();
	view.addEventListener(DialogViewEvent.CLOSED, function (e: DialogViewEvent): void {
		var v: DialogView = DialogView(e.currentTarget);
		v.removeEventListener(DialogViewEvent.CLOSED, arguments.callee);
		v.dispose();
	});
}


//MULTIPLE CHOICE
function showMultipleChoiceDialog(): void {
	var view: DialogView = Dialog.service.create(
		new AlertBuilder()
		.setTitle("title")
		.setMessage("message")
		.addOption("option 1")
		.addOption("option 2")
		.addOption("option 3")
		.addOption("option 4")
		.build()
	);

	view.show();
	view.addEventListener(DialogViewEvent.CLOSED, function (e: DialogViewEvent): void {
		var v: DialogView = DialogView(e.currentTarget);
		v.removeEventListener(DialogViewEvent.CLOSED, arguments.callee);
		v.dispose();
	});
}


function showLoadingDialog(): void {
	var activityDialog: DialogView = Dialog.service.create(
		new ActivityBuilder()
		.setTheme(new DialogTheme(DialogTheme.DEVICE_DEFAULT_DARK))
		.build()
	);
	activityDialog.show();

	function removeLoadingDialog(): void {
		activityDialog.dismiss();
	}
}



//PROGRESS
var _progressDialogView: ProgressDialogView;
var _progressInterval: uint;
var _progress: Number = 0;

function showProgressDialog(): void {

	_progressDialogView = Dialog.service.create(
		new ProgressDialogBuilder()
		.setTitle("title")
		.setMessage("message")
		.setStyle(DialogType.STYLE_HORIZONTAL)
		.build()
	);

	_progressDialogView.show();
	
	_progressDialogView.addEventListener(DialogViewEvent.CLOSED, function (e: DialogViewEvent): void {
		var v: DialogView = DialogView(e.currentTarget);
		v.removeEventListener(DialogViewEvent.CLOSED, arguments.callee);
		v.dispose();
	});

	_progressInterval = setInterval(progressDialogIntervalHandler, 50);
}


function progressDialogIntervalHandler(): void {
	// Update the progress dialog
	_progress += 0.01;
	if (_progress >= 1) {
		clearInterval(_progressInterval);
		_progressDialogView.dismiss();
	} else {
		_progressDialogView.update(_progress);
	}

}


//PICKER
function showPicker(): void {
	var picker: DialogView = Dialog.service.create(
		new PickerDialogBuilder(true)
		.setTitle("Picker Title")
		.setCancelLabel("Cancel")
		.setAcceptLabel("OK")
		.addColumn(["Item A", "Item B", "Item C"], 0, "Items")
		.build()
	);
	picker.show();
}


//DATE / TIME PICKER
function showDateTime(): void {
	var dateTime: DateTimeDialogView = Dialog.service.create(
		new DateTimeDialogBuilder()
		.setMode(DialogType.MODE_TIME)
		.setTitle("Select Time")
		.setAcceptLabel("ACCEPT")
		.setCancelLabel("Cancel")
		.build()
	);
	dateTime.setTime(9, 30);

	dateTime.addEventListener(DialogViewEvent.CLOSED, dateTime_closedHandler);
	dateTime.addEventListener(DialogDateTimeEvent.SELECTED, dateTime_selectedHandler);

	dateTime.show();
}


function dateTime_selectedHandler(event: DialogDateTimeEvent): void {
	trace(event.type + "::" + event.date.toString());
}

function dateTime_closedHandler(event: DialogViewEvent): void {
	var dateTime: DateTimeDialogView = DateTimeDialogView(event.currentTarget);
	dateTime.removeEventListener(DialogViewEvent.CLOSED, dateTime_closedHandler);
	dateTime.removeEventListener(DialogDateTimeEvent.SELECTED, dateTime_selectedHandler);
	dateTime.dispose();
}