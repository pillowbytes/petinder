import { Application } from "@hotwired/stimulus"
import "mapbox-gl/dist/mapbox-gl.css"
import "@hotwired/stimulus-loading"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
