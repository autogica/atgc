###
Manages all javelots
###

after = (t, f) -> setTimeout f, t

class module.exports

  constructor: (old) ->

    # look for elements of previous asset
    if old?
      @objects = old.objects ? {}
      @counter = old.counter
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
      @counter ?= 0
      @objects ?= {}
      # TODO javelot should looks like a good old-fashioned rocket
      # uninstall previous geometry (warning: may break current flying objects)
      #if @geometry?
      #  @geometry.dispose()

      # uninstall previous material (warning: may break current flying objects)
      #if @material?
      #  @material.dispose()

      # create new geometry using new config
      if @geometry?
        @geometry.dispose()

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

      if @material?
        @material.dispose()

      @material = new THREE.MeshNormalMaterial()

      # rebuild existing objects using new geometry and materials
      for id in Object.keys @objects
        obj = @objects[id]
        if obj?
          obj.rebuild()

      app.assets['atgc-core-player'].use @


  ###
  Update the orientation of plants
  ###
  render: ->
    # TODO a javelot lookAt is camera's lookAt
    # or a look
    # push the javelot along it's axis
    # later, if the user's select another mesh, we go there.



  destroy: (id) ->
    if id of @objects
      obj = @objects[id]
      if obj?
        obj.destroy()
      else
        console.log "object already destroyed (but here this should never happen)"
    else
      throw "not found"

  empty: ->
    # thanks to Object.keys we can iterate over the object while we are
    # modifying it (deleting items)
    for id of Object.keys @objects
      obj = @objects[id]
      if obj?
        obj.destroy()
      else
        console.log "Javelot already self-destructed or exploded"


  build: (owner) ->
    console.log "building javelot.."

    obj =
      id: @counter++

    obj.mesh = new THREE.Mesh @geometry, @material

    obj.mesh.position.copy app.camera.position
    obj.mesh.quaternion.copy app.camera.quaternion

    # TODO fix mesh orientation. This should be the camera's normal

    obj.mesh.scale.x = obj.mesh.scale.y = obj.mesh.scale.z = @conf.scale

    # it's cooler if rockets have lights, when we are in obcurity settings
    # TODO maybe we should also add a sprite
    obj.light = new THREE.SpotLight 0xffffff

    obj.light.intensity = 1
    obj.light.castShadow = yes

    obj.light.shadowMapWidth = 32
    obj.light.shadowMapHeight = 32
    obj.light.shadowDarkness = 0.2
    obj.light.shadowCameraNear = 40
    obj.light.shadowCameraFar = 8000
    obj.light.shadowCameraFov = 30
    obj.light.shadowCameraVisible = yes


    cruiseDuration = @conf.cruiseDuration
    cruiseSpeed = @conf.cruiseSpeed
    accelDuration = @conf.accelDuration


    obj.light.tween = new TWEEN.Tween({intensity: obj.light.intensity})
      .to { intensity: 1.0 }, accelDuration
      .easing TWEEN.Easing.Quadratic.InOut
      .onUpdate ->
        obj.light.intensity = @intensity

    obj.tween = new TWEEN.Tween({ zvel: 0 })
      .to({ zvel: cruiseSpeed }, accelDuration)
      .easing TWEEN.Easing.Quadratic.InOut
      .onUpdate ->
        obj.mesh.translateZ @zvel
        # TODO add a slow Z axis rotation
        # obj.mesh.rotation.z += z * Math.PI / 180

      .chain new TWEEN.Tween({ foo: 0 })
        .to({ bar: 1 }, cruiseDuration)
        .onUpdate =>
          obj.mesh.translateZ cruiseSpeed

          return unless @objects? # in case we are a zombie callback

          for id in Object.keys @objects
            jet = @objects[id]
            ###
            d = obj.mesh.position.distanceToSquared(jet.mesh.position)
            if d < 500
              console.log "BOOM"
              obj.destroy()
              jet.destroy()
              break
            if d < 100000
              obj.mesh.lookAt jet.mesh.position
              # TODO emit event for jet, to tell he is attack?
            ###
      after 3000, ->
        console.log "atgc-part-tactical-javelot: self destruct activated after 3 seconds"
        obj.destroy()


    # rebuild an existing object using a new geometry and all
    obj.rebuild = =>
      @app.scene.remove obj.light
      @app.scene.remove obj.mesh
      newMesh = new THREE.Mesh @geometry, @material
      newMesh.position.set obj.mesh.position.x, obj.mesh.position.y, obj.mesh.position.z
      newMesh.scale.x = newMesh.scale.y = newMesh.scale.z = @conf.scale
      obj.mesh = newMesh
      @app.scene.add obj.light
      @app.scene.add obj.mesh

    obj.destroy = =>
      console.log "destroying right now"
      obj.tween.stop?()
      obj.light.tween.stop?()

      @app.scene.remove obj.light
      @app.scene.remove obj.mesh
      obj.light.tween = undefined
      obj.light = undefined
      obj.tween = undefined
      obj.mesh = undefined
      delete @objects[obj.id]
      obj.id = undefined


    obj.run = =>
      obj.light.tween.start()
      obj.tween.start()

    @app.scene.add obj.light
    @app.scene.add obj.mesh

    @objects[obj.id] = obj

    obj



  getControls: (shortcuts) ->

    shortcuts.register_many [
      {
        keys : "shift s"
        is_exclusive: yes
        on_keydown: ->
          console.log("You pressed shift and s together.")
        on_keyup: (e) ->
          console.log("And now you've released one of the keys.")
        "this": @
      },
      {
        keys: "j"
        is_exclusive: true
        on_keydown: ->
          console.log "j pressed"
        on_keyup: (e) ->
          console.log "you released j, we fire something"
          window.app.assets['atgc-bundle-javelot'].launch()
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
          console.log "b pressed"
        on_keyup: (e) ->
          console.log "you released b, we build a random building"

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
      console.log "pressed " + JSON.stringify btns

    mouseUp: (duration, left, middle, right) =>
      btns = {left, middle, right}
      console.log "released " + JSON.stringify(btns) + "(after #{duration}ms)"

      # TODO use some specific "target locked" guidance control code
      if @app.assets['atgc-core-player']?
        javelot = @build @app.assets['atgc-core-player'].get()
        javelot.run()
        console.log "launched javelot"

    mouseMove: (mouseX, mouseY, previousX, previousY, deltaX, deltaY, deltaAbs) ->
      #console.log "mouse moved from (#{previousX}, #{previousY}) to (#{mouseX}, #{mouseY}) delta: #{deltaAbs}"
