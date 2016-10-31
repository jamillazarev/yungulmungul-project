gulp =                  require "gulp"
browserSync =           require "browser-sync"
reload =                browserSync.reload
watch =                 require "gulp-watch"
rimraf =                require "rimraf"
pug =                   require "gulp-pug"
stylus =                require "gulp-stylus"
autoprefixer =          require "gulp-autoprefixer"
nib =                   require "nib"
notify =                require "gulp-notify"
plumber =               require "gulp-plumber"
util =                  require "gulp-util"
uglify =                require "gulp-uglify"
sequence =              require "run-sequence"
coffee =                require "gulp-coffee"
jsdoc =                 require "gulp-jsdoc3"
sourcemaps =            require "gulp-sourcemaps"
environments =          require "gulp-environments"
w3cjs =                 require "gulp-w3cjs"

dev = environments.development
prod = environments.production
projectName = process.cwd().slice(process.cwd().lastIndexOf('/')+1, process.cwd().toString().length)
packageName = require("./package.json").name

onError = (err) ->
  util.beep()
  util.log util.colors.red err
  notify.onError(err.plugin)(err)

gulp.task "browserSync", ->
  browserSync
    server:
      baseDir: "./"
      directory: true
    logPrefix: projectName
    logConnections: true
    startPath: "./dist/index.html"
    port: 1818
    ui:
      port: 1819
    ghostMode:
      clicks: true
      forms: true
      scroll: true
    online: false
    notify: false
    open: true
    xip: false
    reloadDelay: 800

gulp.task "pug", ->
  rimraf "./dist/*.html", ->
    gulp.src ["./src/pug/*.pug", "!./src/pug/_*.pug", "!./src/pug/__*.pug"]
    .pipe plumber errorHandler: onError
    .pipe dev sourcemaps.init()
    .pipe dev pug
      pretty: true
      locals:
        projectName: projectName
        packageName : packageName
    .pipe dev sourcemaps.write()
    .pipe prod pug
      pretty: false
      locals:
        projectName: projectName
        packageName : packageName
    .pipe w3cjs()
    .pipe gulp.dest "./dist"
    .pipe reload stream: true

gulp.task "styl", ->
  rimraf "./dist/css/*.css", ->
    gulp.src ["./src/styl/*.styl", "!./src/styl/_*.styl", "!./src/styl/__*.styl"]
    .pipe plumber errorHandler: onError
    .pipe dev sourcemaps.init()
    .pipe dev stylus use: nib(), linenos: true
    .pipe prod stylus use: nib(), linenos: false, compress: true
    .pipe autoprefixer browsers: "last 4 versions"
    .pipe gulp.dest "./dist/css"
    .pipe reload stream: true

gulp.task "coffee", ->
  rimraf "./dist/js/*.js", ->
    gulp.src ["./src/coffee/*.coffee", "!./src/coffee/_*.coffee", "!./src/coffee/__*.coffee"], read: true
    .pipe plumber errorHandler: onError
    .pipe dev sourcemaps.init()
    .pipe coffee()
    .pipe dev sourcemaps.write()
    .pipe prod uglify()
    .pipe gulp.dest "./dist/js"
    .pipe reload stream: true

gulp.task "doc", ->
  rimraf "./docs", ->
    gulp.src './dist/js/*.js', {read: false}
    .pipe plumber errorHandler: onError
    .pipe jsdoc()
    .pipe reload stream: true

gulp.task "watch", ->
  watch "./src/pug/*.pug", ->
    gulp.start "pug"
    reload
  watch "./src/styl/*.styl", ->
    gulp.start "styl"
    reload
  watch "./src/coffee/*.coffee", ->
    gulp.start "coffee"
    reload

gulp.task "default", ->
  sequence [
    "styl"
    "coffee"
  ], "pug", "browserSync", "watch"