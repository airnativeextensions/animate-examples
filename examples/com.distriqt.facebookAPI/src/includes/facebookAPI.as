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
 * @created		08/01/2016
 * @copyright	http://distriqt.com/copyright/license.txt
 */
//Define Classes
import com.distriqt.extension.core.Core;
import com.distriqt.extension.facebookapi.AccessToken;
import com.distriqt.extension.facebookapi.FacebookAPI;
import com.distriqt.extension.facebookapi.FacebookPermissions;
import com.distriqt.extension.facebookapi.LoginBehaviour;
import com.distriqt.extension.facebookapi.accountkit.ResponseType;
import com.distriqt.extension.facebookapi.appevents.AppEventsConstants;
import com.distriqt.extension.facebookapi.appevents.FacebookAppEvent;
import com.distriqt.extension.facebookapi.appevents.FacebookAppPurchaseEvent;
import com.distriqt.extension.facebookapi.appinvites.AppLink;
import com.distriqt.extension.facebookapi.appinvites.builders.AppInviteContentBuilder;
import com.distriqt.extension.facebookapi.events.AccountKitEvent;
import com.distriqt.extension.facebookapi.events.AppInviteEvent;
import com.distriqt.extension.facebookapi.events.AppLinkEvent;
import com.distriqt.extension.facebookapi.events.FacebookAPISessionEvent;
import com.distriqt.extension.facebookapi.events.GameRequestEvent;
import com.distriqt.extension.facebookapi.events.GraphAPIRequestEvent;
import com.distriqt.extension.facebookapi.events.ShareAPIEvent;
import com.distriqt.extension.facebookapi.events.ShareDialogEvent;
import com.distriqt.extension.facebookapi.games.builders.GameRequestContentBuilder;
import com.distriqt.extension.facebookapi.graphapi.GraphAPIRequest;
import com.distriqt.extension.facebookapi.graphapi.builders.GraphAPIRequestBuilder;
import com.distriqt.extension.facebookapi.share.ShareAPI;
import com.distriqt.extension.facebookapi.share.builders.ShareLinkContentBuilder;
import com.distriqt.extension.facebookapi.share.builders.ShareMediaContentBuilder;
import com.distriqt.extension.facebookapi.share.builders.ShareOpenGraphActionBuilder;
import com.distriqt.extension.facebookapi.share.builders.ShareOpenGraphContentBuilder;
import com.distriqt.extension.facebookapi.share.builders.ShareOpenGraphObjectBuilder;
import com.distriqt.extension.facebookapi.share.builders.SharePhotoContentBuilder;
import com.distriqt.extension.facebookapi.share.builders.ShareVideoContentBuilder;

import flash.display.Bitmap;
import flash.filesystem.File;
import flash.net.URLRequest;
import flash.net.navigateToURL;

Core.init();

try {
	//DISTRIQT APP KEY HERE
	FacebookAPI.init("APP_KEY_HERE");
	trace("FacebookAPI Supported: " + FacebookAPI.isSupported);

	if (FacebookAPI.service.accountKit.isSupported) {
		FacebookAPI.service.accountKit.setup(ResponseType.ACCESS_TOKEN);
	}


	if (FacebookAPI.isSupported) {
		//	Functionality here
		trace("FacebookAPI Version:   " + FacebookAPI.service.version);

		FacebookAPI.service.initialiseApp( "YOUR_FACEBOOK_APP_ID" );

		trace("sdk version:            " + FacebookAPI.service.getSDKVersion());
		trace("isFacebookAppInstalled: " + FacebookAPI.service.isFacebookAppInstalled());
		trace("isSessionOpen:          " + FacebookAPI.service.isSessionOpen());

		var packagedAssets: File = File.applicationDirectory.resolvePath("assets");
		var accessibleAssets: File = File.applicationStorageDirectory.resolvePath("assets");
		if (accessibleAssets.exists) accessibleAssets.deleteDirectory(true);
		packagedAssets.copyTo(accessibleAssets, true);


		FacebookAPI.service.appLinks.addEventListener(AppLinkEvent.APP_LINK, appLinkHandler);
	}
} catch (e: Error) {
	trace(e);
}


