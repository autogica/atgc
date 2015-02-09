###
Manages all javelots
###

after = (t, f) -> setTimeout f, t

# class JavelotInstance

class module.exports

  constructor: (old) ->

    # look for elements of previous asset
    if old?
      @objects = old.objects
      @geometry = old.geometry
      @material = old.material

  config: (conf) ->

    sizeX: conf.sizeX
    sizeY: conf.sizeY
    sizeZ: conf.sizeZ
    scale: conf.scale

    cruiseDuration: conf.cruiseDuration
    cruiseSpeed: conf.cruiseSpeed
    accelDuration: conf.accelDuration

    radiusTop: conf.radiusTop
    radiusBottom: conf.radiusBottom
    height: conf.height
    segmentsRadius: conf.segmentsRadius

  update: (init) ->
    if init

      # destroy former geometry and material
      @geometry?.dispose?()
      @geometry = new THREE.CylinderGeometry(
        @conf.radiusTop,
        @conf.radiusBottom,
        @conf.height,
        @conf.segmentsRadius
      )

      @geometry.applyMatrix(
        new THREE.Matrix4().makeRotationFromEuler(
          new THREE.Euler(Math.PI / 2, Math.PI, 0)
        )
      )

      @material?.dispose?()
      @material = new THREE.MeshNormalMaterial()

      @objects ?= []
      if @objects.length is 0
        @objects = for id in [0...1000]
          mesh = new THREE.Mesh @geometry, @material
          mesh.position.x = 0
          mesh.position.y = 0
          mesh.position.z = -10000
          mesh.scale.x = mesh.scale.y = mesh.scale.z = @conf.scale
          @app.scene.add mesh

          id: id
          mesh: mesh
          isFree: yes

      app.assets['atgc-core-player']?.use? @


  ###
  Update the orientation of plants
  ###
  render: ->
    # TODO a javelot lookAt is camera's lookAt
    # or a look
    # push the javelot along it's axis
    # later, if the user's select another mesh, we go there.



  empty: ->
    return


  free: (obj) ->
    console.log "asked to free ", obj
    if typeof obj is 'undefined'
      throw "NullPointerException: you tried to free an undefined reference"
    if typeof obj is "string"
      id = obj
      console.log "atgc-bundle-javelot: asked to free object id #{id}"
      for obj in @objects
        if obj.id is id
          if obj.isFree
            console.log "atgc-bundle-javelot: object is already free"
            return
          obj.tween?.stop?()
          obj.mesh?.position.z = -10000 # put back in the store
          obj.isFree = yes
          console.log "atgc-bundle-javelot: freed #{obj.id}"
          break
    else
      if obj.isFree
        console.log "atgc-bundle-javelot: object is already free"
        return

      console.log "atgc-bundle-javelot: asked to free object #{obj.id}"
      obj.tween?.stop?()
      obj.mesh?.position.z = -10000 # put back in the store
      obj.isFree = yes
      console.log "atgc-bundle-javelot: freed #{obj.id}"



  # 'this' is the Tween
  onStopOrComplete: ->
    app.assets['atgc-bundle-javelot']?.free? this.obj

  build: ->
    console.log "atgc-bundle-javelot: building javelot.."

    # closure vars
    cruiseDuration = 120000 # @conf.cruiseDuration
    cruiseSpeed = @conf.cruiseSpeed
    accelDuration = @conf.accelDuration

    for obj in @objects
      continue unless obj.isFree
      continue unless obj.mesh?

      obj.isFree = no

      obj.mesh.position.copy app.camera.position
      obj.mesh.quaternion.copy app.camera.quaternion

      # TODO fix mesh orientation. This should be the camera's normal
      # TODO: maybe use a mutation on a "t" var to detect acceleration etc..

      obj.tween = new TWEEN.Tween({ obj: obj, zvel: 0, zrot: 1 })
        .to({ obj: obj, zvel: cruiseSpeed, zrot: 360 }, cruiseDuration)
        .easing TWEEN.Easing.Quadratic.InOut
        .onUpdate ->
          this.obj.mesh.translateZ Math.min this.zvel, cruiseSpeed
          # UNTESTED if we want a "bullet-style" rotation
          # this.obj.mesh.rotateZ Math.PI / this.zrot

        .onStop @onStopOrComplete
        .onComplete @onStopOrComplete

      obj.tween.start()
      console.log "atgc-bundle-javelot: fired object"
      return
    console.log "atgc-bundle-javelot: couldn't find a free slot"


  getControls: (shortcuts) ->

    shortcuts.register_many [
      {
        keys : "shift s"
        is_exclusive: yes
        on_keydown: ->
          console.log "atgc-bundle-javelot: You pressed shift and s together."
        on_keyup: (e) ->
          console.log "atgc-bundle-javelot: And now you've released one of the keys."
        "this": @
      },
      {
        keys: "j"
        is_exclusive: true
        on_keydown: ->
          console.log "atgc-bundle-javelot: j pressed"
        on_keyup: (e) ->
          console.log "atgc-bundle-javelot: you released j, we fire something"
          window.app.assets['atgc-bundle-javelot']?.build?()
          # Normally because we have a keyup event handler,
          # event.preventDefault() would automatically be called.
          # But because we're returning true in this handler,
          # event.preventDefault() will not be called.
          yes
        "this": @
      },
      {
        keys: "b"
        is_exclusive: true
        on_keydown: ->
          console.log "atgc-bundle-javelot: b pressed"
        on_keyup: (e) ->
          console.log "atgc-bundle-javelot: you released b, we build a random building"

          # Normally because we have a keyup event handler,
          # event.preventDefault() would automatically be called.
          # But because we're returning true in this handler,
          # event.preventDefault() will not be called.
          yes
        "this": @
      }
    ]


    # store for how long each tool button has been pressed
    elapsed:
      left: 0
      middle: 0
      right: 0

    mouseDown: (left, middle, right) =>
      btns = {left, middle, right}
      console.log "atgc-bundle-javelot: pressed " + JSON.stringify btns

    mouseUp: (duration, left, middle, right) =>
      btns = {left, middle, right}
      console.log "atgc-bundle-javelot: released " + JSON.stringify(btns) + "(after #{duration}ms)"

      # TODO use some specific "target locked" guidance control code
      if @app.assets['atgc-core-player']?.get?
        javelot = @build window.app.assets['atgc-core-player']?.get?()
        javelot.run()
        console.log "atgc-bundle-javelot: launched javelot"

    mouseMove: (mouseX, mouseY, previousX, previousY, deltaX, deltaY, deltaAbs) ->
      #console.log "mouse moved from (#{previousX}, #{previousY}) to (#{mouseX}, #{mouseY}) delta: #{deltaAbs}"
