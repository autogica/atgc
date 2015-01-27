class module.exports

  constructor: (app, params) ->

    console.log "atgc-core-physics: initializing physics"

    @bodies = []
    @enabled = no

  radianToDegree: (rad) -> rad * 57.29577951308232 # u rad?


  addMesh: (mesh) ->

    console.log "atgc-core-physics: addMesh"
    console.assert mesh instanceof THREE.Mesh

    window.toto = mesh

    body = {}

    #mesh.geometry.computeBoundingBox()
    mesh.geometry.computeBoundingSphere()

    if mesh.geometry.boundingBox? # instanceof THREE.CubeGeometry
      body = new OIMO.Body
        type: 'box'
        size: [
          mesh.geometry.boundingBox.width  * mesh.scale.x
          mesh.geometry.boundingBox.height * mesh.scale.y
          mesh.geometry.boundingBox.depth  * mesh.scale.z
        ]
        pos: mesh.position.toArray()
        rot: mesh.rotation.toArray().slice(0,3).map(@radianToDegree)
        world: @world
        move: yes
        mesh: mesh

    else if mesh.geometry.boundingSphere? #instanceof THREE.SphereGeometry
      body = new OIMO.Body
        type:'sphere'
        size: [mesh.geometry.boundingSphere.radius * mesh.scale.x]
        pos: mesh.position.toArray()
        rot: mesh.rotation.toArray().slice(0,3).map(@radianToDegree)
        world: @world
        move: yes
        mesh: mesh
    else
      console.log "atgc-core-physics: unknow geometry, assuming a spherical bounding box"
      return

    window.test = body

    body.updater = new THREE.Matrix4()
    body.update = ->
      body.updater.fromArray body.body.getMatrix()
      mesh.position.setFromMatrixPosition body.updater
      mesh.rotation.setFromRotationMatrix body.updater

      #mesh.updateMatrix() # what to do with this?
      mesh.matrixAutoUpdate = no # what to do with this?

    @bodies.push body

    body

  update: (init) ->
    if init

      # stats
      @elem = document.createElement 'div'

      @elem.style.position = 'absolute'
      @elem.style.top      = '10px'
      @elem.style.left     = '10px'
      @elem.style.width    = '400px'
      @elem.style.height   = '400px'
      @elem.style.fontSize = '11px'
      #@elem.style.textAlign = 'left'

      document.getElementsByTagName('body')[0].appendChild @elem

      @fps = 0
      @time_prev = 0
      @fpsint = 0

      console.log "atgc-core-physics: creating physic world"

      timeStep = 1/60 # 60*100 # default is 1/60, in the demo it is 60*100, wtf?
      broadPhaseType = 2 # 1: Brute force, 2: SAP, 3: DBVT
      iterations = 8 # default is 8
      gravityY = 0 # default is -9.80665

      @world	= new OIMO.World timeStep, broadPhaseType, iterations

      # Oimo Physics use international system units 0.1 to 10 meters max for dynamique body.
      # In demo with three.js, i scale all by 100 so object is between 10 to 10000 three unit.
      # You can change world scale.
      # for three : world.worldscale(100);
      @world.worldscale 100

      # override settings
      @world.gravity = new OIMO.Vec3(0, gravityY, 0)

      #@world.maxIslandRigidBodies = 64  # default is 64
      #if you change this, you need to set:
      #@world.islandStack.length = @world.maxIslandRigidBodies

      #@world.maxIslandConstraints = 128 # default is 64
      #if you change this, you need to set:
      #@world.islandConstraints.length = @world.maxIslandConstraints



  render: (world) ->

    if @enabled
      # update physic engine
      @world.step()

      # update meshes
      for body in @bodies
        body.update()

    # compute fps
    time = Date.now()
    if time - 1000 > @time_prev
      @time_prev = time
      @fpsint = @fps
      @fps = 0
    @fps++

    @elem.innerHTML = """
      Physics engine:<br><br>
        FPS: #{@fpsint} fps<br><br>
        Rigidbody:  #{@world.numRigidBodies} <br>
        Contact:  #{@world.numContacts} <br>
        Pair Check:  #{@world.broadPhase.numPairChecks} <br>
        Contact Point:  #{@world.numContactPoints} <br>
        Island:  #{@world.numIslands} <br><br>
        Broad-Phase:  #{@world.performance.broadPhaseTime} ms<br>
        Narrow-Phase:  #{@world.performance.narrowPhaseTime} ms<br>
        Solving: #{@world.performance.solvingTime} ms<br>
        Updating:  #{@world.performance.updatingTime} ms<br>
        Total:  #{@world.performance.totalTime} ms
      """
