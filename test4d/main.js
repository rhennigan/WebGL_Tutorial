// Generated by CoffeeScript 1.9.1
(function() {
  var animate, center, currentDirection, dragCurrent, dragStart, drawScene, drawTesseract, gl, initBuffers, initGL, initShaders, lastTime, lightDirectionVector, loadShader, meshBool, modalRotate, mouseDragging, moveSpeed, mvMatrix, pMatrix, pVector, pw, px, py, pz, r1Float, r2Float, r3Float, r4Float, r5Float, r6Float, randAngle, rotationSpeed, setMatrixUniforms, shaderProgram, shaders, stepRotationMode, tVector, tick, vertexColorBuffer, vertexIndexBuffer, vertexLineIndexBuffer, vertexLinePositionBuffer, vertexNormalBuffer, vertexPositionBuffer;

  gl = void 0;

  shaders = {
    fragReady: false,
    vertReady: false,
    frag: void 0,
    vert: void 0
  };

  shaderProgram = void 0;

  mvMatrix = mat4.create();

  pMatrix = mat4.create();

  tVector = vec4.create();

  pVector = vec4.create();

  lightDirectionVector = vec4.create();

  randAngle = function() {
    return 2.0 * Math.PI * Math.random();
  };

  r1Float = randAngle();

  r2Float = randAngle();

  r3Float = randAngle();

  r4Float = randAngle();

  r5Float = randAngle();

  r6Float = randAngle();

  vertexPositionBuffer = void 0;

  vertexColorBuffer = void 0;

  vertexNormalBuffer = void 0;

  vertexIndexBuffer = void 0;

  vertexLinePositionBuffer = void 0;

  vertexLineIndexBuffer = void 0;

  meshBool = true;

  initGL = function(canvas) {
    var e;
    try {
      gl = canvas.getContext("experimental-webgl");
      gl.viewportWidth = canvas.width;
      gl.viewportHeight = canvas.height;
    } catch (_error) {
      e = _error;
      alert("initGL error: " + e);
    }
    if (!gl) {
      return alert("Could not initialize WebGL");
    }
  };

  loadShader = function(path, type) {
    var request;
    request = new XMLHttpRequest();
    request.open('GET', path, true);
    request.onreadystatechange = function() {
      var sourceString;
      if (request.readyState === 4 && request.status === 200) {
        sourceString = request.responseText;
        if (type === 'frag') {
          shaders.frag = gl.createShader(gl.FRAGMENT_SHADER);
          gl.shaderSource(shaders.frag, sourceString);
          gl.compileShader(shaders.frag);
          return shaders.fragReady = true;
        } else if (type === 'vert') {
          shaders.vert = gl.createShader(gl.VERTEX_SHADER);
          gl.shaderSource(shaders.vert, sourceString);
          gl.compileShader(shaders.vert);
          return shaders.vertReady = true;
        } else {
          return alert("unknown shader type: " + type);
        }
      }
    };
    return request.send();
  };

  initShaders = function() {
    if (!shaders.fragReady) {
      return alert("fragment shader script is not loaded");
    } else if (!shaders.vertReady) {
      return alert("vertex shader script is not loaded");
    } else {
      shaderProgram = gl.createProgram();
      gl.attachShader(shaderProgram, shaders.vert);
      gl.attachShader(shaderProgram, shaders.frag);
      gl.linkProgram(shaderProgram);
      if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
        console.log(shaders);
        return alert("failed to initialize shaders");
      } else {
        gl.useProgram(shaderProgram);
        shaderProgram.vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition");
        shaderProgram.vertexColorAttribute = gl.getAttribLocation(shaderProgram, "aVertexColor");
        shaderProgram.vertexNormalAttribute = gl.getAttribLocation(shaderProgram, "aVertexNormal");
        gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute);
        gl.enableVertexAttribArray(shaderProgram.vertexColorAttribute);
        gl.enableVertexAttribArray(shaderProgram.vertexNormalAttribute);
        shaderProgram.pMatrixUniform = gl.getUniformLocation(shaderProgram, "uPMatrix");
        shaderProgram.mvMatrixUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix");
        shaderProgram.tVectorUniform = gl.getUniformLocation(shaderProgram, "uTVector");
        shaderProgram.pVectorUniform = gl.getUniformLocation(shaderProgram, "uPVector");
        shaderProgram.lightDirectionUniform = gl.getUniformLocation(shaderProgram, "uLightDirection");
        shaderProgram.r1FloatUniform = gl.getUniformLocation(shaderProgram, "uR1Float");
        shaderProgram.r2FloatUniform = gl.getUniformLocation(shaderProgram, "uR2Float");
        shaderProgram.r3FloatUniform = gl.getUniformLocation(shaderProgram, "uR3Float");
        shaderProgram.r4FloatUniform = gl.getUniformLocation(shaderProgram, "uR4Float");
        shaderProgram.r5FloatUniform = gl.getUniformLocation(shaderProgram, "uR5Float");
        shaderProgram.r6FloatUniform = gl.getUniformLocation(shaderProgram, "uR6Float");
        return shaderProgram.meshBoolUniform = gl.getUniformLocation(shaderProgram, "uMeshBool");
      }
    }
  };

  setMatrixUniforms = function() {
    gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix);
    gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix);
    gl.uniform4fv(shaderProgram.tVectorUniform, tVector);
    gl.uniform4fv(shaderProgram.pVectorUniform, pVector);
    gl.uniform4fv(shaderProgram.lightDirectionUniform, lightDirectionVector);
    gl.uniform1f(shaderProgram.r1FloatUniform, r1Float);
    gl.uniform1f(shaderProgram.r2FloatUniform, r2Float);
    gl.uniform1f(shaderProgram.r3FloatUniform, r3Float);
    gl.uniform1f(shaderProgram.r4FloatUniform, r4Float);
    gl.uniform1f(shaderProgram.r5FloatUniform, r5Float);
    gl.uniform1f(shaderProgram.r6FloatUniform, r6Float);
    return gl.uniform1i(shaderProgram.meshBoolUniform, meshBool);
  };

  initBuffers = function() {
    var lineVertices, normals, unpackedColors, vertexIndices, vertexLineIndices, vertices;
    vertexPositionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer);
    vertices = [-1, -1, -1, 1, -1, 1, -1, 1, -1, 1, 1, 1, -1, -1, 1, 1, -1, -1, -1, -1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, -1, -1, -1, 1, -1, 1, -1, -1, -1, 1, 1, -1, -1, 1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, -1, 1, 1, -1, -1, 1, 1, -1, 1, 1, -1, -1, 1, 1, -1, -1, -1, -1, -1, -1, 1, -1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, 1, 1, -1, 1, 1, 1, -1, 1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1, 1, 1, -1, -1, -1, 1, -1, 1, -1, 1, -1, 1, 1, 1, -1, -1, 1, -1, -1, -1, -1, -1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, -1, 1, 1, -1, -1, 1, 1, 1, -1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, 1, -1, 1, 1, 1, -1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1, 1, 1, -1, -1, -1, 1, 1, -1, -1, 1, 1, -1, 1, 1, -1, -1, 1, -1, -1, -1, -1, -1, -1, -1, 1, -1, 1, -1, 1, -1, 1, -1, -1, -1, -1, 1, -1, 1, -1, 1, -1, 1, 1, 1, -1, -1, 1, 1, -1, -1, -1, -1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, -1, -1, -1, 1, -1, 1, -1, -1, -1, 1, 1, -1, -1, 1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, 1, -1, -1, 1, 1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, 1, 1, -1, -1, -1, 1, -1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -1, 1, -1, -1, -1, 1, 1, -1, -1, 1, 1, -1, 1, 1, -1, -1, 1, 1, 1, -1, -1, 1, 1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, 1, -1, -1, -1, 1, -1, -1, 1, 1, -1, 1, 1, 1, -1, 1, -1, -1, 1, -1, 1, 1, 1, -1, 1, 1, 1, 1, 1, -1, 1, 1, 1, -1, 1, -1, -1, -1, 1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, -1, 1, 1, -1, -1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, -1, 1, 1, 1, -1, -1, 1, 1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, -1, 1, -1, -1, -1, 1, -1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, -1, 1, 1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, 1, 1, -1, -1, 1, -1, -1, 1, 1, -1, 1, 1, 1, -1, 1, -1, 1, -1, -1, 1, 1, -1, -1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -1, -1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, 1, -1, -1, 1, 1, 1, -1, 1, -1, 1, 1, 1, -1, 1, 1, 1, 1, 1, -1, 1, 1, -1, -1, 1, -1, -1, -1, 1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, -1, 1, 1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, 1, 1, -1, -1, -1, 1, -1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -1, 1, -1, -1, -1, 1, 1, -1, -1, 1, 1, -1, 1, 1, -1, -1, 1, 1, 1, -1, -1, 1, 1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, 1, -1, -1, -1, 1, -1, -1, 1, 1, -1, 1, 1, 1, -1, 1, -1, 1];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
    vertexPositionBuffer.itemSize = 4;
    vertexPositionBuffer.numItems = 192;
    vertexColorBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorBuffer);
    unpackedColors = [0.6682, 0.5, 0.125, 0.5, 0.6682, 0.5, 0.125, 0.5, 0.6682, 0.5, 0.125, 0.5, 0.6682, 0.5, 0.125, 0.5, 0.6682, 1.0, 0.125, 0.5, 0.6682, 1.0, 0.125, 0.5, 0.6682, 1.0, 0.125, 0.5, 0.6682, 1.0, 0.125, 0.5, 0.1682, 1.0, 0.125, 0.5, 0.1682, 1.0, 0.125, 0.5, 0.1682, 1.0, 0.125, 0.5, 0.1682, 1.0, 0.125, 0.5, 0.6682, 0.625, 0.25, 0.5, 0.6682, 0.625, 0.25, 0.5, 0.6682, 0.625, 0.25, 0.5, 0.6682, 0.625, 0.25, 0.5, 0.6682, 0.5, 0.625, 0.5, 0.6682, 0.5, 0.625, 0.5, 0.6682, 0.5, 0.625, 0.5, 0.6682, 0.5, 0.625, 0.5, 0.1682, 0.5, 0.625, 0.5, 0.1682, 0.5, 0.625, 0.5, 0.1682, 0.5, 0.625, 0.5, 0.1682, 0.5, 0.625, 0.5, 0.5072, 0.5, 0.405, 0.5, 0.5072, 0.5, 0.405, 0.5, 0.5072, 0.5, 0.405, 0.5, 0.5072, 0.5, 0.405, 0.5, 0.5072, 1.0, 0.405, 0.5, 0.5072, 1.0, 0.405, 0.5, 0.5072, 1.0, 0.405, 0.5, 0.5072, 1.0, 0.405, 0.5, 0.0072, 1.0, 0.405, 0.5, 0.0072, 1.0, 0.405, 0.5, 0.0072, 1.0, 0.405, 0.5, 0.0072, 1.0, 0.405, 0.5, 0.5072, 0.625, 0.53, 0.5, 0.5072, 0.625, 0.53, 0.5, 0.5072, 0.625, 0.53, 0.5, 0.5072, 0.625, 0.53, 0.5, 0.5072, 0.5, 0.905, 0.5, 0.5072, 0.5, 0.905, 0.5, 0.5072, 0.5, 0.905, 0.5, 0.5072, 0.5, 0.905, 0.5, 0.0072, 0.5, 0.905, 0.5, 0.0072, 0.5, 0.905, 0.5, 0.0072, 0.5, 0.905, 0.5, 0.0072, 0.5, 0.905, 0.5, 0.5, 0.5, 0.28125, 0.5, 0.5, 0.5, 0.28125, 0.5, 0.5, 0.5, 0.28125, 0.5, 0.5, 0.5, 0.28125, 0.5, 0.5, 1.0, 0.28125, 0.5, 0.5, 1.0, 0.28125, 0.5, 0.5, 1.0, 0.28125, 0.5, 0.5, 1.0, 0.28125, 0.5, 0.0, 1.0, 0.28125, 0.5, 0.0, 1.0, 0.28125, 0.5, 0.0, 1.0, 0.28125, 0.5, 0.0, 1.0, 0.28125, 0.5, 0.5, 0.625, 0.40625, 0.5, 0.5, 0.625, 0.40625, 0.5, 0.5, 0.625, 0.40625, 0.5, 0.5, 0.625, 0.40625, 0.5, 0.5, 0.5, 0.78125, 0.5, 0.5, 0.5, 0.78125, 0.5, 0.5, 0.5, 0.78125, 0.5, 0.5, 0.5, 0.78125, 0.5, 0.0, 0.5, 0.78125, 0.5, 0.0, 0.5, 0.78125, 0.5, 0.0, 0.5, 0.78125, 0.5, 0.0, 0.5, 0.78125, 0.5, 0.625, 0.5, 0.18, 0.5, 0.625, 0.5, 0.18, 0.5, 0.625, 0.5, 0.18, 0.5, 0.625, 0.5, 0.18, 0.5, 0.625, 1.0, 0.18, 0.5, 0.625, 1.0, 0.18, 0.5, 0.625, 1.0, 0.18, 0.5, 0.625, 1.0, 0.18, 0.5, 0.125, 1.0, 0.18, 0.5, 0.125, 1.0, 0.18, 0.5, 0.125, 1.0, 0.18, 0.5, 0.125, 1.0, 0.18, 0.5, 0.625, 0.625, 0.305, 0.5, 0.625, 0.625, 0.305, 0.5, 0.625, 0.625, 0.305, 0.5, 0.625, 0.625, 0.305, 0.5, 0.625, 0.5, 0.68, 0.5, 0.625, 0.5, 0.68, 0.5, 0.625, 0.5, 0.68, 0.5, 0.625, 0.5, 0.68, 0.5, 0.125, 0.5, 0.68, 0.5, 0.125, 0.5, 0.68, 0.5, 0.125, 0.5, 0.68, 0.5, 0.125, 0.5, 0.68, 0.5, 0.72445, 0.125, 0.245, 0.5, 0.72445, 0.125, 0.245, 0.5, 0.72445, 0.125, 0.245, 0.5, 0.72445, 0.125, 0.245, 0.5, 0.72445, 0.625, 0.245, 0.5, 0.72445, 0.625, 0.245, 0.5, 0.72445, 0.625, 0.245, 0.5, 0.72445, 0.625, 0.245, 0.5, 0.22445, 0.625, 0.245, 0.5, 0.22445, 0.625, 0.245, 0.5, 0.22445, 0.625, 0.245, 0.5, 0.22445, 0.625, 0.245, 0.5, 0.72445, 0.25, 0.37, 0.5, 0.72445, 0.25, 0.37, 0.5, 0.72445, 0.25, 0.37, 0.5, 0.72445, 0.25, 0.37, 0.5, 0.72445, 0.125, 0.745, 0.5, 0.72445, 0.125, 0.745, 0.5, 0.72445, 0.125, 0.745, 0.5, 0.72445, 0.125, 0.745, 0.5, 0.22445, 0.125, 0.745, 0.5, 0.22445, 0.125, 0.745, 0.5, 0.22445, 0.125, 0.745, 0.5, 0.22445, 0.125, 0.745, 0.5, 0.51445, 0.5, 0.18, 0.5, 0.51445, 0.5, 0.18, 0.5, 0.51445, 0.5, 0.18, 0.5, 0.51445, 0.5, 0.18, 0.5, 0.51445, 1.0, 0.18, 0.5, 0.51445, 1.0, 0.18, 0.5, 0.51445, 1.0, 0.18, 0.5, 0.51445, 1.0, 0.18, 0.5, 0.01445, 1.0, 0.18, 0.5, 0.01445, 1.0, 0.18, 0.5, 0.01445, 1.0, 0.18, 0.5, 0.01445, 1.0, 0.18, 0.5, 0.51445, 0.625, 0.305, 0.5, 0.51445, 0.625, 0.305, 0.5, 0.51445, 0.625, 0.305, 0.5, 0.51445, 0.625, 0.305, 0.5, 0.51445, 0.5, 0.68, 0.5, 0.51445, 0.5, 0.68, 0.5, 0.51445, 0.5, 0.68, 0.5, 0.51445, 0.5, 0.68, 0.5, 0.01445, 0.5, 0.68, 0.5, 0.01445, 0.5, 0.68, 0.5, 0.01445, 0.5, 0.68, 0.5, 0.01445, 0.5, 0.68, 0.5, 0.905, 0.5, 0.28125, 0.5, 0.905, 0.5, 0.28125, 0.5, 0.905, 0.5, 0.28125, 0.5, 0.905, 0.5, 0.28125, 0.5, 0.905, 1.0, 0.28125, 0.5, 0.905, 1.0, 0.28125, 0.5, 0.905, 1.0, 0.28125, 0.5, 0.905, 1.0, 0.28125, 0.5, 0.405, 1.0, 0.28125, 0.5, 0.405, 1.0, 0.28125, 0.5, 0.405, 1.0, 0.28125, 0.5, 0.405, 1.0, 0.28125, 0.5, 0.905, 0.625, 0.40625, 0.5, 0.905, 0.625, 0.40625, 0.5, 0.905, 0.625, 0.40625, 0.5, 0.905, 0.625, 0.40625, 0.5, 0.905, 0.5, 0.78125, 0.5, 0.905, 0.5, 0.78125, 0.5, 0.905, 0.5, 0.78125, 0.5, 0.905, 0.5, 0.78125, 0.5, 0.405, 0.5, 0.78125, 0.5, 0.405, 0.5, 0.78125, 0.5, 0.405, 0.5, 0.78125, 0.5, 0.405, 0.5, 0.78125, 0.5, 0.50605, 0.245, 0.28125, 0.5, 0.50605, 0.245, 0.28125, 0.5, 0.50605, 0.245, 0.28125, 0.5, 0.50605, 0.245, 0.28125, 0.5, 0.50605, 0.745, 0.28125, 0.5, 0.50605, 0.745, 0.28125, 0.5, 0.50605, 0.745, 0.28125, 0.5, 0.50605, 0.745, 0.28125, 0.5, 0.00605, 0.745, 0.28125, 0.5, 0.00605, 0.745, 0.28125, 0.5, 0.00605, 0.745, 0.28125, 0.5, 0.00605, 0.745, 0.28125, 0.5, 0.50605, 0.37, 0.40625, 0.5, 0.50605, 0.37, 0.40625, 0.5, 0.50605, 0.37, 0.40625, 0.5, 0.50605, 0.37, 0.40625, 0.5, 0.50605, 0.245, 0.78125, 0.5, 0.50605, 0.245, 0.78125, 0.5, 0.50605, 0.245, 0.78125, 0.5, 0.50605, 0.245, 0.78125, 0.5, 0.00605, 0.245, 0.78125, 0.5, 0.00605, 0.245, 0.78125, 0.5, 0.00605, 0.245, 0.78125, 0.5, 0.00605, 0.245, 0.78125, 0.5];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(unpackedColors), gl.STATIC_DRAW);
    vertexColorBuffer.itemSize = 4;
    vertexColorBuffer.numItems = 192;
    vertexNormalBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexNormalBuffer);
    normals = [-1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(normals), gl.STATIC_DRAW);
    vertexNormalBuffer.itemSize = 4;
    vertexNormalBuffer.numItems = 192;
    vertexIndexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, vertexIndexBuffer);
    vertexIndices = [0, 1, 2, 0, 3, 2, 4, 5, 6, 4, 7, 6, 8, 9, 10, 8, 11, 10, 12, 13, 14, 12, 15, 14, 16, 17, 18, 16, 19, 18, 20, 21, 22, 20, 23, 22, 24, 25, 26, 24, 27, 26, 28, 29, 30, 28, 31, 30, 32, 33, 34, 32, 35, 34, 36, 37, 38, 36, 39, 38, 40, 41, 42, 40, 43, 42, 44, 45, 46, 44, 47, 46, 48, 49, 50, 48, 51, 50, 52, 53, 54, 52, 55, 54, 56, 57, 58, 56, 59, 58, 60, 61, 62, 60, 63, 62, 64, 65, 66, 64, 67, 66, 68, 69, 70, 68, 71, 70, 72, 73, 74, 72, 75, 74, 76, 77, 78, 76, 79, 78, 80, 81, 82, 80, 83, 82, 84, 85, 86, 84, 87, 86, 88, 89, 90, 88, 91, 90, 92, 93, 94, 92, 95, 94, 96, 97, 98, 96, 99, 98, 100, 101, 102, 100, 103, 102, 104, 105, 106, 104, 107, 106, 108, 109, 110, 108, 111, 110, 112, 113, 114, 112, 115, 114, 116, 117, 118, 116, 119, 118, 120, 121, 122, 120, 123, 122, 124, 125, 126, 124, 127, 126, 128, 129, 130, 128, 131, 130, 132, 133, 134, 132, 135, 134, 136, 137, 138, 136, 139, 138, 140, 141, 142, 140, 143, 142, 144, 145, 146, 144, 147, 146, 148, 149, 150, 148, 151, 150, 152, 153, 154, 152, 155, 154, 156, 157, 158, 156, 159, 158, 160, 161, 162, 160, 163, 162, 164, 165, 166, 164, 167, 166, 168, 169, 170, 168, 171, 170, 172, 173, 174, 172, 175, 174, 176, 177, 178, 176, 179, 178, 180, 181, 182, 180, 183, 182, 184, 185, 186, 184, 187, 186, 188, 189, 190, 188, 191, 190];
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(vertexIndices), gl.STATIC_DRAW);
    vertexIndexBuffer.itemSize = 1;
    vertexIndexBuffer.numItems = 288;
    vertexLinePositionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexLinePositionBuffer);
    lineVertices = [-1, -1, -1, -1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1, 1, 1, -1, 1, -1, -1, -1, 1, -1, 1, -1, 1, 1, -1, -1, 1, 1, 1, 1, -1, -1, -1, 1, -1, -1, 1, 1, -1, 1, -1, 1, -1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, 1, 1, 1, -1, 1, 1, 1, 1];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(lineVertices), gl.STATIC_DRAW);
    vertexLinePositionBuffer.itemSize = 4;
    vertexLinePositionBuffer.numItems = 16;
    vertexLineIndexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, vertexLineIndexBuffer);
    vertexLineIndices = [0, 1, 0, 2, 0, 4, 0, 8, 1, 0, 1, 3, 1, 5, 1, 9, 2, 0, 2, 3, 2, 6, 2, 10, 3, 1, 3, 2, 3, 7, 3, 11, 4, 0, 4, 5, 4, 6, 4, 12, 5, 1, 5, 4, 5, 7, 5, 13, 6, 2, 6, 4, 6, 7, 6, 14, 7, 3, 7, 5, 7, 6, 7, 15, 8, 0, 8, 9, 8, 10, 8, 12, 9, 1, 9, 8, 9, 11, 9, 13, 10, 2, 10, 8, 10, 11, 10, 14, 11, 3, 11, 9, 11, 10, 11, 15, 12, 4, 12, 8, 12, 13, 12, 14, 13, 5, 13, 9, 13, 12, 13, 15, 14, 6, 14, 10, 14, 12, 14, 15, 15, 7, 15, 11, 15, 13, 15, 14];
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(vertexLineIndices), gl.STATIC_DRAW);
    vertexLineIndexBuffer.itemSize = 1;
    return vertexLineIndexBuffer.numItems = 128;
  };

  drawTesseract = function(x, y, z, w) {
    vec4.set(tVector, x, y, z, w);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexColorAttribute, vertexColorBuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexNormalBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexNormalAttribute, vertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexLinePositionBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, vertexLinePositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, vertexLineIndexBuffer);
    setMatrixUniforms();
    gl.uniform1i(shaderProgram.meshBoolUniform, true);
    gl.drawElements(gl.LINES, vertexLineIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, vertexIndexBuffer);
    setMatrixUniforms();
    gl.uniform1i(shaderProgram.meshBoolUniform, false);
    return gl.drawElements(gl.TRIANGLES, vertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);
  };

  drawScene = function(px, py, pz, pw) {
    var d, i, results, w, x, y, z;
    gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    mat4.perspective(pMatrix, 45, gl.viewportWidth / gl.viewportHeight, 0.001, 100.0);
    mat4.identity(mvMatrix);
    vec4.set(pVector, px, py, pz, pw);
    vec4.set(lightDirectionVector, 1, 1, 1, 1);
    vec4.normalize(lightDirectionVector, lightDirectionVector);
    d = 3;
    results = [];
    for (x = i = -1; i <= 1; x = ++i) {
      results.push((function() {
        var j, results1;
        results1 = [];
        for (y = j = -1; j <= 1; y = ++j) {
          results1.push((function() {
            var k, results2;
            results2 = [];
            for (z = k = -1; k <= 1; z = ++k) {
              results2.push((function() {
                var l, results3;
                results3 = [];
                for (w = l = -1; l <= 1; w = ++l) {
                  if (!(x === 0 && y === 0 && z === 0 && w === 0)) {
                    results3.push(drawTesseract(d * x, d * y, d * z, d * w));
                  } else {
                    results3.push(void 0);
                  }
                }
                return results3;
              })());
            }
            return results2;
          })());
        }
        return results1;
      })());
    }
    return results;
  };

  center = {
    x: 0.0,
    y: 0.0
  };

  mouseDragging = false;

  dragStart = {
    x: 0,
    y: 0
  };

  dragCurrent = {
    x: 0,
    y: 0
  };

  currentDirection = {
    forward: 0,
    right: 0,
    up: 0,
    charm: 0
  };

  moveSpeed = 0.005;

  px = 0;

  py = 0;

  pz = 15;

  pw = 0;

  rotationSpeed = 2.0 * Math.PI;

  window.rotateMode = {
    x: 1,
    y: 3
  };

  stepRotationMode = function(dir) {
    center = {
      x: 0.0,
      y: 0.0
    };
    switch (dir) {
      case 0:
        rotateMode.x = (rotateMode.x + 1) % 6;
        break;
      case 1:
        rotateMode.y = (rotateMode.y + 1) % 6;
    }
    return console.log("rotation mode: " + rotateMode);
  };

  modalRotate = function(x0, y0) {
    var x, y;
    x = rotationSpeed * x0;
    y = rotationSpeed * y0;
    switch (rotateMode.x) {
      case 0:
        r1Float = x;
        break;
      case 1:
        r2Float = x;
        break;
      case 2:
        r3Float = x;
        break;
      case 3:
        r4Float = x;
        break;
      case 4:
        r5Float = x;
        break;
      case 5:
        r6Float = x;
    }
    switch (rotateMode.y) {
      case 0:
        return r1Float = y;
      case 1:
        return r2Float = y;
      case 2:
        return r3Float = y;
      case 3:
        return r4Float = y;
      case 4:
        return r5Float = y;
      case 5:
        return r6Float = y;
    }
  };

  window.auto = true;

  lastTime = 0;

  animate = function() {
    var elapsed, timeNow;
    timeNow = (new Date).getTime();
    if (lastTime !== 0) {
      elapsed = timeNow - lastTime;
      pz -= currentDirection.forward * moveSpeed * elapsed;
      px += currentDirection.right * moveSpeed * elapsed;
      py += currentDirection.up * moveSpeed * elapsed;
      pw += currentDirection.charm * moveSpeed * elapsed;
      pw = Math.max(0, pw);
      if (auto) {
        r1Float += 1.1 * elapsed * rotationSpeed / 50000;
        r2Float += 1.2 * elapsed * rotationSpeed / 50000;
        r3Float += 1.3 * elapsed * rotationSpeed / 50000;
        r4Float += 1.4 * elapsed * rotationSpeed / 50000;
        r5Float += 1.5 * elapsed * rotationSpeed / 50000;
        r6Float += 1.6 * elapsed * rotationSpeed / 50000;
      }
    }
    return lastTime = timeNow;
  };

  tick = function() {
    requestAnimFrame(tick);
    drawScene(px, py, pz, pw);
    return animate();
  };

  window.testing = function() {
    var canvas, finishGLInit, getMousePos, handleKeyPress, handleKeyRelease, waitForShaders;
    canvas = document.getElementById('canvas');
    getMousePos = (function(_this) {
      return function(event) {
        var rect;
        rect = canvas.getBoundingClientRect();
        return {
          x: event.clientX - rect.left,
          y: event.clientY - rect.top
        };
      };
    })(this);
    canvas.addEventListener("mousedown", (function(_this) {
      return function(e) {
        dragStart = dragCurrent = getMousePos(e);
        return mouseDragging = true;
      };
    })(this));
    canvas.addEventListener("mousemove", (function(_this) {
      return function(e) {
        var turnRight, turnUp;
        if (mouseDragging) {
          dragCurrent = getMousePos(e);
          turnRight = (dragStart.x - dragCurrent.x) / canvas.width;
          turnUp = (dragStart.y - dragCurrent.y) / canvas.height;
          return modalRotate(center.x + turnRight, center.y + turnUp);
        }
      };
    })(this));
    canvas.addEventListener("mouseup", (function(_this) {
      return function(e) {
        mouseDragging = false;
        center.x = center.x + (dragStart.x - dragCurrent.x) / canvas.width;
        center.y = center.y + (dragStart.y - dragCurrent.y) / canvas.height;
        dragStart = dragCurrent = {
          x: 0.0,
          y: 0.0
        };
        return console.log(r1Float, r2Float);
      };
    })(this));
    handleKeyPress = function(event) {
      var code;
      code = event.keyCode;
      console.log(code);
      switch (code) {
        case 87:
          return currentDirection.forward = 1;
        case 65:
          return currentDirection.right = -1;
        case 68:
          return currentDirection.right = 1;
        case 83:
          return currentDirection.forward = -1;
        case 69:
          return currentDirection.up = 1;
        case 81:
          return currentDirection.up = -1;
        case 82:
          return currentDirection.charm = 1;
        case 70:
          return currentDirection.charm = -1;
      }
    };
    handleKeyRelease = function(event) {
      var code;
      code = event.keyCode;
      switch (code) {
        case 87:
          currentDirection.forward = 0;
          break;
        case 65:
          currentDirection.right = 0;
          break;
        case 68:
          currentDirection.right = 0;
          break;
        case 83:
          currentDirection.forward = 0;
          break;
        case 69:
          currentDirection.up = 0;
          break;
        case 81:
          currentDirection.up = 0;
          break;
        case 82:
          currentDirection.charm = 0;
          break;
        case 70:
          currentDirection.charm = 0;
      }
      return console.log("position: (" + px + ", " + py + ", " + pz + ", " + pw + ")");
    };
    window.addEventListener("keydown", handleKeyPress, false);
    window.addEventListener("keyup", handleKeyRelease, false);
    initGL(canvas);
    loadShader('fragment.glsl', 'frag');
    loadShader('vertex.glsl', 'vert');
    waitForShaders = function(continuation) {
      console.log("fragment shader: " + shaders.fragReady);
      console.log("vertex shader: " + shaders.vertReady);
      if (!(shaders.fragReady && shaders.vertReady)) {
        return setTimeout((function() {
          return waitForShaders(continuation);
        }), 10);
      } else {
        return continuation();
      }
    };
    finishGLInit = function() {
      initShaders();
      initBuffers();
      gl.clearColor(0, 0, 0, 1);
      gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
      gl.enable(gl.BLEND);
      gl.disable(gl.DEPTH_TEST);
      gl.enable(gl.DEPTH_TEST);
      return tick();
    };
    return waitForShaders(finishGLInit);
  };

}).call(this);

//# sourceMappingURL=main.js.map