// cycle through Facebook events
var _state: int = 0;

function startFacebookEvents(): void {
	switch (_state) {
		case 0:
			{
				loginFacebook();
				actionBTN.btnUI.btnTxt.txt.text = "Request Permissions";
				break;
			}


		case 1:
			{
				requestPermissions();
				actionBTN.btnUI.btnTxt.txt.text = "Share A Link";
				break;
			}

		case 2:
			{
				shareLinkContent();
				actionBTN.btnUI.btnTxt.txt.text = "Share A Photo";
				break;
			}

		case 3:
			{
				sharePhotoContent();
				actionBTN.btnUI.btnTxt.txt.text = "Share A Video";
				break;
			}


		case 4:
			{
				shareVideoContent();
				actionBTN.btnUI.btnTxt.txt.text = "Send Game Invite";
				break;
			}


		case 5:
			{
				gameRequest();
				actionBTN.btnUI.btnTxt.txt.text = "Graph Current User Info";
				break;
			}
			
		case 6:
			{
				graph_getCurrentUserInfo();
				actionBTN.btnUI.btnTxt.txt.text = "Graph Get Friends";
				break;
			}
			
		case 7:
			{
				graph_getFriends();
				actionBTN.btnUI.btnTxt.txt.text = "Graph Post Link";
				break;
			}
			
		case 8:
			{
				graph_postLink()
				actionBTN.btnUI.btnTxt.txt.text = "Set App Events";
				break;
			}
			
		case 9:
			{
				appEvents_setUserDetails();
				appEvents_logEvent();
				appEvents_logPurchase();
				actionBTN.btnUI.btnTxt.txt.text = "Logout Facebook";
				break;
			}
			
		case 10:
			{
				logout();
				actionBTN.btnUI.btnTxt.txt.text = "AKit Login w/Phone";
				break;
			}
			
		case 11:
			{
				accountKit_setup();
				accountKit_loginWithPhone();
				actionBTN.btnUI.btnTxt.txt.text = "AKit Logout";
				break;
			}
			
		case 12:
			{
				accountKit_logout();
				actionBTN.btnUI.btnTxt.txt.text = "Login to Facebook";
				break;
			}

		default:
			{
				_state = 0;
				loginFacebook();
				actionBTN.btnUI.btnTxt.txt.text = "Request Permissions";
			}
	}
	_state++;
}



var userID;

////////////////////////////////////////////////////////
// 	LOG IN
//

function loginFacebook(): void {
	trace("login");
	if (FacebookAPI.isSupported) {
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.SESSION_OPENED, fb_sessionOpenedHandler);
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.SESSION_INFO, fb_sessionInfoHandler);
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.SESSION_OPEN_ERROR, fb_sessionOpenErrorHandler);
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.SESSION_OPEN_CANCELLED, fb_sessionOpenCancelledHandler);
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.SESSION_OPEN_DISABLED, fb_sessionOpenDisabledHandler);

		var permissions: Array = ["public_profile", FacebookPermissions.USER_EMAIL, "user_friends"];

		var success: Boolean = FacebookAPI.service.createSession(permissions, true, LoginBehaviour.NATIVE_WITH_FALLBACK);
		trace("createSession = " + success);

		FacebookAPI.service.appEvents.setUserID("user1234");
		trace("User added for Analytics");
	}
}



function getAccessToken(): void {
	trace("getAccessToken");
	if (FacebookAPI.isSupported) {
		var accessToken: com.distriqt.extension.facebookapi.AccessToken = FacebookAPI.service.getAccessToken();
		if (accessToken != null) {
			trace("accessToken = " + accessToken.token);
		} else {
			trace("accessToken = null");
		}
	}
}

function logout(): void {
	trace("logout");
	if (FacebookAPI.isSupported) {
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.SESSION_CLOSED, fb_sessionClosedHandler);
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.SESSION_CLOSE_ERROR, fb_sessionCloseErrorHandler);

		FacebookAPI.service.closeSession();
	}
}


