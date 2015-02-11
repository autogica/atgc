###
Manages all javelots
###

# private functions
after = (t, f) -> setTimeout f, t

# class JavelotInstance

class module.exports

  constructor: (old) ->

    # this is very, very ugly..
    destroyer = ->
      console.log "atgc-bundle-javelot: destroyer"
      app.assets['atgc-bundle-javelot'].pool.free this.obj

    tweenUpdate = ->
      this.obj.mesh.translateZ -this.zvel

    @poolConfig =

      geometryFactory: (opts) ->
        console.log "atgc-bundle-javelot: geometryFactory: ", opts
        g = new THREE.CylinderGeometry(opts.radiusTop, opts.radiusBottom, opts.height, opts.segmentsRadius)

        g.applyMatrix(new THREE.Matrix4().makeRotationFromEuler(
          new THREE.Euler(- Math.PI / 2, Math.PI, 0)))
        g

      # materialFactory : (geometry, opts) -> new THREE.MeshNormalMaterial()
      meshFactory: (geometry, material, opts)  ->
        #console.log "atgc-bundle-javelot: meshFactory:", opts
        m = new THREE.Mesh geometry, material
        m.scale.x = m.scale.y = m.scale.z = opts.scale
        m

      ###
      Attention please:
      this method is called using simple array: here `@` refers to the Tween instance
      ###
      objectDestroyer: (obj) ->
        console.log "atgc-bundle-javelot: objectDestroyer:", obj
        # note that we do not destroy the mesh!! this is on purpose: we are
        # doing pooling, and mesh recycling :)
        obj.tween.stop()
        # TODO order an atgc-core-explosion here
        # using money used for our own object, and allocated to the explosive
        # warhead

      objectFactory: (obj, opts) ->
        console.log "atgc-bundle-javelot: objectFactory:", obj, opts
        obj.mesh.position.copy app.camera.position
        obj.mesh.quaternion.copy app.camera.quaternion
        obj.mesh.geometry.applyMatrix(
          new THREE.Matrix4().makeRotationFromEuler(
            new THREE.Euler(- Math.PI / 2, Math.PI, 0)
          )
        )

        obj.cruiseSpeed = opts.cruiseSpeed
        obj.cruiseDuration = opts.cruiseDuration

        obj.mesh.translateZ -30 # don't fire the mesh "inside" the camera, but a bit in front of it

        console.log "atgc-bundle-javelot: objectFactory: new Tween.."
        obj.tween = new TWEEN.Tween({ obj: obj, zvel: 0, zrot: 1 })
          .to({ obj: obj, zvel: obj.cruiseSpeed, zrot: 360 }, obj.cruiseDuration)
          .easing TWEEN.Easing.Linear.None # TWEEN.Easing.Quadratic.InOut
          .onUpdate tweenUpdate
          .onStop destroyer
          .onComplete destroyer
          .start()
        obj

    @pool = new ObjectPoolFactory 1000


  # TODO merge config and update into the same function
  config: (conf) ->
    @poolConfig.buildOptions = conf
    conf

  # called when config changes
  update: (init) ->
    console.log "atgc-bundle-javelot: update"
    # init is set the first time we load the config
    # this is the only time where it is acceptable to be a bit laggy
    # and freeze a little bit the app
    console.log "atgc-bundle-javelot: update: settings changed, recompiling.."
    @pool.compile @poolConfig
    if init
      @pool.addToScene @app.scene
      after 3000, ->
        console.log "atgc-bundle-javelot: putting javelot into player's hands"
        # this should a stateless, async message of action..
        app.assets['atgc-core-player']?.use? app.assets['atgc-bundle-javelot']

  ###
  Update the orientation of Javelots
  ###
  render: ->
    # TODO a javelot lookAt is camera's lookAt
    # or a look
    # push the javelot along it's axis
    # later, if the user's select another mesh, we go there.


  order: (n, opts={}) ->
    console.log "atgc-bundle-javelot: order for #{n} instances:", opts

    validOpts =
      cruiseSpeed: Math.abs opts.cruiseSpeed ? 3
      cruiseDuration: Math.abs opts.cruiseDuration ? 60 * 1000
      warheadPower: Math.abs opts.warheadPower ? 1000

    # TODO check parameters here

    cruisePrice = Math.abs validOpts.cruiseSpeed * validOpts.cruiseDuration * 0.10

    warheadPrice = Math.abs validOpts.warheadPower * 10

    unitPrice = warheadPrice + cruisePrice # TODO add the joule unit

    pool = @pool

    console.log "atgc-bundle-javelot:",
      validOpts: validOpts
      cruisePrice: cruisePrice
      warheadPrice: warheadPrice
      unitPrice: unitPrice
      price: n * unitPrice

    price: n * unitPrice
    accept: (cb) ->
      console.log "atgc-bundle-javelot: accepted order"
      # TODO execute transaction here
      cb pool.get n, validOpts
      return

  getControls: (shortcuts) ->
    console.log "atgc-bundle-javelot: configuring shortcuts.."
    buildup =
      j: 1
      busy: no
    shortcuts.register_many [
      {
        keys: "j"
        is_exclusive: true
        on_keydown: ->
          console.log "atgc-bundle-javelot: j pressed"
          buildup.j = buildup.j + 1
          buildup.busy = yes

        on_keyup: (e) ->
          if buildup.busy = yes
            nbRockets = Math.round(buildup.j / 5)
            console.log "atgc-bundle-javelot: you released j, we fire #{nbRockets} Javelot rockets"
            order = window.app.assets['atgc-bundle-javelot']?.order nbRockets
            buildup.j = 1
            buildup.busy = no

            console.log "atgc-bundle-javelot: gonna cost us #{order.price}"
            order.accept (goods) ->
              console.log "atgc-bundle-javelot: received goods!"

          yes # 'yes' means event.preventDefault() won't be called
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

      # TODO we should rather fire an async global event, eg something like
      # window.callAsyncAndForget('atgc-bundle-javelot:build')
      order = window.app.assets['atgc-bundle-javelot']?.order 1
      console.log "atgc-bundle-javelot: gonna cost us #{order.price}"
      order.accept (goods) ->
        console.log "atgc-bundle-javelot: received goods!"


    mouseMove: (mouseX, mouseY, previousX, previousY, deltaX, deltaY, deltaAbs) ->
      #console.log "mouse moved from (#{previousX}, #{previousY}) to (#{mouseX}, #{mouseY}) delta: #{deltaAbs}"
