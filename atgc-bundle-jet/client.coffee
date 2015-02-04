

###
Manages all the jets at the same time
###
class module.exports

  constructor: (old) ->

    if old?
      @objects = old.objects
      @material = old.material
      @geometry = old.geometry

  config: (conf) ->

    sizeX: conf.sizeX
    sizeY: conf.sizeY
    sizeZ: conf.sizeZ
    scale: conf.scale

    radiusTop: conf.radiusTop
    radiusBottom: conf.radiusBottom
    height: conf.height
    segmentsRadius: conf.segmentsRadius

  update: (init) ->
    if init

      @objects ?= []

      if @geometry?
        @geometry.dispose()

      if @material?
        @material.dispose()

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

      @material = new THREE.MeshNormalMaterial()

      # rebuild existing objects using new geometry and materials
      for obj in @objects
        obj.rebuild()

  remove: (obj) ->
    i = @objects.indexOf i
    if i > -1
      @objects = @objects.splice(i, 1)
    else
      console.log "atgc-bundle-het: couldn't remove instance of #{obj} (not found in @objects)"

  ###
  Update jets
  ###
  render: ->

    lookAt = @app.scene

    for jet in @objects
      jet.mesh.lookAt lookAt.position
      #jet.mesh.position.set @app.camera.position.x, @app.camera.position.y, @app.camera.position.z
      #jet.light.position.set @app.camera.position.x, @app.camera.position.y, @app.camera.position.z


  build: ->

    obj = {}
    obj.mesh = new THREE.Mesh @geometry, @material

    #obj.mesh.position.set owner.position.x, owner.position.y, owner.position.z

    obj.mesh.scale.x =  obj.mesh.scale.y = obj.mesh.scale.z = @conf.scale
    obj.mesh.castShadow = no
    obj.mesh.receiveShadow = no
    obj.mesh.geometry.computeFaceNormals()
    obj.mesh.geometry.computeVertexNormals()

    spotLight = new THREE.SpotLight( 0xffffff )

    spotLight.position = @app.camera.position  #.set( 0, 400, 0 )

    spotLight.castShadow = yes

    spotLight.shadowMapWidth = 2048
    spotLight.shadowMapHeight = 2048
    spotLight.shadowDarkness = 0.2
    spotLight.shadowCameraNear = 40
    spotLight.shadowCameraFar = 8000
    spotLight.shadowCameraFov = 30
    spotLight.shadowCameraVisible = yes

    obj.light = new THREE.SpotLight(0xffffff,4,40);
    obj.light.shadowCameraVisible = yes
    @app.camera.add obj.light
    @app.camera.add obj.mesh
    obj.mesh.position.set(0,0,-1)
    obj.light.position.set(0,0,1)
    obj.light.target = @app.camera

    #@app.scene.add spotLight
    # end of initialization
    ###
    obj.light = new THREE.SpotLight( 0xffffff )

    obj.light.intensity = 1
    obj.light.distance = 1000
    #obj.light.castShadow = yes

    obj.light.shadowMapWidth = 2048
    obj.light.shadowMapHeight = 2048
    obj.light.shadowDarkness = 0.2
    obj.light.shadowCameraNear = 40
    obj.light.shadowCameraFar = 8000
    obj.light.shadowCameraFov = 30
    obj.light.shadowCameraVisible = yes
    ###

    #flashlight = new THREE.SpotLight(0xffffff,4,40);
    #@app.camera.add(flashlight);
    #flashlight.position.set(0,0,1);
    #flashlight.target = @app.camera
    # rebuild an existing object using a new geometry and all

    obj.light.tween = new TWEEN.Tween({intensity: obj.light.intensity, distance: obj.light.distance})
      .to { intensity: 1.0, distance: 1200 }, 1000
      .delay 1000 # wait for the pilot to sit before turning on the engine
      .easing TWEEN.Easing.Quadratic.InOut
      .onUpdate ->
        obj.light.intensity = @intensity

    obj.rebuild = =>
      @app.scene.remove obj.light
      @app.scene.remove obj.mesh
      newMesh = new THREE.Mesh @geometry, @material
      newMesh.position.set obj.mesh.position.x, obj.mesh.position.y, obj.mesh.position.z
      newMesh.scale.x = newMesh.scale.y = newMesh.scale.z = @conf.scale
      newMesh.castShadow = no
      newMesh.receiveShadow = no
      newMesh.geometry.computeFaceNormals()
      newMesh.geometry.computeVertexNormals()
      obj.mesh = newMesh
      #@app.scene.add obj.mesh
      #@app.scene.add obj.light

    obj.run = ->
      # turn on the reactor lights
      #obj.light.tween.start()

    obj.destroy = =>
      # to tween to stop if jet is not runnin!
      obj.light.tween.stop()
      #@app.scene.remove obj.light
      #@app.scene.remove obj.mesh
      @remove obj

    #@app.scene.add obj.mesh
    #@app.scene.add obj.light

    @objects.push obj

    obj

  make: ->
    console.log "atgc-bundle-jet: taking over a new jet.."
    # TODO: smooth transition to the
    @app.controls.removeListeners()
    @app.controls = new THREE.JetControls @app, @
    @app.controls.movementSpeed = 200
    @app.controls.lookSpeed     = 0.1
    @app.controls.moveForward   = true
    @app.controls.autoForward   = true

    jet = @build()
    jet.run()


    # TODO fire up some cool sound

    # accelerate
    jet