function fb_sessionOpenedHandler(event: FacebookAPISessionEvent): void {
	trace("FacebookAPISessionEvent::SESSION_OPENED");
	trace("accessToken=" + event.accessToken.token);
	trace("User ID:         " + event.accessToken.userId);
	userID = event.accessToken.userId;
	trace("Expiration date: " + event.accessToken.expirationTimestamp);
	trace("Permissions:     " + event.accessToken.permissions.join(", "));
}

function fb_sessionInfoHandler(event: FacebookAPISessionEvent): void {
	trace("FacebookAPISessionEvent::SESSION_INFO");
	trace("profile: " + event.profile.name);
	usernameTXT.text = event.profile.name + " is logged in.";

}

function fb_sessionOpenErrorHandler(event: FacebookAPISessionEvent): void {
	trace("FacebookAPISessionEvent::SESSION_OPEN_ERROR");
	trace("error=[" + event.errorCode + "]: " + event.errorMessage);
}

function fb_sessionOpenCancelledHandler(event: FacebookAPISessionEvent): void {
	trace("FacebookAPISessionEvent::SESSION_OPEN_CANCELLED");
	trace("User cancelled sign-in");
}

function fb_sessionOpenDisabledHandler(event: FacebookAPISessionEvent): void {
	trace("FacebookAPISessionEvent::SESSION_OPEN_DISABLED");
	trace("Session login is disabled");
}

function fb_sessionClosedHandler(event: FacebookAPISessionEvent): void {
	trace("FacebookAPISessionEvent::SESSION_CLOSED");
	usernameTXT.text = "You are logged out.";
}

function fb_sessionCloseErrorHandler(event: FacebookAPISessionEvent): void {
	trace("FacebookAPISessionEvent::SESSION_CLOSE_ERROR");
	trace("error=[" + event.errorCode + "]: " + event.errorMessage);
}



////////////////////////////////////////////////////////
// 	CHANGE / REQUEST PERMISSIONS
//

function requestPermissions(): void {
	trace("requestPermissions()");
	if (FacebookAPI.isSupported) {
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.REQUEST_PERMISSIONS_CANCELLED, requestPermissionsHandler);
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.REQUEST_PERMISSIONS_COMPLETED, requestPermissionsHandler);
		FacebookAPI.service.addEventListener(FacebookAPISessionEvent.REQUEST_PERMISSIONS_ERROR, requestPermissionsHandler);

		var permissions: Array = ["publish_actions", "publish_pages", "manage_pages"];

		FacebookAPI.service.requestPermissions(permissions, false);
	}
}

function requestPermissionsHandler(event: FacebookAPISessionEvent): void {
	trace("requestPermissionsHandler( " + event.type + " ) ");
}


////////////////////////////////////////////////////////
//	SHARE DIALOGS
//	

//LINKS
function shareLinkContent(): void {
	if (FacebookAPI.service.shareDialog.canShow(ShareLinkContentBuilder.TYPE)) {
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_COMPLETED, shareDialogEventHandler);
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_CANCELLED, shareDialogEventHandler);
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_ERROR, shareDialogEventHandler);

		var builder: ShareLinkContentBuilder = new ShareLinkContentBuilder()
		//					.setContentTitle("FacebookAPI ANE")
		//					.setContentDescription("This link was shared using the distriqt FacebookAPI ANE" )
		.setContentUrl("https://airnativeextensions.com/extension/com.distriqt.FacebookAPI");

		var success: Boolean = FacebookAPI.service.shareDialog.show(builder.build());

		trace("shareLinkContent.show() = " + success);
	} else {
		trace("Cannot open share link dialog");
	}
}


[Embed("/assets/promo-main.png")]
var ImagePromo: Class;
var _promoImage: Bitmap = new ImagePromo() as Bitmap;


[Embed("/assets/logo.png")]
var ImageLogo: Class;
var _logo: Bitmap = new ImageLogo() as Bitmap;

[Embed("/assets/facebook.png")]
var Image: Class;
var _image: Bitmap = new Image() as Bitmap;

