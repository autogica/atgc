
class module.exports

  constructor: ->
    #
    # * Add a shuffle function to Array object prototype
    # * Usage :
    # *  var tmpArray = ["a", "b", "c", "d", "e"];
    # *  tmpArray.shuffle();
    #
    window.async = (t, f) -> setTimeout f
    Array::shuffle = ->
      i = @length
      return if i is 0
      while --i
        j = Math.floor(Math.random() * (i + 1))
        tmp = @[i]
        @[i] = @[j]
        @[j] = tmp
      return

  # note: we should use this:
  # https://github.com/jeromeetienne/threex.terrain/blob/master/threex.terrain.js
  # to colorize the terrain
  # or maybe, we should use this:
  # https://github.com/jbouny/terrain-generator
  # to generate the terrain
  # but personnally, I prefer the minimalist operative code
  buildTerrain: (cb) ->
    runTask = operative (opts, cb) ->

      importScripts opts.scripts.improvednoise

      size = opts.worldWidth * opts.worldHeight
      data = new Float32Array size

      perlin = new ImprovedNoise()
      quality = opts.qualityA
      z = Math.random() * opts.amplitude

      for i in [0...size]
        data[i] = 0

      for j in [0...opts.iterations]
        for i in [0...size]
          x = i % opts.worldWidth
          y = ~~ (i / opts.worldWidth)
          data[i] += Math.abs(perlin.noise(x / quality, y / quality, z) * quality * opts.qualityB)

        quality *= opts.qualityC

       cb data
    runTask @conf, cb

  buildGeometry: (terrain, cb) ->

    # http://stackoverflow.com/questions/16904383/merging-geometries-using-a-webworker

    # transferable objects: http://updates.html5rocks.com/2011/12/Transferable-Objects-Lightning-Fast

    # three.js buffers and webworkers, interesting solution:
    # http://stackoverflow.com/questions/17442946/how-to-efficiently-convert-three-geometry-to-arraybuffer-file-or-blob
    #runTask = operative (opts, terrain, cb) ->
    runTask = (opts, terrain, cb) ->

      #importScripts opts.scripts.threejs

      geometry = new THREE.PlaneBufferGeometry(
        opts.width,
        opts.height,
        opts.worldWidth - 1,
        opts.worldHeight - 1
      )

      geometry.applyMatrix(new THREE.Matrix4().makeRotationX(-Math.PI / 2))

      cb geometry

    runTask @conf, terrain, cb


  config: (conf) ->
    altitude: conf.altitude
    width: conf.width
    height: conf.height
    amplitude: conf.amplitude
    qualityA: conf.qualityA
    qualityB: conf.qualityB
    qualityC: conf.qualityC
    worldWidth: conf.worldWidth
    worldHeight: conf.worldHeight

    groundColorAmbientH: conf.groundColorAmbientHSL[0]
    groundColorAmbientS: conf.groundColorAmbientHSL[1]
    groundColorAmbientL: conf.groundColorAmbientHSL[2]

    groundColorH: conf.groundColorHSL[0]
    groundColorS: conf.groundColorHSL[1]
    groundColorL: conf.groundColorHSL[2]

    groundColorSpecularH: conf.groundColorSpecularHSL[0]
    groundColorSpecularS: conf.groundColorSpecularHSL[1]
    groundColorSpecularL: conf.groundColorSpecularHSL[2]

    groundColorShininessH: conf.groundColorShininessHSL[0]
    groundColorShininessS: conf.groundColorShininessHSL[1]
    groundColorShininessL: conf.groundColorShininessHSL[2]

    iterations: conf.iterations
    scripts:
      threejs: app.gunfire.resourcesPath + "/threejs/three.min.js"
      improvednoise: app.gunfire.resourcesPath + "/threejs/ImprovedNoise.js"


  update: (init) ->
    if init

      @buildTerrain (terrain) =>
        @buildGeometry terrain, (geometry) =>

          @geometry = geometry

          groundColorAmbient = new THREE.Color()
          groundColorAmbient.setHSL @conf.groundColorAmbientH, @conf.groundColorAmbientS, @conf.groundColorAmbientL

          groundColor = new THREE.Color()
          groundColor.setHSL @conf.groundColorH, @conf.groundColorS, @conf.groundColorL

          groundColorSpecular = new THREE.Color()
          groundColorSpecular.setHSL @conf.groundColorSpecularH, @conf.groundColorSpecularS, @conf.groundColorSpecularL

          groundColorShininess = new THREE.Color()
          groundColorShininess.setHSL @conf.groundColorShininessH, @conf.groundColorShininessS, @conf.groundColorShininessL


          # if we have colors on the mesh, use this:
          # vertexColors: THREE.FaceColors


          # simple material
          @material = new THREE.MeshPhongMaterial
            ambient: 0xffffff
            color: 0xffffff
            specular: 0x05050
            shininess: 30
            shading: THREE.FlatShading

          @mesh = new THREE.Mesh @geometry, @material

          @mesh.castShadow = yes
          @mesh.receiveShadow = yes


          @mesh.geometry.computeFaceNormals()
          @mesh.geometry.computeVertexNormals()

          @app.scene.add @mesh

          #@app.octree.add @mesh, useFaces: yes # for complex geometries, we need this?

    @mesh?.position?.y = @conf.altitude
