/**
 * 
 */

var AirBridge = (function() {
	var instance;
	function createInstance() {
		var object = new Object();
		object.useWindowLocation = true;
		
		object.isWKWebView = false;
		if (navigator.platform.substr(0,2) === 'iP'){
  			if (window.indexedDB) {	  
				object.isWKWebView = (window.webkit && window.webkit.messageHandlers);
			}
		}
			
		return object;
	}
	
	return {
		setUseWindowLocation: function( $shouldUseWindowLocation ) {
			if (!instance) {
				instance = createInstance();
			}
			instance.useWindowLocation = $shouldUseWindowLocation;	
		},
		
		message: function( $message ) {
			if (!instance) {
				instance = createInstance();
			}
			try {
				if (instance.isWKWebView) {
					window.webkit.messageHandlers.airbridge.postMessage( $message );
				}
				else if (!instance.useWindowLocation) {
					NativeWebView.airBridge( $message );
				}
				else {
					window.location = "airBridge:" + $message;
				}
			}
			catch (err) {
				window.location = "airBridge:" + $message;
			}
		}
	};
})();