//PHOTOS
function sharePhotoContent(): void {
	trace("canShow( SharePhotoContentBuilder.TYPE ) = " + FacebookAPI.service.shareDialog.canShow(SharePhotoContentBuilder.TYPE));
	if (FacebookAPI.service.shareDialog.canShow(SharePhotoContentBuilder.TYPE)) {
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_COMPLETED, shareDialogEventHandler);
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_CANCELLED, shareDialogEventHandler);
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_ERROR, shareDialogEventHandler);

		var builder: SharePhotoContentBuilder = new SharePhotoContentBuilder()
			.setShareHashtag("#distriqt")
			.addBitmap(_image.bitmapData);

		var success: Boolean = FacebookAPI.service.shareDialog.show(builder.build());

		trace("sharePhotoContent.show() = " + success);
	} else {
		trace("Cannot open share photo dialog");
	}
}

//VIDEOS
function shareVideoContent(): void {
	if (FacebookAPI.service.shareDialog.canShow(ShareVideoContentBuilder.TYPE)) {
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_COMPLETED, shareDialogEventHandler);
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_CANCELLED, shareDialogEventHandler);
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_ERROR, shareDialogEventHandler);

		var videoFile: File = File.applicationStorageDirectory.resolvePath("assets/video.mp4");


		var builder: ShareVideoContentBuilder = new ShareVideoContentBuilder()
			.setVideoUrl("file://" + videoFile.nativePath);

		var success: Boolean = FacebookAPI.service.shareDialog.show(builder.build());

		trace("shareVideoContent.show() = " + success);
	} else {
		trace("Cannot open share video dialog");
	}
}



function shareOpenGraphContent(): void {
	var object: Object = new ShareOpenGraphObjectBuilder()
		.putString("og:type", "article")
		.putString("og:url", "https://airnativeextensions.com/extension/com.distriqt.FacebookAPI")
		.putString("og:title", "FacebookAPI ANE")
		.putString("og:description", "Social engagement in your AIR application with the Facebook API!")
		.putPhotoUrl("og:image", "https://airnativeextensions.com/images/extensions/icons/ane-facebookapi-icon.png")
		.build();

	var action: Object = new ShareOpenGraphActionBuilder()
		.setActionType("news.publishes")
		.putObject("article", object)
	//					.putPhoto( "image", _promoImage.bitmapData, "", true )
	//					.putPhotoUrl( "image", "https://airnativeextensions.com/images/home/promo-main.png", "", true )
	.build();

	var builder: ShareOpenGraphContentBuilder = new ShareOpenGraphContentBuilder()
		.setPreviewPropertyName("article")
		.setAction(action);



	//				var shareOpenGraphObject:Object = new ShareOpenGraphObjectBuilder()
	//						.putString( "og:type", "books.book" )
	//						.putString( "og:title", "A Game of Thrones" )
	//						.putString( "og:description", "In the frozen wastes to the north of Winterfell, sinister and supernatural forces are mustering." )
	//						.putString( "books:isbn", "0-553-57340-3" )
	////						.putPhoto( "og:image", _image.bitmapData )
	//						.build();
	//
	//				var shareOpenGraphAction:Object = new ShareOpenGraphActionBuilder()
	//						.setActionType( "books.reads" )
	//						.putObject( "book", shareOpenGraphObject )
	//						.putPhoto( "image", _image.bitmapData, "my logo", true )
	//						.build();
	//
	//				var builder:ShareOpenGraphContentBuilder = new ShareOpenGraphContentBuilder()
	//						.setPreviewPropertyName("book")
	//						.setAction( shareOpenGraphAction );



	if (FacebookAPI.service.shareDialog.canShow(ShareOpenGraphContentBuilder.TYPE)) {
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_COMPLETED, shareDialogEventHandler);
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_CANCELLED, shareDialogEventHandler);
		FacebookAPI.service.shareDialog.addEventListener(ShareDialogEvent.DIALOG_ERROR, shareDialogEventHandler);

		var success: Boolean = FacebookAPI.service.shareDialog.show(builder.build());


		trace("shareOpenGraphContent.show() = " + success);
	} else {
		trace("Cannot open share open graph dialog");
	}
}





