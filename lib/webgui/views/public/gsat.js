var keyhole = {
	init: function(map_id){
		this.map = new google.maps.Map(document.getElementById(map_id), this._map_options);
		setup_web_socket();
	},		
	mark: function(lat, lng){
		var ll 	= new google.maps.LatLng(lat, lng);
		if(!this.marker){
			this.marker 	= new google.maps.Marker({
				position: ll, 
				map: this.map, 
				title: 'Negerkungen dansar...'
			})			
		}else{
			this.marker.setPosition(ll);
		}
		keyhole.map.panTo(ll);		
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
	}
}


$(document).ready(function(e){
	
	keyhole.init("map_canvas");
	
	$("#expand-top-bar").click(function(){
		$("#entities").toggleClass("device-expanded");
	});
	
	$(window).bind('keyup', function(e){
		if(e.which == 27){
			$("#entities").removeClass("device-expanded").removeClass("group-expanded");
		}
	});

});

function update_status(p){
	el = $("#"+p.tracker);
	if(p.status == 'no-fix'){
		el.addClass('no-fix');
		el.removeClass('offline')
	}else if(p.status == 'disconnect'){
		el.addClass('offline');
		el.removeClass('no-fix');
	}else{
		el.removeClass('no-fix');
		el.removeClass('offline');
	}
}

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
			if(payload.event == 'location'){
				keyhole.mark(payload.location.latitude, payload.location.longitude);				
			}else if(payload.event == 'status-change'){
				update_status(payload)
			}						
		}
	}
	window.ws.onclose = function(){
		alert("ws closed...");
	}
	window.ws.onopen = function(){
		console.log("socket opened...");
	}
}


