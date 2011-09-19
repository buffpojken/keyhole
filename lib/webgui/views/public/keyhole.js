if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}

keyhole = {
	init: function(map_id){
		this.map 				= new google.maps.Map(document.getElementById(map_id), this._map_options);
		this.devices	 	= this._map_devices();
		setup_web_socket();
		return this;
	},		
	handle: function(payload){
		if(this[payload.event] != undefined){
			this[payload.event](payload)
		}else{
			alert("Unknown event received from server");
		}
	},
	location: function(payload){
		console.log("Location");
	},
	status: function(){
		console.log("Status change");
	},
	_map_options: {
		zoom:18, 
		center: new google.maps.LatLng(59.336013, 18.081222), 
		mapTypeId: google.maps.MapTypeId.SATELLITE, 
		mapTypeControlOptions: {
			style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR, 
			position: google.maps.ControlPosition.BOTTOM_RIGHT
		}, 
	 	navigationControlOptions: {
	     	style: google.maps.NavigationControlStyle.SMALL, 
				position: google.maps.ControlPosition.BOTTOM_RIGHT
	   }, 
		streetViewControl:false
	}, 
	_map_devices: function(){
		var _d = {};
		$("#device-list li").each(function(i, el){
			_d[el.getAttribute('data-device-id')] = {
				id: el.getAttribute('data-device-id'), 
				name: el.getAttribute('data-device-name')
			}
		});
		return _d;
	}
}

$(function(){
	window.keyhole = Object.create(keyhole).init('map_canvas');
	$("#expand-top-bar").click(function(){
		$("#entities").toggleClass("device-expanded");
	});
});

// Rewrite for better structure .daniel
function setup_web_socket(){
	window.ws = new WebSocket("ws://"+window.keyhole_data.host+":8080/"+window.keyhole_data.session_key);
	window.ws.onmessage = function(evt){
		try{
			payload = JSON.parse(evt.data);		
		}catch(err){
			console.log("error");
			console.log(evt.data);
		}		
		if(payload){
			keyhole.handle(payload);
			// if(payload.event == 'location'){
			// 	keyhole.mark(payload.location.latitude, payload.location.longitude);				
			// }else if(payload.event == 'status-change'){
			// 	update_status(payload)
			// }						
		}
	}
	window.ws.onclose = function(){
		alert("ws closed...");
	}
	window.ws.onopen = function(){
		console.log("socket opened...");
	}
}