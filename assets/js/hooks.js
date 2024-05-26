let Hooks = {}

Hooks.ScrollToBottom = {
  mounted() {
    this.scrollToBottom()
  },
  updated() {
    this.scrollToBottom()
  },
  scrollToBottom() {
    const messagesContainer = this.el
    messagesContainer.scrollTop = messagesContainer.scrollHeight
  }
}

export default Hooks