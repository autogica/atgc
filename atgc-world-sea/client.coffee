
class module.exports

  constructor: (old) ->

  config: (conf) ->
    width: conf.width
    height: conf.height
    worldWidth: conf.worldWidth
    worldHeight: conf.worldHeight
    waterColorH: conf.waterColorHSL[0]
    waterColorS: conf.waterColorHSL[1]
    waterColorL: conf.waterColorHSL[2]
    waveSpeed: conf.waveSpeedMin + conf.waveSpeedFactor
    waveDepth: conf.waveDepthMin + conf.waveDepthFactor
    waterLevel: conf.waterLevel
    waterOpacity: conf.waterOpacity
    widthSegments: conf.widthSegments
    heightSegments: conf.heightSegments
    depth: conf.depth
    param: conf.param
    filterparam: conf.filterparam

  update: (init) ->

    if init
      console.log "initializing sea shaders.."
      @waterNormals = new THREE.ImageUtils.loadTexture 'textures/normal-maps/waternormals.jpg'
      @waterNormals.wrapS = @waterNormals.wrapT = THREE.RepeatWrapping

      waterParams =
        textureWidth: 512
        textureHeight: 512
        waterNormals: @waterNormals
        alpha: 1.0
        sunDirection: THREE.Vector3 1.0, 1.0, 1.0 #directionalLight.position.normalize()
        sunColor: 0xffffff
        waterColor: 0x001e0f
        distortionScale: 50.0

      @water = new THREE.Water @app.renderer, @app.camera, @app.scene, waterParams
      @geometry = new THREE.PlaneGeometry @conf.width * 500, @conf.height * 500, 50, 50
      @mesh = new THREE.Mesh @geometry,	@water.material
      @mesh.add @water
      @mesh.rotation.x = - Math.PI * 0.5

      @app.scene.add @mesh

      @position = @mesh.position

    #@mesh.material.opacity = @conf.waterOpacity
    #@mesh.material.color.setHSL @conf.waterColorH, @conf.waterColorS, @conf.waterColorL

  render: ->
    delta = @app.clock.getDelta()
    time = @app.clock.getElapsedTime() * @conf.waveSpeed
    @water.material.uniforms.time.value += 1.0 / 60.0;
    @water.render()
