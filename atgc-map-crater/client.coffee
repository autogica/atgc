


class module.exports

  constructor: ->

  config: (conf) ->
    filePath: conf.filePath

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


  loadMap: (onComplete) ->

    #opts.width,
    #opts.height,
    #opts.worldWidth - 1,
    #opts.worldHeight - 1

    loader = new THREE.JSONLoader()
    loader.load @conf.filePath, (geometry) ->
      # geometry.applyMatrix(new THREE.Matrix4().makeRotationX( - Math.PI / 2))
      onComplete geometry

  update: (init) ->
    return unless init

    @loadMap (geometry) =>

      @geometry = geometry

      groundColorAmbient = new THREE.Color()
      groundColorAmbient.setHSL @conf.groundColorAmbientH, @conf.groundColorAmbientS, @conf.groundColorAmbientL

      groundColor = new THREE.Color()
      groundColor.setHSL @conf.groundColorH, @conf.groundColorS, @conf.groundColorL

      groundColorSpecular = new THREE.Color()
      groundColorSpecular.setHSL @conf.groundColorSpecularH, @conf.groundColorSpecularS, @conf.groundColorSpecularL

      groundColorShininess = new THREE.Color()
      groundColorShininess.setHSL @conf.groundColorShininessH, @conf.groundColorShininessS, @conf.groundColorShininessL

      # old version, should maybe removed
      ___material = new THREE.MeshPhongMaterial
        ambient: groundColorAmbient.getHex()
        color: groundColor.getHex()
        specular: groundColorSpecular.getHex()
        shininess: groundColorShininess.getHex()
        shading: THREE.FlatShading # always. To get the vectorial look
        wireframe: no
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
      @mesh.scale.x = 1000
      @mesh.scale.y = 1000
      @mesh.scale.z = 1000
      @mesh.position.y = -150

      @mesh.castShadow = yes
      @mesh.receiveShadow = yes

      # already computed by Blender, right?
      #@mesh.geometry.computeFaceNormals()
      #@mesh.geometry.computeVertexNormals()

      @app.scene.add @mesh

      #@app.octree.add @mesh, useFaces: yes # for complex geometries, we need this?

      #@mesh?.position?.y = @conf.altitude
