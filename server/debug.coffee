coffee       = require "coffee-script"
fs           = require "fs"
pathHelpers  = require "path"
childProcess = require "child_process"
socketIO     = require "socket.io"
chalk        = require "chalk"

utils = require "./utils"
global.__SERVER_utils_data = utils._data

clientDir = "../client"
clientLoc = clientDir + "/index.coffee"
serverDir = "../server"
serverLoc = serverDir + "/index.coffee"

{Q, Qdenodify, server, app} = utils
io = socketIO server

readFile  = Qdenodify fs, fs.readFile
readDirQ  = Qdenodify fs, fs.readdir
readFileQ = Qdenodify fs, fs.readFile
statQ     = Qdenodify fs, fs.stat
execQ     = Qdenodify childProcess, childProcess.exec

browserify = (loc, emitScript) ->

  Qall = (ps) ->
    result = Q []
    for p in ps
      do (p) ->
        result = result.then (arr) ->
          p
          .then (v) ->
            arr.concat [v]
          .catch (e) ->
            arr.concat [err: e]
    result

  isCoffee = (path) -> path.indexOf(".coffee") is path.length - ".coffee".length

  awesomify = (srcPath) ->
    dir = pathHelpers.resolve pathHelpers.dirname srcPath
    readFileQ srcPath
    .then (src) ->
      src = src.toString "utf8"
      if isCoffee srcPath
        src = coffee.compile src, bare: true
      i = 0
      regex = /require *\( *['"][-_./0-9a-zA-Z]*['"] *\)/g
      dependenciesQ = while req = regex.exec src
        path = req[0]
        len = path.length
        path = path.substr(7).trim()
        shouldBeEscaped = [" ", "(", ")", '"', "'"]
        while path.charAt(0) in shouldBeEscaped
          path = path.substr 1
        while path.charAt(path.length - 1) in shouldBeEscaped
          path = path.substr 0, path.length - 1
        do (path, req, len) ->
          isWindows = process.env.OS is "Windows_NT"
          execQ (if isWindows then "cd #{dir} && coffee -e \"console.log require.resolve '#{path}'\"" else "cd #{dir} ; coffee -e \"console.log require.resolve '#{path}'\"")
          .then ([out, _]) ->
            throw "'#{path}' not resolved" unless out? and out.charAt(0).toLowerCase() is (if isWindows then __dirname.charAt(0).toLowerCase() else '/')
            from: req.index
            to: req.index + len
            path: out.substr 0, out.length - 1
      Qall dependenciesQ
      .then (dependencies) ->
        {dependencies, src}

  resolved = {}
  loadQ = (path) ->
    if resolved[path]?
      if resolved[path].loading
        return Q()
      else
        resolved[path].loading = true
    else
      index = Object.keys(resolved).length
      resolved[path] = index: index, path: path, loading: true
    resolved[path].compiledCodeChanged = false
    awesomify path
    .then (result) ->
      resolved[path].time = new Date().getTime()
      src = result.src
      offset = 0
      sequenceQ = Q()
      for dependency in result.dependencies
        if dependency.err
          console.log "Error", dependency.err
          continue
        do (dependency) ->
          sequenceQ = sequenceQ.then ->
            loadQ dependency.path
          .then ->
            newReq = "__req__(#{resolved[dependency.path].index})"
            src = src.slice(0, dependency.from + offset) + newReq + src.slice (dependency.to + offset)
            offset += newReq.length - (dependency.to - dependency.from)
      sequenceQ.then ->
        console.log chalk.green "loaded file: #{path}"
        script = resolved[path]
        script.compiledCodeChanged = script.src isnt src
        if script.compiledCodeChanged
          script.src = src
          emitScript? index: script.index, code: script.src , path: path
    .catch (err) ->
      resolved[path]?.time = new Date().getTime()
      delete err.code
      console.log "Error in file:", path, '\n', err

  bundleQ = loadQ loc


  do rebundle = ->
    bundleQ = bundleQ.then ->
      resolvedArr = (resolved[k] for k in Object.keys resolved)
      resolvedArr = resolvedArr.sort (a, b) -> a.index - b.index
      resolvedArr.map (r) ->
        src: r.src ? ''
        path: r.path

  do checkFiles = ->
    resolvedArr = (resolved[k] for k in Object.keys resolved)
    resolvedArr = resolvedArr.sort (a, b) -> a.index - b.index
    sequenceQ = Q()
    for r in resolvedArr
      do (r) ->
        sequenceQ = sequenceQ.then ->
          statQ r.path
        .then (stat) ->
          if stat.mtime.getTime() > r.time
            console.log "\u001B[2J\u001B[0;0f"
            resolved[r.path].loading = false
            loadQ r.path
            .then ->
              if resolved[r.path].compiledCodeChanged
                rebundle()

    sequenceQ.then ->
      setTimeout checkFiles

  -> bundleQ

#######################################################################################################################################

console.log "\u001B[2J\u001B[0;0f"

######################################################################[server]#########################################################

isUtils = (path) -> path.indexOf("utils.coffee") is path.length - "utils.coffee".length

serverEmitScript = (script) ->
  ev = eval
  ev "
    if (typeof(global.__SERVER_module_defenitions) !== 'undefined' && typeof(global.__SERVER_load) === 'function') {
      var defenition = function(__req__, module, exports){#{script.code}};
      #{if isUtils script.path then "defenition.isUtils = true;" else ""}
      global.__SERVER_module_defenitions[#{script.index}] = defenition;
      global.__SERVER_load(#{script.index});
    }
  "

browserify(serverLoc, serverEmitScript)()
.then (srcs) ->
  browserified = "
    var loadedModules = {};
    global.__SERVER_load = function(num) {
      var module;
      if (loadedModules[num]) {
        module = loadedModules[num];
      }
      else {
        module = loadedModules[num] = {
          dynamic: true,
          exports: {}
        };
      }
      var defenition = global.__SERVER_module_defenitions[num];
      if (defenition.isUtils)
        module._data = global.__SERVER_utils_data;
      defenition((function(num) {
        if (loadedModules[num])
          return loadedModules[num].exports;
        else
          return global.__SERVER_load(num).exports;
      }), module, module.exports);
      return module;
    };
    global.__SERVER_module_defenitions = [];
    var defenition;
    #{srcs.map (r) ->
        "defenition = function(__req__, module, exports){#{r.src}};
        #{if isUtils r.path then "defenition.isUtils = true;" else ""}
        global.__SERVER_module_defenitions.push(defenition);"
      .join ''}
    global.__SERVER_load(0);
  "
  ev = eval
  ev browserified

######################################################################[client]#########################################################

_clientEmitScript = ->
clientEmitScript = (script) ->
  _clientEmitScript script

io.on "connection", (socket) ->
  _clientEmitScript = (script) ->
    # socket.emit "script", script

clientQ = browserify clientLoc, clientEmitScript

app.get "/scripts.js", (req, res) ->
  clientQ().then (srcs) ->
    res.send "
      var loadedModules = {};
      var load = function(num) {
        var module;
        if (loadedModules[num]) {
          module = loadedModules[num];
        }
        else {
          module = loadedModules[num] = {
            dynamic: true,
            exports: {}
          };
        }
        var defenition = moduleDefenitions[num];
        defenition((function(num) {
          if (loadedModules[num])
            return loadedModules[num].exports;
          else
            return load(num).exports;
        }), module, module.exports);
        return module;
      };
      var moduleDefenitions = [];
      var defenition;
      #{
        srcs.map (r) ->
          "defenition = function(__req__, module, exports){#{r.src}};
          moduleDefenitions.push(defenition);"
        .join ""
      }
      load(0);
    "

appRoute = app._router.stack.filter (x) -> x.route?.path is '/'
appRoute = appRoute[0]
app._router.stack.splice app._router.stack.indexOf(appRoute), 1
app.get '/', (req, res) ->
  res.send '
    <!doctype html>
    <html>
    <head>
    <title></title>
    <script src="assets/lib/shim.js"></script>
    <script src="assets/lib/sham.js"></script>
    <script src="assets/lib/platform.js"></script>
    <script src="assets/lib/jquery.js"></script>
    <script src="assets/lib/bootstrap.js"></script>
    </head>
    <body>
    <script src="scripts.js"></script>
    </body>
    </html>
  '

