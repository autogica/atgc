DefaultControls = (shortcuts) ->

  # store for how long each tool button has been pressed
  elapsed: left: 0, middle: 0, right: 0

  mouseDown: (left, middle, right) ->
    btns = {left, middle, right}
    console.log "atgc-core-player: pressed " + JSON.stringify btns

  mouseUp: (duration, left, middle, right) ->
    btns = {left, middle, right}
    console.log "atgc-core-player: released " + JSON.stringify(btns) + "(after #{duration}ms)"

  mouseMove: (mouseX, mouseY, previousX, previousY, deltaX, deltaY, deltaAbs, raycaster) ->
    console.log "atgc-core-player: mouse moved"

  release: (shortcuts) ->
    console.log "atgc-core-player: releasing default controls"
    shortcuts.reset()


class module.exports

  constructor: ->
    @_BUTTONS =
      '0': 'left'
      '1': 'middle'
      '2': 'right'

    # default dummy controls, for debug
    @controls = DefaultControls

  config: (conf) ->
    conf

  mouseDownListener: (evt) =>
    console.log "atgc-core-player: mouseDown", evt
    btn = @_BUTTONS[evt.button.toString()]
    console.log "atgc-core-player: btn: ", btn
    @controls.elapsed[btn] = + new Date()
    @controls.mouseDown((evt.button == 0), (evt.button == 1), (evt.button == 2))

  mouseUpListener: (evt) =>
    console.log "atgc-core-player: mouseUp", evt
    btn = @_BUTTONS[evt.button.toString()]
    now = + new Date()
    elapsed = now - (@controls.elapsed[btn] ? now)
    @controls.mouseUp(elapsed, (evt.button == 0), (evt.button == 1), (evt.button == 2))

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
    projector = new THREE.Projector()
    projector.unprojectVector( vector, app.camera )
    raycaster = new THREE.Raycaster( app.camera.position, vector.sub( app.camera.position ).normalize() )

    @controls.mouseMove mouseX, mouseY, previousX, previousY, deltaX, deltaY, deltaAbs, raycaster

  uninstall: ->
    document.removeEventListener 'mousemove', @mouseMoveListener
    document.addEventListener "mousedown", @mouseDownListener
    document.addEventListener "mouseup",   @mouseUpListener

  update: (init) ->
    if init
      unless @shortcuts?
        @shortcuts = new window.keypress.Listener()

      # install new listeners
      document.addEventListener 'mousemove', @mouseMoveListener, no
      document.addEventListener "mousedown", @mouseDownListener, no
      document.addEventListener "mouseup",   @mouseUpListener, no


  # make the player use a tool
  use: (tool) ->

    if isString tool
      tool = app.assets[tool]
      unless tool?
        console.log "atgc-core-player: tool #{tool} does not exist."
        return

    # it is possible that .use() is called before shortcut object is initialized
    # instead of deferring, we initialize it on the spot
    unless @shortcuts?
      @shortcuts = new window.keypress.Listener()

    @controls?.release? @shortcuts
    @controls = tool.getControls @shortcuts

  # return current player's info
  get: ->
    name: @conf.name
    position: @app.camera.position
