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

      // 🔥 Warm-up reverse geocoding to avoid delay on first click
      fetch(`https://api.mapbox.com/geocoding/v5/mapbox.places/0,0.json?access_token=${this.apiKeyValue}`, {
        method: "GET",
        keepalive: true,
        cache: "no-cache"
      }).then(() => console.log("Mapbox geocoding warmed up"))
        .catch(() => console.warn("Geocoding warm-up failed"))
    })

    // 👇 Handle map clicks to show rich address info
    this.map.on("click", async (e) => {
      performance.mark("click-start")
      console.log("📍 User clicked on map")

      const lng = e.lngLat.lng
      const lat = e.lngLat.lat

      const popup = new mapboxgl.Popup().setLngLat([lng, lat]).setHTML("Carregando...").addTo(this.map)

      performance.mark("fetch-start")
      const response = await fetch(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${lng},${lat}.json?access_token=${this.apiKeyValue}`
      )
      performance.mark("fetch-end")
      const data = await response.json()
      performance.mark("json-parsed")

      // Simulate location logic
      navigator.geolocation.getCurrentPosition((position) => {
        performance.mark("geo-done")

        const html = `<div>Endereço carregado</div>`
        popup.setHTML(html)

        performance.mark("popup-set")
        performance.measure("1. Fetch duration", "fetch-start", "fetch-end")
        performance.measure("2. JSON parse duration", "fetch-end", "json-parsed")
        performance.measure("3. Geolocation delay", "json-parsed", "geo-done")
        performance.measure("4. Popup render delay", "geo-done", "popup-set")

        console.table(performance.getEntriesByType("measure"))
      })
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
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 2000 })
  }
}