function shareDialogEventHandler(event: ShareDialogEvent): void {
	FacebookAPI.service.shareDialog.removeEventListener(ShareDialogEvent.DIALOG_COMPLETED, shareDialogEventHandler);
	FacebookAPI.service.shareDialog.removeEventListener(ShareDialogEvent.DIALOG_CANCELLED, shareDialogEventHandler);
	FacebookAPI.service.shareDialog.removeEventListener(ShareDialogEvent.DIALOG_ERROR, shareDialogEventHandler);

	trace(event.type + " :: " + event.errorMessage);
	if (event.postId != null) trace("postId=" + event.postId);
}



//
//	SHARE API
//

function shareAPI(): void {
	var builder: SharePhotoContentBuilder = new SharePhotoContentBuilder()
		.addBitmap(_image.bitmapData);

	FacebookAPI.service.shareAPI.addEventListener(ShareAPIEvent.COMPLETED, shareAPIEventHandler);
	FacebookAPI.service.shareAPI.addEventListener(ShareAPIEvent.CANCELLED, shareAPIEventHandler);
	FacebookAPI.service.shareAPI.addEventListener(ShareAPIEvent.ERROR, shareAPIEventHandler);

	var success: Boolean = FacebookAPI.service.shareAPI.share(builder.build());
}


function shareAPIEventHandler(event: ShareAPIEvent): void {
	FacebookAPI.service.shareAPI.removeEventListener(ShareAPIEvent.COMPLETED, shareAPIEventHandler);
	FacebookAPI.service.shareAPI.removeEventListener(ShareAPIEvent.CANCELLED, shareAPIEventHandler);
	FacebookAPI.service.shareAPI.removeEventListener(ShareAPIEvent.ERROR, shareAPIEventHandler);

	trace(event.type + " :: " + event.errorMessage);
	if (event.postId != null) trace("postId=" + event.postId);
}




////////////////////////////////////////////////////////
//	MESSAGE DIALOGS
//	


function messageLinkContent(): void {
	if (FacebookAPI.service.messageDialog.canShow(ShareLinkContentBuilder.TYPE)) {
		FacebookAPI.service.messageDialog.addEventListener(ShareDialogEvent.DIALOG_COMPLETED, messageDialogEventHandler);
		FacebookAPI.service.messageDialog.addEventListener(ShareDialogEvent.DIALOG_CANCELLED, messageDialogEventHandler);
		FacebookAPI.service.messageDialog.addEventListener(ShareDialogEvent.DIALOG_ERROR, messageDialogEventHandler);

		var builder: ShareLinkContentBuilder = new ShareLinkContentBuilder()
			.setContentTitle("FacebookAPI ANE")
			.setContentDescription("This link was shared using the distriqt FacebookAPI ANE")
			.setContentUrl("https://airnativeextensions.com/extension/com.distriqt.FacebookAPI");

		var success: Boolean = FacebookAPI.service.messageDialog.show(builder.build());

		trace("messageLinkContent.show() = " + success);
	} else {
		trace("Cannot open message link dialog");
	}
}


function messageDialogEventHandler(event: ShareDialogEvent): void {
	FacebookAPI.service.messageDialog.removeEventListener(ShareDialogEvent.DIALOG_COMPLETED, messageDialogEventHandler);
	FacebookAPI.service.messageDialog.removeEventListener(ShareDialogEvent.DIALOG_CANCELLED, messageDialogEventHandler);
	FacebookAPI.service.messageDialog.removeEventListener(ShareDialogEvent.DIALOG_ERROR, messageDialogEventHandler);

	trace(event.type);
	if (event.postId != null) trace("postId=" + event.postId);
}





////////////////////////////////////////////////////////
//	GAME REQUESTS
//	


