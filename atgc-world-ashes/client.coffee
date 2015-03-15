
class module.exports

  constructor: ->

  config: (conf) -> conf

  update: (init) ->
    return unless init

    geometry = new THREE.Geometry()
    sprite1 = THREE.ImageUtils.loadTexture @conf.sprite6
    sprite2 = THREE.ImageUtils.loadTexture @conf.sprite5
    sprite3 = THREE.ImageUtils.loadTexture @conf.sprite4
    sprite4 = THREE.ImageUtils.loadTexture @conf.sprite3
    sprite5 = THREE.ImageUtils.loadTexture @conf.sprite2
    for i in [0...20000]
      v = new THREE.Vector3()
      v.x = Math.random() * 2000 - 1000
      v.y = Math.random() * 2000 - 1000
      v.z = Math.random() * 2000 - 1000
      geometry.vertices.push v

    params = [
      [ [1.0,  0.2,  0.2], sprite2, 3 ]
      [ [0.95, 0.1,  0.2], sprite3, 8 ]
      [ [0.90, 0.05, 0.2], sprite1, 6 ]
      [ [0.85, 0,    0.2], sprite5, 5  ]
      [ [0.80, 0,    0.2], sprite4, 5  ]
    ]

    for p in params
      color = p[0]
      sprite = p[1]
      size = p[2]
      material = new THREE.PointCloudMaterial
        size: size
        map: sprite
        blending: THREE.AdditiveBlending
        depthTest: yes
        transparent: yes

      material.color.setHSL color[0], color[1], color[2]
      particles = new THREE.PointCloud geometry, material
	  	particles.rotation.x = Math.random() * 6
	  	particles.rotation.y = Math.random() * 6
		  particles.rotation.z = Math.random() * 6
		  @app.scene.add particles

    return

  render: ->
    t1 = Date.now() * 0.000005
    t2 = Date.now() * 0.0000045
    i = 0
    j = 0
    for object in @app.scene.children
      if object instanceof THREE.PointCloud
        i += 1
        j += 1
        object.rotation.y = time * i
        object.rotation.z = time * j
