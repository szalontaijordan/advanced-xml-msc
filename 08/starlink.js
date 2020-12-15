(function(container) {
    const map = L.map(container).setView([40, 0], 4);
    const params = {
        noWrap: true,
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    };
    const icon = L.icon({
        iconUrl: 'satellite.png',
        iconSize: [32, 32]
    });

    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', params).addTo(map);

    points.forEach((pointset, index) => {
        pointset.forEach(point => {
            L.marker(point, {
                icon: L.icon({
                      iconUrl: 'satellite.png',
                      iconSize: [(index * 8) + 16, (index * 8) + 16]
                  })
            }).addTo(map)
        })
    });
})('map')
