// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

function renewTextAlignment(el) {
  const bbox = el.getBBox()

  if(el.previousElementSibling.hasAttribute("data-background-box")) {
     const sibling = el.previousElementSibling.firstElementChild
    sibling.setAttribute('x', bbox.x)
    sibling.setAttribute('y', bbox.y)
    sibling.setAttribute('width', bbox.width)
    sibling.setAttribute('height', bbox.height)
  }

  const origX = parseFloat(el.getAttribute("x"))
  const align = el.getAttribute("data-text-anchor")
  const weight = {
    'start': 0,
    'middle':0.5,
    'end':1,
  }[align||"start"]
  const children = Array.from(el.children)
  for(let c=children.length-1;c>=0;c--) {
    children[c].setAttribute('x', origX + weight*bbox.width)
  }
  el.setAttribute("text-anchor", align)
  el.setAttribute('x', origX + weight*bbox.width)
}

Hooks.ResizeRenewText = {
  // Callbacks
  mounted() { 
    renewTextAlignment(this.el)
  },
  beforeUpdate() {  },
  updated() { 
    renewTextAlignment(this.el)
  },
  destroyed() {  },
  disconnected() {  },
  reconnected()  {  },
}

Hooks.RenewStyleAttribute = {
  // Callbacks
  mounted() { 
    const rnwElement = this.el.getAttribute('rnw-element')
    const rnwStyle = this.el.getAttribute('rnw-style')
    const rnwLayerId = this.el.getAttribute('rnw-layer-id')

    this.el.addEventListener('change', (evt) => {
      this.pushEvent("update_style", {
        value: ['radio','checkbox'].indexOf(evt.currentTarget.type) > -1 ? evt.currentTarget.checked: evt.currentTarget.value,
        element: rnwElement,
        style: rnwStyle,
        layer_id: rnwLayerId,
      })
    })
  },
  beforeUpdate() {  },
  updated() { 
  },
  destroyed() {  },
  disconnected() {  },
  reconnected()  {  },
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

