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
		this._setup_controls();
		this._setup_layers();
		setup_web_socket();
		return this;
	},		
	handle: function(payload){
		if(this[payload.event] != undefined){
			var device = this.devices[payload.id];
			if(!device){
				toast("Unknown device with id: "+payload.id+" - contact admin!");
				return;
			}else{				
				this[payload.event](device, payload)
			}
		}else{
			console.log("Received unknown:");
			console.log(payload);
		}
	},
	location: function(device, payload){
		console.log(device);
		if(!device.marker){
			device.marker = this._build_marker(device);
		}
		var _ll = new google.maps.LatLng(payload.location.latitude, payload.location.longitude);
		device.marker.setPosition(_ll);
		device.path.push(_ll);
		device.polyline.setPath(device.path);
		this.set(device, 'track-length', Number(google.maps.geometry.spherical.computeLength(device.path)).toFixed(2));
		if(this.options.track){
			this.map.panTo(_ll);
		}
		// Override point for drawing and updating polyline!
		this.set(device, 'updated-at', payload.timestamp);
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
	set: function(device, key, value){
		$("#"+device.id + " ."+key).html(value);
	},
	error: function(device, payload){
		toast(payload.message);
	},
	tracking: function(){
		var _btn = $("#toggle-follow");
		console.log(arguments.length);
		if(arguments.length > 0){
			var toggle = arguments[0];
		}else{
			var toggle = _btn.hasClass('inactive');
		}
		if(toggle){
			this.options.track = true; 
			_btn.removeClass('inactive');
			toast('Tracking is: ON');
		}else{
			this.options.track = false; 
			_btn.addClass('inactive');				
			toast('Tracking is: OFF');
		}			
	},
	_map_options: {
		zoom:18, 
		center: new google.maps.LatLng(59.336013, 18.081222), 
		mapTypeId: google.maps.MapTypeId.SATELLITE,
		zoomControl:false,
		mapTypeControlOptions: {
			style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR, 
			position: google.maps.ControlPosition.BOTTOM_LEFT
		}, 
	 	navigationControlOptions: {
	     	style: google.maps.NavigationControlStyle.SMALL, 
				position: google.maps.ControlPosition.RIGHT_CENTER
	   }, 
		streetViewControl:false
	}, 
	_map_devices: function(){
		var _d = {};
		var _t = this;
		$("#device-list li").each(function(i, el){
		 var device = {
				id: el.getAttribute('data-device-id'), 
				name: el.getAttribute('data-device-name'), 
				el: $(el), 
				color: el.getAttribute('data-device-color')
			}
			
			// This is sloppy, but will work for now! .daniel
			device.polyline = _t._build_polyline(device)
			_d[el.getAttribute('data-device-id')] = device;
			_t._draw_history(device);
		});
		return _d;
	}, 
	_build_marker: function(device){
		return new google.maps.Marker({
			map: this.map, 
			title: device.name,
			optimized: false
		});
	}, 
	_build_polyline: function(device){
		device.path = new google.maps.MVCArray;
		return new google.maps.Polyline({
			strokeColor: device.color, 
			clickable: false, 
			path: device.path, 
			map: this.map
		});
	},
	_draw_history: function(device){
		$.each(window.keyhole_history[device.id], function(i, el){
			device.path.push(new google.maps.LatLng(el.location.latitude, el.location.longitude))
		});
		device.polyline.setPath(device.path);
		this.set(device, 'track-length', Number(google.maps.geometry.spherical.computeLength(device.path)).toFixed(2));
	},
	_setup_controls: function(){
		var _t = this;
		$("#zoom-in").bind('click', function(){
			_t.map.setZoom(_t.map.getZoom()+1);
		});
		$("#zoom-out").bind('click', function(){
			_t.map.setZoom(_t.map.getZoom()-1);
		});
		$("#toggle-follow").bind('click', function(){
			_t.tracking();
		});
		$(".device-name").bind('click', function(){
			var _l = $(this).parents('li');
			var device = _t.devices[_l.attr('data-device-id')];
			_t.tracking(false);
			_t.map.panTo(device.marker.getPosition());
		});
		$("#expand-top-bar").click(function(){
			$("#entities").toggleClass("device-expanded");
		});
		$("#clear-session").click(function(){
			if(confirm("Are you sure - this can not be undone!")){
				$.ajax({
					url:'/map/'+window.keyhole_data.session_key+"/clear", 
					type: 'post', 
					dataType: 'json', 
					success: function(p){
						if(!p.error){
							window.location.reload();
						}
					}, 
					error: function(){
						toast("The session could not be reset - try again!");
					}
				});
			}
		});
	}, 
	_setup_layers: function(){
		var _t = this;
		$.each(window.keyhole_layers, function(i, el){
			el.layer.kml_layer = new google.maps.KmlLayer(el.layer.url);
			el.layer.kml_layer.setMap(_t.map);
		});
	}
}

$(function(){
	window.keyhole = Object.create(keyhole).init('map_canvas');
});

// Rewrite for better structure .daniel
function setup_web_socket(){
	clearInterval(window.keyhole.reconnect);
	window.ws = new WebSocket("ws://"+window.keyhole_data.host+":8080/"+window.keyhole_data.session_key);
	window.ws.onmessage = function(evt){
		try{
			payload = JSON.parse(evt.data);		
		}catch(err){
			console.log("error");
			console.log(evt.data);
		}		
		if(payload){
			console.log(payload);
			keyhole.handle(payload);
		}
	}
	window.ws.onclose = function(){
		toast("Connection with Keyhole has been lost");
		document.title = "[keyhole] - offline";
		window.keyhole.reconnect = setInterval(function(){
			toast('Trying to reconnect...');
			setTimeout(function(){
				setup_web_socket();				
			}, 2000);
		}, 6000);
	}
	window.ws.onopen = function(){
		toast("Connection with Keyhole established");
		document.title = "[keyhole] - online";
	}
}

function toast(sMessage){
	var container = $(document.createElement("div"));
	container.addClass("toast");
	var message = $(document.createElement("div"));
	message.addClass("message");
	message.text(sMessage);
	message.appendTo(container);
	container.appendTo(document.body);
	container.delay(100).fadeIn("slow", function(){
		$(this).delay(2000).fadeOut("slow", function(){				
			$(this).remove();
		});
	});
}

