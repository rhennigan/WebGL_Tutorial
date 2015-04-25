gl = undefined
shaders =
  fragReady: false
  vertReady: false
  frag: undefined
  vert: undefined
shaderProgram = undefined

mvMatrix = mat4.create()
pMatrix = mat4.create()
tVector = vec4.create()
pVector = vec4.create()
lightDirectionVector = vec4.create()

randAngle = -> 2.0 * Math.PI * Math.random()

r1Float = randAngle()
r2Float = randAngle()
r3Float = randAngle()
r4Float = randAngle()
r5Float = randAngle()
r6Float = randAngle()

vertexPositionBuffer = undefined
vertexColorBuffer = undefined
vertexNormalBuffer = undefined
vertexIndexBuffer = undefined

initGL = (canvas) ->
  try
    gl = canvas.getContext "experimental-webgl"
    gl.viewportWidth = canvas.width
    gl.viewportHeight = canvas.height
  catch e
    alert "initGL error: #{e}"
  if not gl then alert "Could not initialize WebGL"

loadShader = (path, type) ->
  request = new XMLHttpRequest()
  request.open 'GET', path, true
  request.onreadystatechange = ->
    if request.readyState is 4 and request.status is 200
      sourceString = request.responseText
      if type is 'frag'
        shaders.frag = gl.createShader gl.FRAGMENT_SHADER
        gl.shaderSource shaders.frag, sourceString
        gl.compileShader shaders.frag
        shaders.fragReady = true
      else if type is 'vert'
        shaders.vert = gl.createShader gl.VERTEX_SHADER
        gl.shaderSource shaders.vert, sourceString
        gl.compileShader shaders.vert
        shaders.vertReady = true
      else
        alert "unknown shader type: #{type}"
  request.send()

initShaders = ->
  if not shaders.fragReady
    alert "fragment shader script is not loaded"
  else if not shaders.vertReady
    alert "vertex shader script is not loaded"
  else
    shaderProgram = gl.createProgram()
    gl.attachShader shaderProgram, shaders.vert
    gl.attachShader shaderProgram, shaders.frag
    gl.linkProgram shaderProgram
    if not gl.getProgramParameter shaderProgram, gl.LINK_STATUS
      console.log shaders
      alert "failed to initialize shaders"
    else
      gl.useProgram shaderProgram
      shaderProgram.vertexPositionAttribute = gl.getAttribLocation shaderProgram, "aVertexPosition"
      shaderProgram.vertexColorAttribute = gl.getAttribLocation shaderProgram, "aVertexColor"
      shaderProgram.vertexNormalAttribute = gl.getAttribLocation shaderProgram, "aVertexNormal"
      gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
      gl.enableVertexAttribArray shaderProgram.vertexColorAttribute
      gl.enableVertexAttribArray shaderProgram.vertexNormalAttribute
      shaderProgram.pMatrixUniform = gl.getUniformLocation shaderProgram, "uPMatrix"
      shaderProgram.mvMatrixUniform = gl.getUniformLocation shaderProgram, "uMVMatrix"
      shaderProgram.tVectorUniform = gl.getUniformLocation shaderProgram, "uTVector"
      shaderProgram.pVectorUniform = gl.getUniformLocation shaderProgram, "uPVector"
      shaderProgram.lightDirectionUniform = gl.getUniformLocation shaderProgram, "uLightDirection"
      shaderProgram.r1FloatUniform = gl.getUniformLocation shaderProgram, "uR1Float"
      shaderProgram.r2FloatUniform = gl.getUniformLocation shaderProgram, "uR2Float"
      shaderProgram.r3FloatUniform = gl.getUniformLocation shaderProgram, "uR3Float"
      shaderProgram.r4FloatUniform = gl.getUniformLocation shaderProgram, "uR4Float"
      shaderProgram.r5FloatUniform = gl.getUniformLocation shaderProgram, "uR5Float"
      shaderProgram.r6FloatUniform = gl.getUniformLocation shaderProgram, "uR6Float"