function gameRequest(): void {
	if (FacebookAPI.service.gameRequest.canShow()) {
		FacebookAPI.service.gameRequest.addEventListener(GameRequestEvent.DIALOG_COMPLETED, gameRequestEventHandler);
		FacebookAPI.service.gameRequest.addEventListener(GameRequestEvent.DIALOG_CANCELLED, gameRequestEventHandler);
		FacebookAPI.service.gameRequest.addEventListener(GameRequestEvent.DIALOG_ERROR, gameRequestEventHandler);

		var builder: GameRequestContentBuilder = new GameRequestContentBuilder()
			.setRecipients([userID])
			.setTitle("Facebook API ANE Game Request")
			.setMessage("Come play this game with me");

		var success: Boolean = FacebookAPI.service.gameRequest.show(builder.build());

		trace("gameRequest.show() = " + success);
	} else {
		trace("Cannot open gameRequest dialog");
	}
}


function gameRequestEventHandler(event: GameRequestEvent): void {
	FacebookAPI.service.appInvite.removeEventListener(GameRequestEvent.DIALOG_COMPLETED, gameRequestEventHandler);
	FacebookAPI.service.appInvite.removeEventListener(GameRequestEvent.DIALOG_CANCELLED, gameRequestEventHandler);
	FacebookAPI.service.appInvite.removeEventListener(GameRequestEvent.DIALOG_ERROR, gameRequestEventHandler);

	trace(event.type);
	switch (event.type) {
		case GameRequestEvent.DIALOG_COMPLETED:
			trace("requestId:  " + event.requestId);
			trace("recipients: " + event.recipients.join(","));
			break;

		case GameRequestEvent.DIALOG_ERROR:
			trace("error: [" + event.errorCode + "]:" + event.errorMessage);
			break;
	}
}







//
//	ACCOUNT KIT
//

function accountKit_setup(): void {
	try {
		FacebookAPI.service.accountKit.addEventListener(AccountKitEvent.SETUP_COMPLETE, accountKit_setupCompleteHandler);

		if (FacebookAPI.service.accountKit.setup(ResponseType.ACCESS_TOKEN)) {
			FacebookAPI.service.accountKit.addEventListener(AccountKitEvent.LOGIN_WITH_AUTHORISATIONCODE, accountKit_loginAuthorisationCodeHandler);
			FacebookAPI.service.accountKit.addEventListener(AccountKitEvent.LOGIN_WITH_ACCESSTOKEN, accountKit_loginAccessHandler);
			FacebookAPI.service.accountKit.addEventListener(AccountKitEvent.CANCELLED, accountKit_cancelledHandler);
			FacebookAPI.service.accountKit.addEventListener(AccountKitEvent.ERROR, accountKit_errorHandler);

			FacebookAPI.service.accountKit.addEventListener(AccountKitEvent.ACCOUNTINFO, accountKit_accountInfoHandler);
			FacebookAPI.service.accountKit.addEventListener(AccountKitEvent.ACCOUNTINFO_ERROR, accountKit_errorHandler);
		}
	} catch (e: Error) {}
}

function accountKit_setupCompleteHandler(event: AccountKitEvent): void {
	trace(event.type);
}

function accountKit_loginWithPhone(): void {
	if (FacebookAPI.service.accountKit.isSupported) {
		FacebookAPI.service.accountKit.loginWithPhone(); // "+61", "0400000000" );
	}
}

function accountKit_loginWithEmail(): void {
	if (FacebookAPI.service.accountKit.isSupported) {
		FacebookAPI.service.accountKit.loginWithEmail();
	}
}

function accountKit_logout(): void {
	if (FacebookAPI.service.accountKit.isSupported) {
		FacebookAPI.service.accountKit.logout();
	}
}

function accountKit_getAccountInfo(): void {
	if (FacebookAPI.service.accountKit.isSupported) {
		FacebookAPI.service.accountKit.getAccountInfo();
	}
}





function accountKit_loginAuthorisationCodeHandler(event: AccountKitEvent): void {
	trace(event.type + "::" + event.authorisationCode);
}

function accountKit_loginAccessHandler(event: AccountKitEvent): void {
	trace(event.type + "::" + event.accessToken.tokenString);
}

function accountKit_cancelledHandler(event: AccountKitEvent): void {
	trace(event.type);
}

function accountKit_errorHandler(event: AccountKitEvent): void {
	trace(event.type + "::[" + event.errorCode + "] " + event.errorMessage);
}

