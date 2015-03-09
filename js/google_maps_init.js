var map;
function initialize() {
    var myLatLng = new google.maps.LatLng(39.9520494, -75.1894637);
    var map_canvas = document.getElementById('drl-map');
    var map_options = {
        center: myLatLng,
        zoom: 16,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var white = '#FFFFFF';
    var orange_light = '#E67E22';
    var purple_dark = '#8E44AD';
    var purple_light = '#9B59B6';
    var blue_light = '#1ABC9C';
    map = new google.maps.Map(map_canvas, map_options);
    map.set('styles', [
        {
            featureType: 'road',
            elementType: 'geometry',
            stylers: [
                { color: orange_light },
                { weight: 3 },
                {lightness: 20},
                {visibility: 'simplified'}
            ]
        },
        {
            featureType: 'road',
            elementType: 'labels',
            stylers: [
                {hue: purple_dark}
            ]
        },
        {
            featureType: 'landscape',
            elementType: 'geometry',
            stylers: [

                { color: white },
            ]
        },
        {
            featureType: 'landscape.man_made',
            elementType: 'geometry',
            stylers: [

                { color: white },
            ]
        },
        {
            featureType: 'poi',
            elementType: 'geometry',
            stylers: [
                { color: white },
            ]
        },
        {
            featureType: 'poi.school',
            elementType: 'geometry',
            stylers: [
                { color: white },
            ]
        }
    ]);
    var marker = new google.maps.Marker({
        position: myLatLng,
        map: map,
        title: 'Hello World!'
    });
    // Define the LatLng coordinates for the polygon's path.
    var drlCoords = [
        new google.maps.LatLng(39.952418, -75.189885),
        new google.maps.LatLng(39.952241, -75.188442),
        new google.maps.LatLng(39.952097, -75.188485),
        new google.maps.LatLng(39.952163, -75.189107),
        new google.maps.LatLng(39.952035, -75.189134),
        new google.maps.LatLng(39.951842, -75.18804),
        new google.maps.LatLng(39.951657, -75.188115),
        new google.maps.LatLng(39.951862, -75.189987)
    ];

    // Construct the polygon.
    var drlTriangle = new google.maps.Polygon({
        paths: drlCoords,
        strokeColor: purple_light,
        strokeOpacity: 0.8,
        strokeWeight: 2,
        fillColor: purple_dark,
        fillOpacity: 0.5
    });

    drlTriangle.setMap(map);

    // info window stuff
    var contentString = '<div id="content">' +
        '<a href="http://www.physics.upenn.edu/" target="_blank">David Rittenhouse Laboratory</a></div>';

    var infowindow = new google.maps.InfoWindow({
        content: contentString
    });
    google.maps.event.addListener(marker, 'click', function () {
        infowindow.open(map, marker);
    });
}
google.maps.event.addDomListener(window, 'load', initialize);
google.maps.event.addDomListener(window, "resize", function () {
    var center = map.getCenter();
    google.maps.event.trigger(map, "resize");
    map.setCenter(center);
});
