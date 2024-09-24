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

    const eventType = this.el.tagName == "BUTTON" ? 'click' : 'input'

    this.el.addEventListener(eventType, (evt) => {
      const newValue = ['radio','checkbox'].indexOf(evt.currentTarget.type) > -1 ? evt.currentTarget.checked: evt.currentTarget.value

    console.log("update_style")
      this.pushEvent("update_style", {
        value: newValue,
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

Hooks.RenewBoxSize = {
  // Callbacks
  mounted() {
    this.el.addEventListener('input', (evt) => {
      const {position_x, position_y, width, height} = Object.fromEntries(new FormData(evt.currentTarget))
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')

    console.log("update_box_size")
      this.pushEvent("update_box_size", {
        value: {position_x, position_y, width, height},
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
Hooks.RenewTextBody = {
  // Callbacks
  mounted() { 
    this.el.addEventListener('input', (evt) => {
      const body = evt.currentTarget.value
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')

    console.log("update_text_body")
      this.pushEvent("update_text_body", {
        value: body,
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
Hooks.RenewTextPosition = {
  // Callbacks
  mounted() {
    this.el.addEventListener('input', (evt) => {
      const {position_x, position_y} = Object.fromEntries(new FormData(evt.currentTarget))
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')

    console.log("update_text_position")
      this.pushEvent("update_text_position", {
        value: {position_x, position_y},
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

Hooks.RenewZIndex = {
  // Callbacks
  mounted() {
    this.el.addEventListener('input', (evt) => {
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')
      const newValue = evt.currentTarget.valueAsNumber

    console.log("update_z_index")
      this.pushEvent("update_z_index", {
        value: newValue,
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

Hooks.RenewEdgePosition = {
  // Callbacks
  mounted() {
    this.el.addEventListener('input', (evt) => {
      const {source_x, source_y, target_x, target_y} = Object.fromEntries(new FormData(evt.currentTarget))
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')

    console.log("update_edge_position")
      this.pushEvent("update_edge_position", {
        value: {source_x, source_y, target_x, target_y},
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

Hooks.RenewEdgeWaypointCreate = {
  // Callbacks
  mounted() {
    this.el.addEventListener('click', (evt) => {
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')
      const rnwWaypointId = evt.currentTarget.getAttribute('rnw-waypoint-id')
      
      console.log("create_waypoint")
      this.pushEvent("create_waypoint", {
        layer_id: rnwLayerId,
        after_waypoint_id: rnwWaypointId,
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

Hooks.RenewEdgeWaypointPosition = {
  // Callbacks
  mounted() {
    this.el.addEventListener('input', (evt) => {
      const {position_x, position_y} = Object.fromEntries(new FormData(evt.currentTarget))
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')
      const rnwWaypointId = evt.currentTarget.getAttribute('rnw-waypoint-id')

    console.log("update_waypoint_position")
      this.pushEvent("update_waypoint_position", {
        value: {position_x, position_y},
        layer_id: rnwLayerId,
        waypoint_id: rnwWaypointId,
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

Hooks.RenewEdgeWaypointDelete = {
  // Callbacks
  mounted() {
    this.el.addEventListener('click', (evt) => {
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')
      const rnwWaypointId = evt.currentTarget.getAttribute('rnw-waypoint-id')

    console.log("delete_waypoint")
      this.pushEvent("delete_waypoint", {
        layer_id: rnwLayerId,
        waypoint_id: rnwWaypointId,
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

Hooks.RenewEdgeWaypointsClear = {
  // Callbacks
  mounted() {
    this.el.addEventListener('click', (evt) => {
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')

    console.log("clear_waypoints")
      this.pushEvent("clear_waypoints", {
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

Hooks.RenewSemanticTag = {
  // Callbacks
  mounted() {
    this.el.addEventListener('input', (evt) => {
      const semanticTag = evt.currentTarget.value
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')

    console.log("update_semantic_tag")
      this.pushEvent("update_semantic_tag", {
        value: semanticTag,
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

Hooks.RenewBoxShape = {
  // Callbacks
  mounted() {
    this.el.addEventListener('input', (evt) => {
      const {shape_id, shape_attributes} = Object.fromEntries(new FormData(evt.currentTarget))
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')

    console.log("update_shape")
      this.pushEvent("update_shape", {
        value: {shape_id: shape_id || null, shape_attributes: shape_attributes.trim() ? JSON.parse(shape_attributes) : null},
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

Hooks.RnwEdgeBond = {
  // Callbacks
  mounted() {
    this.el.addEventListener('submit', (evt) => {
      evt.preventDefault()
      const rnwEdgeId = evt.currentTarget.getAttribute('rnw-edge-id')
      const bondKind = evt.currentTarget.getAttribute('rnw-kind')
      const {layer_id, socket_id} = Object.fromEntries(new FormData(evt.currentTarget))

      if(layer_id && socket_id) {
        console.log("create_edge_bond")
        this.pushEvent("create_edge_bond", {
          edge_id: rnwEdgeId,
          kind: bondKind,
          layer_id: layer_id,
          socket_id: socket_id,
        })
      }
    }) 
  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() {  },
  disconnected() {  },
  reconnected()  {  },
}



Hooks.RnwLinkLayer = {
  // Callbacks
  mounted() {
    this.el.addEventListener('change', (evt) => {
      evt.preventDefault()
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')
      const {target} = Object.fromEntries(new FormData(evt.currentTarget))

      if(target) {
        console.log("link_layer")
        this.pushEvent("link_layer", {
          source_layer_id: rnwLayerId,
          target_layer_id: target,
        })
      }
    }) 
  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() {  },
  disconnected() {  },
  reconnected()  {  },
}

Hooks.RnwAssignInterface = {
  // Callbacks
  mounted() {
    this.el.addEventListener('change', (evt) => {
      evt.preventDefault()
      const rnwLayerId = evt.currentTarget.getAttribute('rnw-layer-id')
      const socket_schema_id = evt.currentTarget.value

      if(socket_schema_id) {
        console.log("assign_layer_socket_schema")
        this.pushEvent("assign_layer_socket_schema", {
          layer_id: rnwLayerId,
          socket_schema_id: socket_schema_id,
        })
      }
    }) 
  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() {  },
  disconnected() {  },
  reconnected()  {  },
}

Hooks.RnwSnapshotPin = {
  // Callbacks
  mounted() {
    this.el.addEventListener('submit', (evt) => {
      evt.preventDefault()
      const rnwSnapshotId = evt.currentTarget.getAttribute('rnw-snapshot-id')
      const {description} = Object.fromEntries(new FormData(evt.currentTarget))


      console.log("create_snapshot_label")
      this.pushEvent("create_snapshot_label", {
        snapshot_id: rnwSnapshotId,
        description: description,
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


Hooks.RnwSocket = {
  // Callbacks
  mounted() {
    this.mouseup = (evt) => {
      evt.preventDefault()
      this.el.style.fill=null
    }

    this.el.addEventListener('mousedown', (evt) => {
      evt.preventDefault()
      evt.stopPropagation()
      this.el.style.fill="purple"
    })

    this.el.addEventListener('click', (evt) => {
      evt.preventDefault()
      evt.stopPropagation()
    })

    window.addEventListener('mouseup', this.mouseup)
  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() { 

    window.removeEventListener('mouseup', this.mouseup)
  },
  disconnected() {  },
  reconnected()  {  },
}


Hooks.RenewGrabber = {
  // Callbacks
  mounted() {
    this.el.addEventListener('dragstart', (evt) => {
      evt.dataTransfer.setData("text/plain", evt.currentTarget.getAttribute('rnw-layer-id'));
    }) 
  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() {  },
  disconnected() {  },
  reconnected()  {  },
}
Hooks.RenewDropper = {
  // Callbacks
  mounted() {
    let counter = 0
    this.el.addEventListener('dragenter', (evt) => {
        const subjectId = evt.dataTransfer.getData("text");
        const targetId = evt.currentTarget.getAttribute('rnw-layer-id');
        if(subjectId==targetId) {
          return
        }
      evt.currentTarget.style.backgroundColor="lightgreen"
      evt.currentTarget.style.outline="8px solid lightgreen"
      counter++
    }) 
    this.el.addEventListener('dragleave', (evt) => {
       const subjectId = evt.dataTransfer.getData("text");
        const targetId = evt.currentTarget.getAttribute('rnw-layer-id');
        if(subjectId==targetId) {
          return
        }
      if(--counter < 1) {
        evt.currentTarget.style.backgroundColor="initial"
        evt.currentTarget.style.outline="initial"
      }
    }) 
    this.el.addEventListener('drop', (evt) => {
        counter = 0
        evt.currentTarget.style.backgroundColor="initial"
        evt.currentTarget.style.outline="initial"
        const subjectId = evt.dataTransfer.getData("text");
        const targetId = evt.currentTarget.getAttribute('rnw-layer-id');
        const relative = evt.currentTarget.getAttribute('rnw-relative');
        const order = evt.currentTarget.getAttribute('rnw-order');
        if(subjectId==targetId) {
          return
        }

        console.log("move_layer")
        this.pushEvent("move_layer", {
          target_layer_id: targetId,
          layer_id: subjectId,
          order: order,
          relative: relative // vs inside_top
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
Hooks.RnwBoxDragger = {
  // Callbacks
  mounted() {
    let x = 0
    let y = 0
    const rnwLayerId = this.el.getAttribute('rnw-layer-id')
    const svg = this.el.ownerSVGElement
    const pt = svg.createSVGPoint();

    function cursorPoint(evt){
      pt.x = evt.clientX; pt.y = evt.clientY;
      return pt.matrixTransform(svg.getScreenCTM().inverse());
    }

    this.dragMove = (evt) => {
      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y

      this.el.setAttribute('transform', `translate(${dx}, ${dy})`)
    }

    this.mouseUp = (evt) => {
      evt.preventDefault()
      window.removeEventListener('mousemove', this.dragMove)
      window.removeEventListener('mouseup', this.mouseUp)

      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y

      
          console.log("update_box_size")
          const bbox = this.el.getBBox()
      this.pushEvent("update_box_size", {
        value: {position_x:bbox.x+dx, position_y:bbox.y+dy},
        layer_id: rnwLayerId,
      })
    }

    this.el.addEventListener('click', function(e) {
      e.stopPropagation()
    })

    this.el.addEventListener('mousedown', (evt) => {
      evt.stopPropagation()

      evt.preventDefault()
      const p = cursorPoint(evt)
      x = p.x
      y = p.y

      window.addEventListener('mousemove', this.dragMove)
      window.addEventListener('mouseup', this.mouseUp)

    })

  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() { 
    window.removeEventListener('mousemove', this.dragMove)
    window.removeEventListener('mouseup', this.mouseUp)
 },
  disconnected() {  },
  reconnected()  {  },
}

Hooks.RnwBoxResizeDragger = {
  // Callbacks
  mounted() {
    let x = 0
    let y = 0
    const rnwLayerId = this.el.getAttribute('rnw-layer-id')
    const svg = this.el.ownerSVGElement
    const pt = svg.createSVGPoint();
    let offsetX = 0
    let offsetY = 0

    function cursorPoint(evt){
      pt.x = evt.clientX; pt.y = evt.clientY;
      return pt.matrixTransform(svg.getScreenCTM().inverse());
    }

    this.dragMove = (evt) => {
      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y

      this.el.setAttribute('transform', `translate(${dx}, ${dy})`)
    }

    this.mouseUp = (evt) => {
      evt.preventDefault()
      window.removeEventListener('mousemove', this.dragMove)
      window.removeEventListener('mouseup', this.mouseUp)

      const p = cursorPoint(evt)

      
          console.log("update_box_size")
          const bbox = this.el.previousElementSibling.getBBox()
      this.pushEvent("update_box_size", {
        value: {width: Math.max(3, p.x - bbox.x - offsetX), height: Math.max(3, p.y - bbox.y - offsetY)},
        layer_id: rnwLayerId,
      })
    }


    this.el.addEventListener('click', function(e) {
      e.stopPropagation()
    })

    this.el.addEventListener('mousedown', (evt) => {
      evt.stopPropagation()

      evt.preventDefault()
      const p = cursorPoint(evt)
      x = p.x
      y = p.y

      const bbox = this.el.previousElementSibling.getBBox()
      offsetX = p.x - bbox.x - bbox.width
      offsetY = p.y - bbox.y - bbox.height

      window.addEventListener('mousemove', this.dragMove)
      window.addEventListener('mouseup', this.mouseUp)

    })

  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() { 
    window.removeEventListener('mousemove', this.dragMove)
    window.removeEventListener('mouseup', this.mouseUp)
 },
  disconnected() {  },
  reconnected()  {  },
}

Hooks.RnwEdgeDragger = {
  // Callbacks
  mounted() {
    let x = 0
    let y = 0
    const rnwLayerId = this.el.getAttribute('rnw-layer-id')
    const rnwEdgeSide = this.el.getAttribute('rnw-edge-side')
    const svg = this.el.ownerSVGElement
    const pt = svg.createSVGPoint();
    let moved = 0

    function cursorPoint(evt){
      pt.x = evt.clientX; pt.y = evt.clientY;
      return pt.matrixTransform(svg.getScreenCTM().inverse());
    }

    this.dragMove = (evt) => {
      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y

      moved += Math.hypot(dx, dy)

      this.el.setAttribute('transform', `translate(${dx}, ${dy})`)
    }

    this.mouseUp = (evt) => {
      evt.preventDefault()
      window.removeEventListener('mousemove', this.dragMove)
      window.removeEventListener('mouseup', this.mouseUp)

      const p = cursorPoint(evt)
      if(moved > 2) {
        console.log("update_edge_position")
        this.pushEvent("update_edge_position", {
          value: {[`${rnwEdgeSide}_x`]: p.x, [`${rnwEdgeSide}_y`]: p.y},
          layer_id: rnwLayerId,
          side: rnwEdgeSide,
        })
      }
    }


    this.el.addEventListener('click', function(e) {
      e.stopPropagation()
    })

    this.el.addEventListener('mousedown', (evt) => {
      evt.stopPropagation()

      evt.preventDefault()
      const p = cursorPoint(evt)
      x = p.x
      y = p.y

      moved = 0

      window.addEventListener('mousemove', this.dragMove)
      window.addEventListener('mouseup', this.mouseUp)

    })

  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() { 
    window.removeEventListener('mousemove', this.dragMove)
    window.removeEventListener('mouseup', this.mouseUp)
 },
  disconnected() {  },
  reconnected()  {  },
}


Hooks.RnwWaypointDragger = {
  // Callbacks
  mounted() {
    let x = 0
    let y = 0
    const rnwLayerId = this.el.getAttribute('rnw-layer-id')
    const rnwWaypointId = this.el.getAttribute('rnw-waypoint-id')
    const svg = this.el.ownerSVGElement
    const pt = svg.createSVGPoint();
    let moved = 0
    let preventClick = false

    function cursorPoint(evt){
      pt.x = evt.clientX; pt.y = evt.clientY;
      return pt.matrixTransform(svg.getScreenCTM().inverse());
    }

    this.dragMove = (evt) => {
      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y

      moved += Math.hypot(dx, dy)

      this.el.setAttribute('transform', `translate(${dx}, ${dy})`)
    }

    this.mouseUp = (evt) => {
      evt.preventDefault()
      window.removeEventListener('mousemove', this.dragMove)
      window.removeEventListener('mouseup', this.mouseUp)

      const p = cursorPoint(evt)
      if(moved > 2) {
        console.log("update_waypoint_position")
        this.pushEvent("update_waypoint_position", {
          value: {position_x: p.x, position_y: p.y},
          layer_id: rnwLayerId,
          waypoint_id: rnwWaypointId,
        })
        preventClick = true
      }
    }


    this.el.addEventListener('click', function(e) {
      e.stopPropagation()
    })

    this.el.addEventListener('mousedown', (evt) => {
      evt.stopPropagation()

      evt.preventDefault()
      const p = cursorPoint(evt)
      x = p.x
      y = p.y

      moved = 0
      preventClick = false

      window.addEventListener('mousemove', this.dragMove)
      window.addEventListener('mouseup', this.mouseUp)

    })

    this.el.addEventListener('dblclick', (evt) => {
      if(preventClick)  {
        preventClick = false
        return
      }

        console.log("delete_waypoint")
      this.pushEvent("delete_waypoint", {
        layer_id: rnwLayerId,
        waypoint_id: rnwWaypointId,
      })
    })

  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() { 
    window.removeEventListener('mousemove', this.dragMove)
    window.removeEventListener('mouseup', this.mouseUp)
 },
  disconnected() {  },
  reconnected()  {  },
}


Hooks.RnwWaypointCreator = {
  // Callbacks
  mounted() {
    let x = 0
    let y = 0
    const svg = this.el.ownerSVGElement
    const pt = svg.createSVGPoint();

    function cursorPoint(evt){
      pt.x = evt.clientX; pt.y = evt.clientY;
      return pt.matrixTransform(svg.getScreenCTM().inverse());
    }

    this.dragMove = (evt) => {
      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y

      this.el.setAttribute('transform', `translate(${dx}, ${dy})`)
    }

    this.mouseUp = (evt) => {
      evt.preventDefault()
      window.removeEventListener('mousemove', this.dragMove)
      window.removeEventListener('mouseup', this.mouseUp)

      const p = cursorPoint(evt)

      const rnwLayerId = this.el.getAttribute('rnw-layer-id')
      const rnwWaypointId = this.el.getAttribute('rnw-waypoint-id')

    console.log("create_waypoint")
      this.pushEvent("create_waypoint", {
        layer_id: rnwLayerId,
        after_waypoint_id: rnwWaypointId,
        position_x: p.x, 
        position_y: p.y
      })
    }


    this.el.addEventListener('click', function(e) {
      e.stopPropagation()
    })

    this.el.addEventListener('mousedown', (evt) => {
      evt.stopPropagation()

      evt.preventDefault()
      const p = cursorPoint(evt)
      x = p.x
      y = p.y

      window.addEventListener('mousemove', this.dragMove)
      window.addEventListener('mouseup', this.mouseUp)

    })

  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() { 
    window.removeEventListener('mousemove', this.dragMove)
    window.removeEventListener('mouseup', this.mouseUp)
 },
  disconnected() {  },
  reconnected()  {  },
}

Hooks.RnwTextDragger = {
  // Callbacks
  mounted() {
    let x = 0
    let y = 0
    const rnwLayerId = this.el.getAttribute('rnw-layer-id')
    const svg = this.el.ownerSVGElement
    const pt = svg.createSVGPoint();
    let moved = 0

    function cursorPoint(evt){
      pt.x = evt.clientX; pt.y = evt.clientY;
      return pt.matrixTransform(svg.getScreenCTM().inverse());
    }

    this.dragMove = (evt) => {
      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y
      moved += Math.hypot(dx, dy)

      this.el.setAttribute('transform', `translate(${dx}, ${dy})`)
    }

    this.mouseUp = (evt) => {
      evt.preventDefault()
      window.removeEventListener('mousemove', this.dragMove)
      window.removeEventListener('mouseup', this.mouseUp)

      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y

      if(moved > 2) {

        const bbox = this.el.getBBox()
        this.pushEvent("update_text_position", {
          value: {position_x: bbox.x+dx, position_y: bbox.y+dy},
          layer_id: rnwLayerId,
        })
      }
    }


    this.el.addEventListener('click', function(e) {
      e.stopPropagation()
    })

    this.el.addEventListener('mousedown', (evt) => {
      evt.stopPropagation()

      evt.preventDefault()
      const p = cursorPoint(evt)
      x = p.x
      y = p.y
      moved = 0

      window.addEventListener('mousemove', this.dragMove)
      window.addEventListener('mouseup', this.mouseUp)

    })

  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() { 
    window.removeEventListener('mousemove', this.dragMove)
    window.removeEventListener('mouseup', this.mouseUp)
 },
  disconnected() {  },
  reconnected()  {  },
}



Hooks.RnwGroupDragger = {
  // Callbacks
  mounted() {
    let x = 0
    let y = 0
    const rnwLayerId = this.el.getAttribute('rnw-layer-id')
    const svg = this.el.ownerSVGElement
    const pt = svg.createSVGPoint();
    let moved = 0

    function cursorPoint(evt){
      pt.x = evt.clientX; pt.y = evt.clientY;
      return pt.matrixTransform(svg.getScreenCTM().inverse());
    }

    this.dragMove = (evt) => {
      if(!this.el.hasAttribute('selected')) {
        return
      }
      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y
      moved += Math.hypot(dx, dy)
      this.el.setAttribute('transform', `translate(${dx}, ${dy})`)
    }

    let stopClick = false
    this.preventClick = (evt) => {
      if(!this.el.hasAttribute('selected')) {
        return
      }
      if(stopClick) {
        evt.stopPropagation()
        stopClick = false
      }

    }

    this.mouseUp = (evt) => {
      if(!this.el.hasAttribute('selected')) {
        return
      }
      evt.preventDefault()
      window.removeEventListener('mousemove', this.dragMove)
      window.removeEventListener('mouseup', this.mouseUp)

      const p = cursorPoint(evt)
      const dx = p.x - x
      const dy = p.y - y

      if(moved > 2) {
        this.pushEvent("move_layer_relative", {
          layer_id: rnwLayerId,
          dx: dx, dy: dy
        })
        stopClick = true
      }
    }

    window.addEventListener('click', this.preventClick, true)
    this.el.addEventListener('mousedown', (evt) => {
      if(!this.el.hasAttribute('selected')) {
        return
      }
      evt.stopPropagation()

      evt.preventDefault()
      const p = cursorPoint(evt)
      x = p.x
      y = p.y
      moved = 0

      window.addEventListener('mousemove', this.dragMove)
      window.addEventListener('mouseup', this.mouseUp)

    })

  },
  beforeUpdate() {  },
  updated() { 

  },
  destroyed() { 
    window.removeEventListener('mousemove', this.dragMove)
    window.removeEventListener('mouseup', this.mouseUp)
    window.removeEventListener('click', this.preventClick, true)
 },
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

