import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["app", "blocker"]

  connect() {
    this.checkViewport()
    window.addEventListener("resize", this.checkViewport.bind(this))
  }

  disconnect() {
    window.removeEventListener("resize", this.checkViewport.bind(this))
  }

  checkViewport() {
    const isMobile = window.innerWidth < 768
    this.appTarget.style.display = isMobile ? "block" : "none"
    this.blockerTarget.style.display = isMobile ? "none" : "flex"
  }
}
