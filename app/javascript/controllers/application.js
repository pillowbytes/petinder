import { Application } from "@hotwired/stimulus"
import "@hotwired/stimulus-loading"
import { Dropdown } from "bootstrap"


const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

document.addEventListener("turbo:load", () => {
  document.querySelectorAll(".dropdown-toggle").forEach((dropdown) => {
    new Dropdown(dropdown);
  });
});

export { application }
