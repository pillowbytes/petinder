import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form"]

  connect() {
    // Enter key submits the form (without Shift)
    this.inputTarget.addEventListener("keydown", (event) => {
      if (event.key === "Enter" && !event.shiftKey) {
        event.preventDefault()
        this.formTarget.requestSubmit()
      }
    })

    // Scroll to bottom on connect (initial load)
    this.scrollToBottom()
  }

  // Clear input after message sent
  clearInput() {
    // console.log("Triggered clear input")
    this.inputTarget.value = ""
    this.scrollToBottom()
  }

  // Scroll messages container to bottom
  scrollToBottom() {
    // console.log("Triggered Scroll")
    const messagesContainer = document.querySelector(".turbo-messages")
    if (messagesContainer) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight
    }
  }


}