function accountKit_accountInfoHandler(event: AccountKitEvent): void {
	trace(event.type + "::" + event.account.toString());
}




////////////////////////////////////////////////////////
//	APP EVENTS
//

function appEvents_setUserDetails(): void {
	if (FacebookAPI.service.appEvents.isSupported) {
		FacebookAPI.service.appEvents.setUserID("user1234");
		FacebookAPI.service.appEvents.setUserProperties({
			test_prop: "test_value"
		});
	}
}

function appEvents_logEvent(): void {
	if (FacebookAPI.service.appEvents.isSupported) {
		var event: FacebookAppEvent = new FacebookAppEvent(AppEventsConstants.EVENT_NAME_ADDED_TO_CART);
		event.valueToSum = 54.23;

		event.setParameter(AppEventsConstants.EVENT_PARAM_CURRENCY, "USD");
		event.setParameter(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, "product");
		event.setParameter(AppEventsConstants.EVENT_PARAM_CONTENT_ID, "HDFU-8452");

		FacebookAPI.service.appEvents.logEvent(event);
	}
}


function appEvents_logPurchase(): void {
	if (FacebookAPI.service.appEvents.isSupported) {
		var event: FacebookAppPurchaseEvent = new FacebookAppPurchaseEvent(
			Math.floor(Math.random() * 1000) / 100,
			"AUD"
		);

		FacebookAPI.service.appEvents.logPurchase(event);
	}
}


function appEvents_logCustomEvent(): void {
	if (FacebookAPI.service.appEvents.isSupported) {
		var event: FacebookAppEvent = new FacebookAppEvent("a_custom_event_name");

		FacebookAPI.service.appEvents.logEvent(event);
	}
}





////////////////////////////////////////////////////////
//	GRAPH API
//

function request_completeHandler(event: GraphAPIRequestEvent): void {
	trace(event.type + "::" + JSON.stringify(event.data));

	event.currentTarget.removeEventListener(GraphAPIRequestEvent.COMPLETE, request_completeHandler);
	event.currentTarget.removeEventListener(GraphAPIRequestEvent.ERROR, request_errorHandler);
}

function request_errorHandler(event: GraphAPIRequestEvent): void {
	trace(event.type + "::[" + event.errorCode + "]" + event.errorMessage);

	event.currentTarget.removeEventListener(GraphAPIRequestEvent.COMPLETE, request_completeHandler);
	event.currentTarget.removeEventListener(GraphAPIRequestEvent.ERROR, request_errorHandler);
}



function graph_getCurrentUserInfo(): void {
	trace("GraphAPI: getCurrentUserInfo");
	if (FacebookAPI.service.graphAPI.isSupported) {
		var request: GraphAPIRequest = new GraphAPIRequestBuilder()
			.setPath("/me")
			.addField("email")
			.addField("name")
			.build();

		request.addEventListener(GraphAPIRequestEvent.COMPLETE, request_completeHandler);
		request.addEventListener(GraphAPIRequestEvent.ERROR, request_errorHandler);

		FacebookAPI.service.graphAPI.makeRequest(request);
	}
}


function graph_getCurrentPermissions(): void {
	trace("GraphAPI: getCurrentPermissions");
	if (FacebookAPI.service.graphAPI.isSupported) {
		var request: GraphAPIRequest = GraphAPIRequestBuilder.getCurrentPermissionsRequest();

		request.addEventListener(GraphAPIRequestEvent.COMPLETE, request_completeHandler);
		request.addEventListener(GraphAPIRequestEvent.ERROR, request_errorHandler);

		FacebookAPI.service.graphAPI.makeRequest(request);
	}
}


function graph_postLink(): void {
	trace("GraphAPI: postLink");
	if (FacebookAPI.service.graphAPI.isSupported) {
		var request: GraphAPIRequest = new GraphAPIRequestBuilder()
			.setPath("/me/feed")
			.setMethod(GraphAPIRequestBuilder.METHOD_POST)
			.addParameter("link", "https://airnativeextensions.com")
			.addParameter("caption", "Posted through the Graph API from the Facebook API ANE")
			.build();

		request.addEventListener(GraphAPIRequestEvent.COMPLETE, request_completeHandler);
		request.addEventListener(GraphAPIRequestEvent.ERROR, request_errorHandler);

		FacebookAPI.service.graphAPI.makeRequest(request);
	}
}


