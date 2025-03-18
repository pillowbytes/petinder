import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { userId: Number }

  // Connects to data-controller="message"
  connect() {
    console.log("Stimulus connected");

    const currentUserId = parseInt(document.body.dataset.currentUserId, 10);

    // Ensure the class reflects who sent the message
    if (this.userIdValue === currentUserId) {
      console.log("First if");

      this.element.classList.add('pet-message-sent');
      console.log(this.element.classList);

      this.element.classList.remove('pet-message-received');
      console.log(this.element.classList);
    } else {
      console.log("Second if");
      this.element.classList.add('pet-message-received');
      console.log(this.element.classList);
      this.element.classList.remove('pet-message-sent');
      console.log(this.element.classList);
    }
    console.log("After if");
    // Auto-scroll to new messages
    this.element.scrollIntoView({ behavior: 'smooth' });
    console.log("end call");
  }
}
