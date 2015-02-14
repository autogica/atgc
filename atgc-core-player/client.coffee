# global Tool is persistent
GlobalTool =

  bind: ->
    console.log "GlobalTool.bind: unbinding our reserved shortcuts.."

    Mousetrap.unbind 'd'

    Mousetrap.bind 'd', ->
      console.log "GlobalTool.bind('d'): toggling debug mode"
      window.app.debug = !window.app.debug

  mouseDown: (left, middle, right) ->
    btns = {left, middle, right}
    console.log "GlobalTool.mouseDown: pressed ", {left, middle, right}

  mouseUp: (duration, left, middle, right) ->
    console.log "GlobalTool.mouseUp: released after #{duration}ms:", {left, middle, right}

  mouseMove: (mouseX, mouseY, previousX, previousY, deltaX, deltaY, deltaAbs, raycaster) ->
    console.log "GlobalTool.mouseMove: mouse moved"

  unbind: -> # global tool keep bindings in memory
    console.log "GlobalTool.unbind: nothing to unbind, we are persistent"


class module.exports

  constructor: ->
    @_BUTTONS =
      '0': 'left'
      '1': 'middle'
      '2': 'right'

    @node = window.app.camera


    console.log "atgc-core-player.constructor: binding with GlobalTool"
    @tool = GlobalTool
    @tool.bind @


  config: (conf) ->
    conf

  mouseDownListener: (evt) =>
    console.log "atgc-core-player.mouseDownListener:", evt
    btn = @_BUTTONS[evt.button.toString()]
    console.log "atgc-core-player: btn: ", btn
    @tool.state.buildupTime[btn] = + new Date()
    @tool.mouseDown((evt.button == 0), (evt.button == 1), (evt.button == 2))

  mouseUpListener: (evt) =>
    console.log "atgc-core-player.mouseUpListener: ", evt
    btn = @_BUTTONS[evt.button.toString()]
    now = + new Date()
    elapsed = now - (@tool.state.buildupTime?[btn] ? now)
    @tool.mouseUp(elapsed, (evt.button == 0), (evt.button == 1), (evt.button == 2))

  mouseMoveListener: (evt) =>

    mouseX = evt.clientX - app.windowHalfX
    mouseY = evt.clientY - app.windowHalfY
    previousX = @mouseX ? 0
    previousY = @mouseY ? 0
    @mouseX = mouseX
    @mouseY = mouseY
    deltaX = previousX - mouseX
    deltaY = previousY - mouseY
    deltaAbs = Math.sqrt Math.pow(mouseX - previousX, 2) + Math.pow(mouseY - mouseY, 2)

    mouseXnorm = ( evt.clientX / window.innerWidth ) * 2 - 1
    mouseYnorm = -( evt.clientY / window.innerHeight ) * 2 + 1

    vector = new THREE.Vector3 mouseXnorm, mouseYnorm, app.camera.near
    # Convert the [-1, 1] screen coordinate into a world coordinate on the near plane
    # projector = new THREE.Projector() # not used anymore?
    vector.unproject( app.camera )
    raycaster = new THREE.Raycaster( app.camera.position, vector.sub( app.camera.position ).normalize() )

    @tool.mouseMove(mouseX, mouseY, previousX, previousY, deltaX, deltaY, deltaAbs, raycaster)

  uninstall: ->
    document.removeEventListener 'mousemove', @mouseMoveListener
    document.addEventListener "mousedown", @mouseDownListener
    document.addEventListener "mouseup",   @mouseUpListener

  update: (init) ->
    if init
      # install new listeners
      document.addEventListener 'mousemove', @mouseMoveListener, no
      document.addEventListener "mousedown", @mouseDownListener, no
      document.addEventListener "mouseup",   @mouseUpListener, no


  # make the player use a tool
  getBound: (thing) ->
    unless thing?
      throw "atgc-core-player.getBound: missing parameter"
    console.log "atgc-core-player.getBound: ", thing
    tool = GlobalTool
    if typeof thing is 'string'
      if thing of app.assets
        tool = app.assets[thing]
      else
        console.log "atgc-core-player.getBound: not found:", thing
    else if thing.bind? and thing.unbind?
      tool = thing
    else
      throw "atgc-core-player.getBound: cannot use object, not bindable"
    console.log "atgc-core-player.getBound: tool is", tool

    console.log "atgc-core-player.getBound: calling @tool.unbind()"
    @tool.unbind @
    @tool = tool
    console.log "atgc-core-player.getBound: calling tool.bind()"
    @tool.bind @

  # return current player's info
  ###
  Obsolete
  ###
  get: ->
    name: @conf.name
    node: @node
    position: @node.position
