// import { Controller } from "@hotwired/stimulus"
// import mapboxgl from 'mapbox-gl' // Don't forget this!

// // Connects to data-controller="map"
// export default class extends Controller {
//   static values = {
//     apiKey: String,
//     markers: Array,
//     userMarker: Object
//   }

//   connect() {
//     mapboxgl.accessToken = this.apiKeyValue

//     this.map = new mapboxgl.Map({
//       container: this.element,
//       style: "mapbox://styles/mapbox/streets-v10"
//     })

//     this.#addMarkersToMap()
//     this.#fitMapToMarkers()
//     this.#getUserLocation()
//   }

//   #getUserLocation() {
//     navigator.geolocation.getCurrentPosition((position) => {
//       const customMarker = document.createElement("div")
//       customMarker.innerHTML = this.userMarkerValue.marker_html
//       const { latitude, longitude } = position.coords
//       this.map.setCenter([longitude, latitude])
//       new mapboxgl.Marker(customMarker)
//       .setLngLat([ longitude, latitude ])
//       .addTo(this.map)
//     })
//   }

//   #addMarkersToMap() {
//     this.markersValue.forEach((marker) => {
//       const customMarker = document.createElement("div")
//       customMarker.innerHTML = marker.marker_html
//       new mapboxgl.Marker(customMarker)
//         .setLngLat([ marker.lng, marker.lat ])
//         .addTo(this.map)
//     })
//   }

//   #fitMapToMarkers() {
//     const bounds = new mapboxgl.LngLatBounds()
//     this.markersValue.forEach(marker => bounds.extend([ marker.lng, marker.lat ]))
//     this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
//   }
// }

import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array,
    userMarker: Object
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/pillowbytes/cm8kcktg500o801pabjxk6vzv"
    })

    this.map.on("load", () => {
      this.#addUserLocation()
      this.#addMarkersToMap()
      this.#fitMapToMarkers()
    })
  }

  #addUserLocation() {
    navigator.geolocation.getCurrentPosition((position) => {
      const customMarker = document.createElement("div")
      customMarker.innerHTML = this.userMarkerValue.marker_html
      const { latitude, longitude } = position.coords
      this.map.setCenter([longitude, latitude])
      new mapboxgl.Marker(customMarker)
        .setLngLat([longitude, latitude])
        .addTo(this.map)
    })
  }

  #addMarkersToMap() {
    const features = this.markersValue.map((marker) => {
      return {
        type: "Feature",
        geometry: {
          type: "Point",
          coordinates: [marker.lng, marker.lat]
        },
        properties: {
          marker_html: marker.marker_html,
          name: marker.name,
          last_seen: marker.last_seen,
          user_count: marker.user_count
        }
      }
    })

    const geojson = {
      type: "FeatureCollection",
      features: features
    }

    this.map.addSource("pets", {
      type: "geojson",
      data: geojson,
      cluster: true,
      clusterMaxZoom: 14,
      clusterRadius: 50
    })

    // Cluster circles
    this.map.addLayer({
      id: "clusters",
      type: "circle",
      source: "pets",
      filter: ["has", "point_count"],
      paint: {
        "circle-color": "#FF6B81",
        "circle-radius": ["step", ["get", "point_count"], 20, 10, 30, 50, 40],
        "circle-opacity": 0.75
      }
    })

    // Cluster count label
    this.map.addLayer({
      id: "cluster-count",
      type: "symbol",
      source: "pets",
      filter: ["has", "point_count"],
      layout: {
        "text-field": "{point_count_abbreviated}",
        "text-size": 14
      }
    })

    // Custom unclustered pins with improved popups
    features.forEach((feature) => {
      const { coordinates } = feature.geometry
      const { marker_html, name, last_seen, user_count } = feature.properties

      const markerElement = document.createElement("div")
      markerElement.innerHTML = marker_html

      const imageSrc = markerElement.querySelector('img')?.src

      const popupContent = `
        <div style="text-align: center;">
          <img src="${imageSrc}" class="rounded-full" width="80" height="80" />
          <div><strong>${name}</strong></div>
          <small>${last_seen}</small>
          ${user_count > 1 ? `<div>${user_count} pets nearby!</div>` : ""}
        </div>`

      new mapboxgl.Marker(markerElement)
        .setLngLat(coordinates)
        .setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(popupContent))
        .addTo(this.map)
    })

    // Zoom into cluster when clicked
    this.map.on("click", "clusters", (e) => {
      const features = this.map.queryRenderedFeatures(e.point, {
        layers: ["clusters"]
      })
      const clusterId = features[0].properties.cluster_id
      this.map.getSource("pets").getClusterExpansionZoom(clusterId, (err, zoom) => {
        if (err) return

        const numPets = features[0].properties.point_count

        new mapboxgl.Popup()
          .setLngLat(e.lngLat)
          .setHTML(`<div style="text-align: center;"><strong>${numPets} pets nearby!</strong></div>`)
          .addTo(this.map)

        this.map.easeTo({
          center: features[0].geometry.coordinates,
          zoom: zoom
        })
      })
    })

    // Change cursor on cluster hover
    this.map.on("mouseenter", "clusters", () => {
      this.map.getCanvas().style.cursor = "pointer"
    })
    this.map.on("mouseleave", "clusters", () => {
      this.map.getCanvas().style.cursor = ""
    })

    // Accessibility fix for Mapbox popup close button
    setTimeout(() => {
      document.querySelectorAll(".mapboxgl-popup-close-button").forEach((btn) => {
        btn.removeAttribute("aria-hidden")
      })
    }, 500)
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([marker.lng, marker.lat]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
  }
}