setMatrixUniforms = ->
  gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
  gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix
  gl.uniform4fv shaderProgram.tVectorUniform, tVector
  gl.uniform4fv shaderProgram.pVectorUniform, pVector
  gl.uniform4fv shaderProgram.lightDirectionUniform, lightDirectionVector
  gl.uniform1f shaderProgram.r1FloatUniform, r1Float
  gl.uniform1f shaderProgram.r2FloatUniform, r2Float
  gl.uniform1f shaderProgram.r3FloatUniform, r3Float
  gl.uniform1f shaderProgram.r4FloatUniform, r4Float
  gl.uniform1f shaderProgram.r5FloatUniform, r5Float
  gl.uniform1f shaderProgram.r6FloatUniform, r6Float

initBuffers = ->
# vertex positions
  vertexPositionBuffer = gl.createBuffer()
  gl.bindBuffer gl.ARRAY_BUFFER, vertexPositionBuffer
  vertices =
    [
      -1, -1, -1, 1,
      -1, 1, -1, 1,
      -1, 1, 1, 1,
      -1, -1, 1, 1,
      -1, -1, -1, -1,
      -1, -1, 1, -1,
      -1, 1, 1, -1,
      -1, 1, -1, -1,
      -1, -1, 1, -1,
      -1, -1, 1, 1,
      -1, 1, 1, 1,
      -1, 1, 1, -1,
      -1, -1, -1, -1,
      -1, 1, -1, -1,
      -1, 1, -1, 1,
      -1, -1, -1, 1,
      -1, 1, -1, -1,
      -1, 1, 1, -1,
      -1, 1, 1, 1,
      -1, 1, -1, 1,
      -1, -1, -1, -1,
      -1, -1, -1, 1,
      -1, -1, 1, 1,
      -1, -1, 1, -1,
      -1, -1, -1, 1,
      1, -1, -1, 1,
      1, -1, 1, 1,
      -1, -1, 1, 1,
      -1, -1, -1, -1,
      -1, -1, 1, -1,
      1, -1, 1, -1,
      1, -1, -1, -1,
      -1, -1, 1, -1,
      -1, -1, 1, 1,
      1, -1, 1, 1,
      1, -1, 1, -1,
      -1, -1, -1, -1,
      1, -1, -1, -1,
      1, -1, -1, 1,
      -1, -1, -1, 1,
      1, -1, -1, -1,
      1, -1, 1, -1,
      1, -1, 1, 1,
      1, -1, -1, 1,
      -1, -1, -1, -1,
      -1, -1, -1, 1,
      -1, -1, 1, 1,
      -1, -1, 1, -1,
      -1, -1, -1, 1,
      1, -1, -1, 1,
      1, 1, -1, 1,
      -1, 1, -1, 1,
      -1, -1, -1, -1,
      -1, 1, -1, -1,
      1, 1, -1, -1,
      1, -1, -1, -1,
      -1, 1, -1, -1,
      -1, 1, -1, 1,
      1, 1, -1, 1,
      1, 1, -1, -1,
      -1, -1, -1, -1,
      1, -1, -1, -1,
      1, -1, -1, 1,
      -1, -1, -1, 1,
      1, -1, -1, -1,
      1, 1, -1, -1,
      1, 1, -1, 1,
      1, -1, -1, 1,
      -1, -1, -1, -1,
      -1, -1, -1, 1,
      -1, 1, -1, 1,
      -1, 1, -1, -1,
      -1, -1, 1, -1,
      1, -1, 1, -1,
      1, 1, 1, -1,
      -1, 1, 1, -1,
      -1, -1, -1, -1,
      -1, 1, -1, -1,
      1, 1, -1, -1,
      1, -1, -1, -1,
      -1, 1, -1, -1,
      -1, 1, 1, -1,
      1, 1, 1, -1,
      1, 1, -1, -1,
      -1, -1, -1, -1,
      1, -1, -1, -1,
      1, -1, 1, -1,
      -1, -1, 1, -1,
      1, -1, -1, -1,
      1, 1, -1, -1,
      1, 1, 1, -1,
      1, -1, 1, -1,
      -1, -1, -1, -1,
      -1, -1, 1, -1,
      -1, 1, 1, -1,
      -1, 1, -1, -1,
      1, -1, -1, 1,
      1, 1, -1, 1,
      1, 1, 1, 1,
      1, -1, 1, 1,
      1, -1, -1, -1,
      1, -1, 1, -1,
      1, 1, 1, -1,
      1, 1, -1, -1,
      1, -1, 1, -1,
      1, -1, 1, 1,
      1, 1, 1, 1,
      1, 1, 1, -1,
      1, -1, -1, -1,
      1, 1, -1, -1,
      1, 1, -1, 1,
      1, -1, -1, 1,
      1, 1, -1, -1,
      1, 1, 1, -1,
      1, 1, 1, 1,
      1, 1, -1, 1,
      1, -1, -1, -1,
      1, -1, -1, 1,
      1, -1, 1, 1,
      1, -1, 1, -1,
      -1, 1, -1, 1,
      1, 1, -1, 1,
      1, 1, 1, 1,
      -1, 1, 1, 1,
      -1, 1, -1, -1,
      -1, 1, 1, -1,
      1, 1, 1, -1,
      1, 1, -1, -1,
      -1, 1, 1, -1,
      -1, 1, 1, 1,
      1, 1, 1, 1,
      1, 1, 1, -1,
      -1, 1, -1, -1,
      1, 1, -1, -1,
      1, 1, -1, 1,
      -1, 1, -1, 1,
      1, 1, -1, -1,
      1, 1, 1, -1,
      1, 1, 1, 1,
      1, 1, -1, 1,
      -1, 1, -1, -1,
      -1, 1, -1, 1,
      -1, 1, 1, 1,
      -1, 1, 1, -1,
      -1, -1, 1, 1,
      1, -1, 1, 1,
      1, 1, 1, 1,
      -1, 1, 1, 1,
      -1, -1, 1, -1,
      -1, 1, 1, -1,
      1, 1, 1, -1,
      1, -1, 1, -1,
      -1, 1, 1, -1,
      -1, 1, 1, 1,
      1, 1, 1, 1,
      1, 1, 1, -1,
      -1, -1, 1, -1,
      1, -1, 1, -1,
      1, -1, 1, 1,
      -1, -1, 1, 1,
      1, -1, 1, -1,
      1, 1, 1, -1,
      1, 1, 1, 1,
      1, -1, 1, 1,
      -1, -1, 1, -1,
      -1, -1, 1, 1,
      -1, 1, 1, 1,
      -1, 1, 1, -1,
      -1, -1, 1, 1,
      1, -1, 1, 1,
      1, 1, 1, 1,
      -1, 1, 1, 1,
      -1, -1, -1, 1,
      -1, 1, -1, 1,
      1, 1, -1, 1,
      1, -1, -1, 1,
      -1, 1, -1, 1,
      -1, 1, 1, 1,
      1, 1, 1, 1,
      1, 1, -1, 1,
      -1, -1, -1, 1,
      1, -1, -1, 1,
      1, -1, 1, 1,
      -1, -1, 1, 1,
      1, -1, -1, 1,
      1, 1, -1, 1,
      1, 1, 1, 1,
      1, -1, 1, 1,
      -1, -1, -1, 1,
      -1, -1, 1, 1,
      -1, 1, 1, 1,
      -1, 1, -1, 1
    ]
  gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
  vertexPositionBuffer.itemSize = 4
  vertexPositionBuffer.numItems = 192

  # triangle vertex colors
  vertexColorBuffer = gl.createBuffer()
  gl.bindBuffer gl.ARRAY_BUFFER, vertexColorBuffer
  unpackedColors =
    [
      0.6682, 0.5, 0.125, 0.5,
      0.6682, 0.5, 0.125, 0.5,
      0.6682, 0.5, 0.125, 0.5,
      0.6682, 0.5, 0.125, 0.5,
      0.6682, 1.0, 0.125, 0.5,
      0.6682, 1.0, 0.125, 0.5,
      0.6682, 1.0, 0.125, 0.5,
      0.6682, 1.0, 0.125, 0.5,
      0.1682, 1.0, 0.125, 0.5,
      0.1682, 1.0, 0.125, 0.5,
      0.1682, 1.0, 0.125, 0.5,
      0.1682, 1.0, 0.125, 0.5,
      0.6682, 0.625, 0.25, 0.5,
      0.6682, 0.625, 0.25, 0.5,
      0.6682, 0.625, 0.25, 0.5,
      0.6682, 0.625, 0.25, 0.5,
      0.6682, 0.5, 0.625, 0.5,
      0.6682, 0.5, 0.625, 0.5,
      0.6682, 0.5, 0.625, 0.5,
      0.6682, 0.5, 0.625, 0.5,
      0.1682, 0.5, 0.625, 0.5,
      0.1682, 0.5, 0.625, 0.5,
      0.1682, 0.5, 0.625, 0.5,
      0.1682, 0.5, 0.625, 0.5,
      0.5072, 0.5, 0.405, 0.5,
      0.5072, 0.5, 0.405, 0.5,
      0.5072, 0.5, 0.405, 0.5,
      0.5072, 0.5, 0.405, 0.5,
      0.5072, 1.0, 0.405, 0.5,
      0.5072, 1.0, 0.405, 0.5,
      0.5072, 1.0, 0.405, 0.5,
      0.5072, 1.0, 0.405, 0.5,
      0.0072, 1.0, 0.405, 0.5,
      0.0072, 1.0, 0.405, 0.5,
      0.0072, 1.0, 0.405, 0.5,
      0.0072, 1.0, 0.405, 0.5,
      0.5072, 0.625, 0.53, 0.5,
      0.5072, 0.625, 0.53, 0.5,
      0.5072, 0.625, 0.53, 0.5,
      0.5072, 0.625, 0.53, 0.5,
      0.5072, 0.5, 0.905, 0.5,
      0.5072, 0.5, 0.905, 0.5,
      0.5072, 0.5, 0.905, 0.5,
      0.5072, 0.5, 0.905, 0.5,
      0.0072, 0.5, 0.905, 0.5,
      0.0072, 0.5, 0.905, 0.5,
      0.0072, 0.5, 0.905, 0.5,
      0.0072, 0.5, 0.905, 0.5,
      0.5, 0.5, 0.28125, 0.5,
      0.5, 0.5, 0.28125, 0.5,
      0.5, 0.5, 0.28125, 0.5,
      0.5, 0.5, 0.28125, 0.5,
      0.5, 1.0, 0.28125, 0.5,
      0.5, 1.0, 0.28125, 0.5,
      0.5, 1.0, 0.28125, 0.5,
      0.5, 1.0, 0.28125, 0.5,
      0.0, 1.0, 0.28125, 0.5,
      0.0, 1.0, 0.28125, 0.5,
      0.0, 1.0, 0.28125, 0.5,
      0.0, 1.0, 0.28125, 0.5,
      0.5, 0.625, 0.40625, 0.5,
      0.5, 0.625, 0.40625, 0.5,
      0.5, 0.625, 0.40625, 0.5,
      0.5, 0.625, 0.40625, 0.5,
      0.5, 0.5, 0.78125, 0.5,
      0.5, 0.5, 0.78125, 0.5,
      0.5, 0.5, 0.78125, 0.5,
      0.5, 0.5, 0.78125, 0.5,
      0.0, 0.5, 0.78125, 0.5,
      0.0, 0.5, 0.78125, 0.5,
      0.0, 0.5, 0.78125, 0.5,
      0.0, 0.5, 0.78125, 0.5,
      0.625, 0.5, 0.18, 0.5,
      0.625, 0.5, 0.18, 0.5,
      0.625, 0.5, 0.18, 0.5,
      0.625, 0.5, 0.18, 0.5,
      0.625, 1.0, 0.18, 0.5,
      0.625, 1.0, 0.18, 0.5,
      0.625, 1.0, 0.18, 0.5,
      0.625, 1.0, 0.18, 0.5,
      0.125, 1.0, 0.18, 0.5,
      0.125, 1.0, 0.18, 0.5,
      0.125, 1.0, 0.18, 0.5,
      0.125, 1.0, 0.18, 0.5,
      0.625, 0.625, 0.305, 0.5,
      0.625, 0.625, 0.305, 0.5,
      0.625, 0.625, 0.305, 0.5,
      0.625, 0.625, 0.305, 0.5,
      0.625, 0.5, 0.68, 0.5,
      0.625, 0.5, 0.68, 0.5,
      0.625, 0.5, 0.68, 0.5,
      0.625, 0.5, 0.68, 0.5,
      0.125, 0.5, 0.68, 0.5,
      0.125, 0.5, 0.68, 0.5,
      0.125, 0.5, 0.68, 0.5,
      0.125, 0.5, 0.68, 0.5,
      0.72445, 0.125, 0.245, 0.5,
      0.72445, 0.125, 0.245, 0.5,
      0.72445, 0.125, 0.245, 0.5,
      0.72445, 0.125, 0.245, 0.5,
      0.72445, 0.625, 0.245, 0.5,
      0.72445, 0.625, 0.245, 0.5,
      0.72445, 0.625, 0.245, 0.5,
      0.72445, 0.625, 0.245, 0.5,
      0.22445, 0.625, 0.245, 0.5,
      0.22445, 0.625, 0.245, 0.5,
      0.22445, 0.625, 0.245, 0.5,
      0.22445, 0.625, 0.245, 0.5,
      0.72445, 0.25, 0.37, 0.5,
      0.72445, 0.25, 0.37, 0.5,
      0.72445, 0.25, 0.37, 0.5,
      0.72445, 0.25, 0.37, 0.5,
      0.72445, 0.125, 0.745, 0.5,
      0.72445, 0.125, 0.745, 0.5,
      0.72445, 0.125, 0.745, 0.5,
      0.72445, 0.125, 0.745, 0.5,
      0.22445, 0.125, 0.745, 0.5,
      0.22445, 0.125, 0.745, 0.5,
      0.22445, 0.125, 0.745, 0.5,
      0.22445, 0.125, 0.745, 0.5,
      0.51445, 0.5, 0.18, 0.5,
      0.51445, 0.5, 0.18, 0.5,
      0.51445, 0.5, 0.18, 0.5,
      0.51445, 0.5, 0.18, 0.5,
      0.51445, 1.0, 0.18, 0.5,
      0.51445, 1.0, 0.18, 0.5,
      0.51445, 1.0, 0.18, 0.5,
      0.51445, 1.0, 0.18, 0.5,
      0.01445, 1.0, 0.18, 0.5,
      0.01445, 1.0, 0.18, 0.5,
      0.01445, 1.0, 0.18, 0.5,
      0.01445, 1.0, 0.18, 0.5,
      0.51445, 0.625, 0.305, 0.5,
      0.51445, 0.625, 0.305, 0.5,
      0.51445, 0.625, 0.305, 0.5,
      0.51445, 0.625, 0.305, 0.5,
      0.51445, 0.5, 0.68, 0.5,
      0.51445, 0.5, 0.68, 0.5,
      0.51445, 0.5, 0.68, 0.5,
      0.51445, 0.5, 0.68, 0.5,
      0.01445, 0.5, 0.68, 0.5,
      0.01445, 0.5, 0.68, 0.5,
      0.01445, 0.5, 0.68, 0.5,
      0.01445, 0.5, 0.68, 0.5,
      0.905, 0.5, 0.28125, 0.5,
      0.905, 0.5, 0.28125, 0.5,
      0.905, 0.5, 0.28125, 0.5,
      0.905, 0.5, 0.28125, 0.5,
      0.905, 1.0, 0.28125, 0.5,
      0.905, 1.0, 0.28125, 0.5,
      0.905, 1.0, 0.28125, 0.5,
      0.905, 1.0, 0.28125, 0.5,
      0.405, 1.0, 0.28125, 0.5,
      0.405, 1.0, 0.28125, 0.5,
      0.405, 1.0, 0.28125, 0.5,
      0.405, 1.0, 0.28125, 0.5,
      0.905, 0.625, 0.40625, 0.5,
      0.905, 0.625, 0.40625, 0.5,
      0.905, 0.625, 0.40625, 0.5,
      0.905, 0.625, 0.40625, 0.5,
      0.905, 0.5, 0.78125, 0.5,
      0.905, 0.5, 0.78125, 0.5,
      0.905, 0.5, 0.78125, 0.5,
      0.905, 0.5, 0.78125, 0.5,
      0.405, 0.5, 0.78125, 0.5,
      0.405, 0.5, 0.78125, 0.5,
      0.405, 0.5, 0.78125, 0.5,
      0.405, 0.5, 0.78125, 0.5,
      0.50605, 0.245, 0.28125, 0.5,
      0.50605, 0.245, 0.28125, 0.5,
      0.50605, 0.245, 0.28125, 0.5,
      0.50605, 0.245, 0.28125, 0.5,
      0.50605, 0.745, 0.28125, 0.5,
      0.50605, 0.745, 0.28125, 0.5,
      0.50605, 0.745, 0.28125, 0.5,
      0.50605, 0.745, 0.28125, 0.5,
      0.00605, 0.745, 0.28125, 0.5,
      0.00605, 0.745, 0.28125, 0.5,
      0.00605, 0.745, 0.28125, 0.5,
      0.00605, 0.745, 0.28125, 0.5,
      0.50605, 0.37, 0.40625, 0.5,
      0.50605, 0.37, 0.40625, 0.5,
      0.50605, 0.37, 0.40625, 0.5,
      0.50605, 0.37, 0.40625, 0.5,
      0.50605, 0.245, 0.78125, 0.5,
      0.50605, 0.245, 0.78125, 0.5,
      0.50605, 0.245, 0.78125, 0.5,
      0.50605, 0.245, 0.78125, 0.5,
      0.00605, 0.245, 0.78125, 0.5,
      0.00605, 0.245, 0.78125, 0.5,
      0.00605, 0.245, 0.78125, 0.5,
      0.00605, 0.245, 0.78125, 0.5
    ]

  gl.bufferData gl.ARRAY_BUFFER, new Float32Array(unpackedColors), gl.STATIC_DRAW
  vertexColorBuffer.itemSize = 4
  vertexColorBuffer.numItems = 192

  # vertex normals
  vertexNormalBuffer = gl.createBuffer()
  gl.bindBuffer gl.ARRAY_BUFFER, vertexNormalBuffer
  normals =
    [
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      0, 0, 0, -1,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1,
      0, 0, 0, 1
    ]
  gl.bufferData gl.ARRAY_BUFFER, new Float32Array(normals), gl.STATIC_DRAW
  vertexNormalBuffer.itemSize = 4
  vertexNormalBuffer.numItems = 192

  # indices for triangles
  vertexIndexBuffer = gl.createBuffer()
  gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, vertexIndexBuffer
  vertexIndices =
    [
      0, 1, 2, 0, 2, 3, 4, 5, 6, 4, 6, 7, 8, 9, 10, 8, 10, 11, 12, 13, 14, 12, 14, 15, 16, 17, 18, 16, 18, 19, 20, 21,
      22, 20, 22, 23, 24, 25, 26, 24, 26, 27, 28, 29, 30, 28, 30, 31, 32, 33, 34, 32, 34, 35, 36, 37, 38, 36, 38, 39,
      40, 41, 42, 40, 42, 43, 44, 45, 46, 44, 46, 47, 48, 49, 50, 48, 50, 51, 52, 53, 54, 52, 54, 55, 56, 57, 58, 56,
      58, 59, 60, 61, 62, 60, 62, 63, 64, 65, 66, 64, 66, 67, 68, 69, 70, 68, 70, 71, 72, 73, 74, 72, 74, 75, 76, 77,
      78, 76, 78, 79, 80, 81, 82, 80, 82, 83, 84, 85, 86, 84, 86, 87, 88, 89, 90, 88, 90, 91, 92, 93, 94, 92, 94, 95,
      96, 97, 98, 96, 98, 99, 100, 101, 102, 100, 102, 103, 104, 105, 106, 104, 106, 107, 108, 109, 110, 108, 110, 111,
      112, 113, 114, 112, 114, 115, 116, 117, 118, 116, 118, 119, 120, 121, 122, 120, 122, 123, 124, 125, 126, 124, 126,
      127, 128, 129, 130, 128, 130, 131, 132, 133, 134, 132, 134, 135, 136, 137, 138, 136, 138, 139, 140, 141, 142, 140,
      142, 143, 144, 145, 146, 144, 146, 147, 148, 149, 150, 148, 150, 151, 152, 153, 154, 152, 154, 155, 156, 157, 158,
      156, 158, 159, 160, 161, 162, 160, 162, 163, 164, 165, 166, 164, 166, 167, 168, 169, 170, 168, 170, 171, 172, 173,
      174, 172, 174, 175, 176, 177, 178, 176, 178, 179, 180, 181, 182, 180, 182, 183, 184, 185, 186, 184, 186, 187, 188,
      189, 190, 188, 190, 191
    ]
  gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(vertexIndices), gl.STATIC_DRAW
  vertexIndexBuffer.itemSize = 1
  vertexIndexBuffer.numItems = 288

