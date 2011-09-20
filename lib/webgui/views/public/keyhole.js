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
		this.options		= {track: true};
		setup_web_socket();
		return this;
	},		
	handle: function(payload){
		if(this[payload.event] != undefined){
			var device = this.devices[payload.id];
			this[payload.event](device, payload)
		}else{
			alert("Unknown event received from server");
		}
	},
	location: function(device, payload){
		if(!device.marker){
			device.marker = this._build_marker(device);
		}
		var _ll = new google.maps.LatLng(payload.location.latitude, payload.location.longitude);
		device.marker.setPosition(_ll);
		if(this.options.track){
			this.map.panTo(_ll);
		}
	},
	status: function(device, payload){
		if(payload.status == 'no-fix'){
			device.el.addClass('no-fix');
			device.el.removeClass('offline')
		}else if(payload.status == 'disconnect'){
			device.el.addClass('offline');
			device.el.removeClass('no-fix');
		}else{
			device.el.removeClass('no-fix');
			device.el.removeClass('offline');
		}
	},
	connect: function(device, payload){
		// Show good-looking notification here .daniel
		toast(device.name + " has connected to the server");
	},
	_map_options: {
		zoom:18, 
		center: new google.maps.LatLng(59.336013, 18.081222), 
		mapTypeId: google.maps.MapTypeId.SATELLITE, 
		mapTypeControlOptions: {
			style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR, 
			position: google.maps.ControlPosition.RIGHT
		}, 
	 	navigationControlOptions: {
	     	style: google.maps.NavigationControlStyle.SMALL, 
				position: google.maps.ControlPosition.RIGHT
	   }, 
		streetViewControl:false
	}, 
	_map_devices: function(){
		var _d = {};
		$("#device-list li").each(function(i, el){
			_d[el.getAttribute('data-device-id')] = {
				id: el.getAttribute('data-device-id'), 
				name: el.getAttribute('data-device-name'), 
				el: $(el)
			}
		});
		return _d;
	}, 
	_build_marker: function(device){
		return new google.maps.Marker({
			map: this.map, 
			title: device.name,
			optimized: false,
			icon: '/images/blue_dot_circle.png'
		});
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
		}
	}
	window.ws.onclose = function(){
		toast("Socket connection with Keyhole has been lost");
	}
	window.ws.onopen = function(){
		toast("Connection with Keyhole established");
	}
}

function toast(sMessage)
	{
		var container = $(document.createElement("div"));
		container.addClass("toast");
		var message = $(document.createElement("div"));
		message.addClass("message");
		message.text(sMessage);
		message.appendTo(container);
		container.appendTo(document.body);
		container.delay(100).fadeIn("slow", function()
		{
			$(this).delay(2000).fadeOut("slow", function()
			{
				$(this).remove();
			});
		});
	}