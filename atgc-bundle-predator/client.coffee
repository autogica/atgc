###
Manages all predators
###

# private functions
after = (t, f) -> setTimeout f, t

aclamp = (value, min = 0, max = 1) ->
  if isNaN(value) or !isFinite(value)
    return 0
  else
    return Math.min(Math.min(max, Math.abs(value)), max)

# class predatorInstance

class module.exports

  constructor: (old) ->

    @master = undefined
    @masterNode = window.app.camera # by defaut, we emit stuff in from of the camera

    @state =
      stock: []
      orderedAmount: 0
      orderInProgress: no

      buildupTime:
        left: 0
        middle: 0
        right: 0

    if old?.master?
      @master = old.master

    if old?.masterNode?
      @masterNode = old.masterNode

    if old?.state?
      @state = old.state

    # console.log "atgc-bundle-predator.constructor: going to initialize pool"
    pool = if old?.pool?
        old.pool
      else
        new ObjectPoolFactory()

    @pool = pool

    destroyer = ->
      #console.log "atgc-bundle-predator: destroyer"
      pool.free this.obj

    tweenUpdate = ->
      #console.log this.zvel

    console.log "atgc-bundle-predator.constructor: going to call pool.update"
    pool.update

      size: 1000

      geometryFactory: (opts) => (cb) =>

        loader = new THREE.JSONLoader()
        loader.load @conf.filePath, (g) =>

          #g.computeCentroids()
          g.computeFaceNormals()
          g.computeVertexNormals()
          g.computeMorphNormals()
          #g.computeTangents()
          g.computeBoundingBox()
          g.computeBoundingSphere()

          cb g

      materialFactory : (geometry, opts) -> (cb) ->
        cb new THREE.MeshPhongMaterial
          ambient: 0xffffff
          color: 0x353b3e
          specular: 0x454545
          emissive: 0x181818
          shininess: 30
          shading: THREE.FlatShading

      _materialFactory : (geometry, opts) => (cb) =>

        m = new THREE.ShaderMaterial
          uniforms:
            tNormal:
              type: 't'
              value: THREE.ImageUtils.loadTexture @conf.normalMap
            tMatCap:
              type: 't'
              value: THREE.ImageUtils.loadTexture @conf.environmentMap
            time:
              type: 'f'
              value: 0
            bump:
              type: 'f'
              value: 0
            noise:
              type: 'f'
              value: .04
            repeat:
              type: 'v2'
              value: new THREE.Vector2 1, 1
            useNormal:
              type: 'f'
              value: 0
            useRim:
              type: 'f'
              value: 0
            rimPower:
              type: 'f'
              value: 2
            useScreen:
              type: 'f'
              value: 0
            normalScale:
              type: 'f'
              value: .5
            normalRepeat:
              type: 'f'
              value: 1
          vertexShader: document.getElementById( 'sem-vs' ).textContent
          fragmentShader: document.getElementById( 'sem-fs' ).textContent
          shading: THREE.FlatShading

        m.uniforms.tMatCap.value.wrapS = m.uniforms.tMatCap.value.wrapT = THREE.ClampToEdgeWrapping
        m.uniforms.tNormal.value.wrapS = m.uniforms.tNormal.value.wrapT = THREE.RepeatWrapping

        cb m



      _materialFactory : (geometry, opts) -> (cb) ->

        m = new THREE.MeshPhongMaterial
          color: 0xffffff
          ambient: 0xffffff # should be same that color, or else..
          specular: 0x050505
          shininess: 150
          shading: THREE.FlatShading
        cb m


      meshFactory: (geometry, material, opts) -> (cb) ->
        m = new THREE.Mesh geometry, material
        m.scale.x = m.scale.y = m.scale.z = opts.scale
        m.castShadow = yes
        cb m

      objectDestroyer: (obj) ->
        app.assets['atgc-core-metrics'].dec 'atgc', 'predator.instances'
        obj.tween.stop()
        delete obj.teleportInFrontOf
        delete obj.run
        delete obj.tween
        delete obj.setMasterNode
        delete obj.teleportTo
        # TODO order an atgc-core-explosion here using obj.payload
        #window.app.assets['atgc-core-explosion']?.order(1, payload: payload).accept()
        # using money used for our own object, and allocated to the explosive
        # warhead

      objectFactory: (obj, opts) ->
        app.assets['atgc-core-metrics'].inc 'atgc', 'predator.instances'
        #console.log "atgc-bundle-predator: objectFactory:", obj, opts

        obj.speed = opts.speed
        obj.lifetime = opts.lifetime
        obj.payload = opts.payload
        obj.masterNode = opts.masterNode

        sourceValues =
          obj: obj
          zvel: 0
          zvelmax: obj.speed
          zrot: 1

        targetValues =
          obj: obj
          zvel: obj.speed # (obj.duration / 3000) # want this to last 3 seconds
          zvelmax: obj.speed
          zrot: 360

        #console.log "atgc-bundle-predator: objectFactory: new Tween.."
        # TODO create an animation in 4 steps:
        # 1. fallback / motor is disabled
        #. 2 acceleration, aiming at target, straight, with easing in out
        #. 3. cruise, more or less straight to target
        #. 4. exhausted, with errative movement eg. random rotation, cycling, hyperbolic movement
        obj.tween = new TWEEN.Tween(sourceValues)
          .to(targetValues, obj.lifetime)
          .easing TWEEN.Easing.Back.In # TWEEN.Easing.Quadratic.InOut
          .onUpdate tweenUpdate
          .onStop destroyer
          .onComplete destroyer


        obj.setMasterNode = (masterNode) ->
          obj.masterNode = masterNode
          obj

        obj.teleportTo = (node) ->
          obj.mesh.position.copy node.position
          obj.mesh.quaternion.copy node.quaternion
          obj.mesh.translateZ -60
          obj

        obj.run = ->
          obj.mesh.position.copy obj.masterNode.position
          obj.mesh.quaternion.copy obj.masterNode.quaternion
          obj.mesh.translateZ -60

          obj.mesh.visible = yes
          obj.tween.start()
          obj

        obj



  # parse config file
  config: (conf) ->
    conf

  # called when config changes: note, config should be passed as argument
  #
  update: (init, opts) ->

    console.log "atgc-bundle-predator.update: settings changed, recompiling.."
    # TODO: optimize by doing a separation between build options and
    @pool.update buildOptions: opts.build
    if init
      @pool.connectTo @app.scene
      after 3000, ->
        #console.log "atgc-bundle-predator.update->after: putting predator into player's hands"
        # this should a stateless, async message of action..
        app.assets['atgc-core-player']?.getBound 'atgc-bundle-predator'

  ###
  Update the orientation of predators?
  ###
  render: ->
    # not used right now

  order: (opts={}) ->
    console.log "atgc-bundle-predator: order for #{opts.nbInstances} instances:", opts

    budget = opts.budget ? 0

    validOpts =

      # common settings
      masterNode: opts.masterNode
      nbInstances: aclamp opts.nbInstances, 1, 100

      # less common settings
      speed:    aclamp opts.speed, 0, 1000
      lifetime: aclamp opts.lifetime, 0, 3600000
      payload:  aclamp opts.payload, 10, 1000


    console.log validOpts
    ###
    unless validOpts.deliverTo?
      throw "atgc-bundle-predator.order: invalid deliverTo"
    deli = validOpts.deliverTo # short as a shortcut
    unless deli.position? and deli.quaternion?
      unless deli.parent?.position? or deli.parent?.quaternion?
        throw "atgc-bundle-predator.order: invalid deliverTo setting (no position and/or quaternion)"
      console.log "atgc-bundle-predator.order: using parent's coordinates"
      validOpts.deliverTo = deli.parent
    ###

    cruisePrice = validOpts.speed * validOpts.lifetime * 0.10

    payloadPrice = validOpts.payload * 10

    unitPrice = payloadPrice + cruisePrice # TODO add the joule unit

    console.log "atgc-bundle-predator.order: stats:",
      budget: budget
      validOpts: validOpts
      cruisePrice: cruisePrice
      payloadPrice: payloadPrice
      unitPrice: unitPrice
      price: validOpts.nbInstances * unitPrice

    price: validOpts.nbInstances * unitPrice
    accept: (callback) =>
      console.log "atgc-bundle-predator.order->accept: accepted order"
      app.assets['atgc-core-metrics'].inc 'atgc', 'energy.spent', validOpts.nbInstances * unitPrice

      # TODO execute transaction here
      # if the client budget gets negative, we notify the bank which will take
      # strict actions like terminate the player / entity
      # isValid = window.app.assets['atgc-core-bank'].executeTransaction(..)
      #
      @pool.getAsync validOpts, callback

  addToCart: =>
    console.log "atgc-bundle-predator.addtoCart:"
    @state.orderedAmount = @state.orderedAmount + 1
    @state.orderInProgress = yes
    @

  payForCart: =>
    return unless @state.orderInProgress
    nbRockets = 1 + Math.round(@state.orderedAmount / 5)
    console.log "atgc-bundle-predator.payForCart: you released b, we buy #{nbRockets} predator rockets"
    # note: taking an order is fast but not *very* fast (ie. it's not synchronous)
    # so maybe the player would prefer to
    order = @order
      nbInstances: nbRockets
      masterNode: @masterNode # we could also give the object to a robot etc..
      speed: 2
      lifetime: 10 * 60000
      payload: 1000

    @state.orderedAmount = 0
    @state.orderInProgress = no

    console.log "atgc-bundle-predator.payForCart: gonna cost us #{order.price}"
    order.accept (rockets) =>
      # pile up warheads
      @state.stock = @state.stock.concat rockets
      console.log "atgc-bundle-predator.payForCart->acceptOrder: received goods, adding to stock.."
    @

  # define what happens when a human player take control of the predator
  bind: (master) ->
    console.log "atgc-bundle-predator.bind: giving control to controller.."
    @master = master
    @masterNode = master.node
    Mousetrap.unbind 'b'
    Mousetrap.bind 'b', @addToCart
    Mousetrap.bind 'b', @payForCart, 'keyup'
    @

  mouseDown: (left, middle, right) ->
    console.log "atgc-bundle-predator.mouseDown: pressed ", {left, middle, right}
    @state.stock.pop()?.run()

  mouseUp: (duration, left, middle, right) ->
    console.log "atgc-bundle-predator.mouseUp: released after #{duration}ms:", {left, middle, right}

  mouseMove: (mouseX, mouseY, previousX, previousY, deltaX, deltaY, deltaAbs, raycaster) ->
    #console.log "atgc-bundle-predator.mouseMove: mouse moved"
    #console.log "mouse moved from (#{previousX}, #{previousY}) to (#{mouseX}, #{mouseY}) delta: #{deltaAbs}"

  unbind: ->
    console.log "atgc-bundle-predator.unbind: releasing default controls"
    Mousetrap.unbind 'b'
    #@master = undefined # for debugging purpose, we put stuff in from of the camera
    @masterNode = window.app.camera
    @