# TODO: do square stuff here!

drawTesseract = (x, y, z, w) ->
  vec4.set tVector, x, y, z, w

  # setup positions
  gl.bindBuffer gl.ARRAY_BUFFER, vertexPositionBuffer
  gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute,
      vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)

  # setup colors
  gl.bindBuffer gl.ARRAY_BUFFER, vertexColorBuffer
  gl.vertexAttribPointer(shaderProgram.vertexColorAttribute,
      vertexColorBuffer.itemSize, gl.FLOAT, false, 0, 0)

  # setup normals
  gl.bindBuffer gl.ARRAY_BUFFER, vertexNormalBuffer
  gl.vertexAttribPointer(shaderProgram.vertexNormalAttribute,
      vertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0)

  # setup triangle index
  gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, vertexIndexBuffer
  setMatrixUniforms()
  gl.drawElements gl.TRIANGLES, vertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0

drawScene = (px, py, pz, pw) ->
# get scene ready
  gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
  gl.clear (gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
  mat4.perspective pMatrix, 45, gl.viewportWidth / gl.viewportHeight, 0.001, 100.0
  mat4.identity mvMatrix
  #mat4.translate mvMatrix, mvMatrix, (new Float32Array([0, 0, 0]))
  #mat4.rotate(mvMatrix, mvMatrix, 1.0, new Float32Array([1, 1, 1]))

  vec4.set pVector, px, py, pz, pw
  vec4.set lightDirectionVector, 1, 1, 1, 1
  vec4.normalize(lightDirectionVector, lightDirectionVector)

  d = 4
  for x in [-1..1]
    for y in [-1..1]
      for z in [-1..1]
        for w in [-1..1]
          if not (x == 0 and y == 0 and z == 0 and w == 0)
            drawTesseract(d * x, d * y, d * z, d * w)

center = {x: 0.0, y: 0.0}
mouseDragging = false
dragStart = {x: 0, y: 0}
dragCurrent = {x: 0, y: 0}
currentDirection =
  forward: 0
  right: 0

moveSpeed = 0.005
px = 0
py = 0
pz = 15
pw = 0

rotationSpeed = Math.PI
window.rotateMode =
  x: 1
  y: 3

stepRotationMode = (dir) ->
  center = {x: 0.0, y: 0.0}
  switch dir
    when 0 then rotateMode.x = (rotateMode.x + 1) % 6
    when 1 then rotateMode.y = (rotateMode.y + 1) % 6
  console.log("rotation mode: #{rotateMode}")

modalRotate = (x0, y0) ->
  x = rotationSpeed * x0
  y = rotationSpeed * y0
  switch rotateMode.x
    when 0 then r1Float = x
    when 1 then r2Float = x
    when 2 then r3Float = x
    when 3 then r4Float = x
    when 4 then r5Float = x
    when 5 then r6Float = x
  switch rotateMode.y
    when 0 then r1Float = y
    when 1 then r2Float = y
    when 2 then r3Float = y
    when 3 then r4Float = y
    when 4 then r5Float = y
    when 5 then r6Float = y

window.auto = false

lastTime = 0
animate = ->
  timeNow = (new Date).getTime()
  if lastTime != 0
    elapsed = timeNow - lastTime
    pz += currentDirection.forward * moveSpeed * elapsed
    px -= currentDirection.right * moveSpeed * elapsed
    if auto
      r1Float += 1.0 * elapsed * rotationSpeed / 50000
      r2Float += 2.0 * elapsed * rotationSpeed / 50000
      r3Float += 3.0 * elapsed * rotationSpeed / 50000
      r4Float += 4.0 * elapsed * rotationSpeed / 50000
      r5Float += 5.0 * elapsed * rotationSpeed / 50000
      r6Float += 6.0 * elapsed * rotationSpeed / 50000
  lastTime = timeNow

tick = ->
  requestAnimFrame tick
  drawScene(px, py, pz, pw)
  animate()
# console.log(rFloat)

window.testing = ->
  canvas = document.getElementById 'canvas'
  getMousePos = (event) =>
    rect = canvas.getBoundingClientRect()
    x: event.clientX - rect.left
    y: event.clientY - rect.top

  canvas.addEventListener "mousedown", (e) =>
    dragStart = dragCurrent = getMousePos(e)
    mouseDragging = true

  canvas.addEventListener "mousemove", (e) =>
    if mouseDragging
      dragCurrent = getMousePos(e)
      turnRight = (dragStart.x - dragCurrent.x) / canvas.width
      turnUp = (dragStart.y - dragCurrent.y) / canvas.height
      modalRotate(center.x + turnRight, center.y + turnUp)
  #      r3Float = center.x + turnRight
  #      r4Float = center.y + turnUp

  canvas.addEventListener "mouseup", (e) =>
    mouseDragging = false
    center.x = center.x + (dragStart.x - dragCurrent.x) / canvas.width
    center.y = center.y + (dragStart.y - dragCurrent.y) / canvas.height
    dragStart = dragCurrent = {x: 0.0, y: 0.0}
    console.log(r1Float, r2Float)

  handleKeyPress = (event) ->
    code = event.keyCode
    console.log(code)
    switch code
      when 87 then currentDirection.forward = 1
      when 65 then currentDirection.right = -1
      when 68 then currentDirection.right = 1
      when 83 then currentDirection.forward = -1

      when 81 then stepRotationMode(0)
      when 69 then stepRotationMode(1)

  handleKeyRelease = (event) ->
    code = event.keyCode
    switch code
      when 87 then currentDirection.forward = 0
      when 65 then currentDirection.right = 0
      when 68 then currentDirection.right = 0
      when 83 then currentDirection.forward = 0
    console.log("position: (#{px}, #{py}, #{pz}, #{pw})")

  window.addEventListener "keydown", handleKeyPress, false

  window.addEventListener "keyup", handleKeyRelease, false

  initGL canvas
  loadShader 'fragment.glsl', 'frag'
  loadShader 'vertex.glsl', 'vert'

  waitForShaders = (continuation) ->
    console.log "fragment shader: #{shaders.fragReady}"
    console.log "vertex shader: #{shaders.vertReady}"
    if not (shaders.fragReady and shaders.vertReady)
      setTimeout (-> waitForShaders continuation), 10
    else
      continuation()

  finishGLInit = ->
    initShaders()
    initBuffers()
    gl.clearColor 0, 0, 0, 1 # default background color: black
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
    gl.enable(gl.BLEND)
    gl.disable(gl.DEPTH_TEST)
    gl.enable(gl.DEPTH_TEST)
    tick()

  waitForShaders finishGLInit