function graph_postImage(): void {
	trace("GraphAPI: postImage");
	if (FacebookAPI.service.graphAPI.isSupported) {
		var request: GraphAPIRequest = new GraphAPIRequestBuilder()
			.setPath("/me/photos")
			.setMethod(GraphAPIRequestBuilder.METHOD_POST)
			.setImage(_image.bitmapData)
			.addParameter("message", "Image posted through the Graph API from the Facebook API ANE")
			.build();

		request.addEventListener(GraphAPIRequestEvent.COMPLETE, request_completeHandler);
		request.addEventListener(GraphAPIRequestEvent.ERROR, request_errorHandler);

		FacebookAPI.service.graphAPI.makeRequest(request);
	}
}


function graph_getFriends(): void {
	trace("GraphAPI: getFriends");
	if (FacebookAPI.service.graphAPI.isSupported) {
		var request: GraphAPIRequest = new GraphAPIRequestBuilder()
			.setPath("/me/friends")
			.addField("name")
			.build();

		request.addEventListener(GraphAPIRequestEvent.COMPLETE, request_completeHandler);
		request.addEventListener(GraphAPIRequestEvent.ERROR, request_errorHandler);

		FacebookAPI.service.graphAPI.makeRequest(request);
	}
}



//
//	PAGE TESTS
//

function postToPage(): void {
	trace("GraphAPI: getFriends");
	if (FacebookAPI.service.graphAPI.isSupported) {
		var request: GraphAPIRequest = new GraphAPIRequestBuilder()
			.setPath("/me/accounts")
			.build();

		request.addEventListener(GraphAPIRequestEvent.COMPLETE, postToPage_getAccounts_completeHandler);
		request.addEventListener(GraphAPIRequestEvent.ERROR, request_errorHandler);

		FacebookAPI.service.graphAPI.makeRequest(request);
	}
}

var pageAccountInfo: Object;

function postToPage_getAccounts_completeHandler(event: GraphAPIRequestEvent): void {
	try {
		pageAccountInfo = event.data.data[0];
		trace("PAGE: " + JSON.stringify(pageAccountInfo));

		var request: GraphAPIRequest = new GraphAPIRequestBuilder()
			.setPath("/" + pageAccountInfo.id + "/feed")
			.setMethod(GraphAPIRequestBuilder.METHOD_POST)
			.addParameter("access_token", pageAccountInfo.access_token)
			.addParameter("message", "Page Post from the Facebook API ANE")
			.addParameter("link", "https://airnativeextensions.com/extension/com.distriqt.FacebookAPI")
			.build();

		request.addEventListener(GraphAPIRequestEvent.COMPLETE, postToPage_post_completeHandler);
		request.addEventListener(GraphAPIRequestEvent.ERROR, request_errorHandler);

		FacebookAPI.service.graphAPI.makeRequest(request);
	} catch (e: Error) {
		trace("ERROR: " + e.message);
	}
}


function postToPage_post_completeHandler(event: GraphAPIRequestEvent): void {
	trace("postToPage: COMPLETE");
}





//
//	APP LINKS
//

var _appLink: AppLink;


function appLinks_openReferer(): void {
	trace("openReferer");
	if (FacebookAPI.isSupported) {
		FacebookAPI.service.appLinks.openReferer(_appLink);
	}
}


function appLinks_fetchDeferredAppLink(): void {
	trace("fetchDeferredAppLink");
	if (FacebookAPI.isSupported) {
		FacebookAPI.service.appLinks.addEventListener(AppLinkEvent.FETCH_COMPLETE, appLinkHandler);
		FacebookAPI.service.appLinks.fetchDeferredAppLink();
	}
}



function appLinkHandler(event: AppLinkEvent): void {
	trace(event.type);
	if (event.appLink != null)
		trace(event.appLink.dataJSON);
	_appLink = event.appLink;
}