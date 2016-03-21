gulp           = require 'gulp'
del            = require 'del'
browserify     = require 'browserify'
browserifyInc  = require 'browserify-incremental'
sass           = require 'gulp-sass'
reactify       = require 'coffee-reactify'
source         = require 'vinyl-source-stream'
sourcemaps     = require 'gulp-sourcemaps'
webserver      = require 'gulp-server-livereload'
sequence       = require 'run-sequence'
manifest       = require 'gulp-manifest'
rename         = require 'gulp-rename'
buffer         = require 'vinyl-buffer'
uglify         = require 'gulp-uglify'

config =
  sassPath: './app-frontend/style'
  npmDir: './node_modules'

gulp.task 'default', (cb) ->
  sequence 'clean', ['copy', 'sass', 'script'], 'manifest', 'watch', 'webserver', cb

gulp.task 'production', (cb) ->
  sequence 'clean', ['copy', 'sass', 'script'], 'manifest', cb

gulp.task 'script', ->
  b = browserify {
    fullPaths: true,
    debug: true,
    cache: {}
  }
  browserifyInc(b, {cacheFile: './browserify-cache.json'})
  b.transform(reactify)
  b.add('./app-frontend/js/main.cjsx')

  b.bundle()
    .on 'error', (err) -> 
      console.error err.toString()
      this.emit("end")
    .pipe(source('app.js'))
    .pipe buffer()
    .pipe sourcemaps.init({loadMaps: true})
    # .pipe uglify()
    .pipe sourcemaps.write('./maps')
    .pipe gulp.dest('./public/app/assets')

gulp.task 'copy', ->
  gulp.src('./app-frontend/images/**').pipe gulp.dest('./public/app/assets/images')
  gulp.src('./app-frontend/*.html').pipe gulp.dest('./public/app')
  gulp.src("#{config.npmDir}/bootstrap-sass/assets/fonts/**").pipe gulp.dest('./public/app/fonts')
  

gulp.task 'clean', ->
  del(['./public/app/*','./browserify-cache.json'])

gulp.task 'sass', ->
  gulp.src './app-frontend/style/app.sass'
    .pipe sourcemaps.init()
      .pipe sass(
        loadPath: [
          config.sassPath
        ]
      ).on('error', sass.logError)
    .pipe sourcemaps.write('./maps')
    .pipe gulp.dest('./public/app/assets')

gulp.task 'manifest', ->
  gulp.src([ './public/app/**/*' ], base: './public/app/assets').pipe(manifest(
    hash: true
    preferOnline: true
    network: [ '*' ]
    filename: 'app.manifest'
    exclude: 'assets/app.manifest')).pipe gulp.dest('./public/app/assets')

gulp.task 'webserver', ->
  gulp.src('./public/app')
    .pipe(
      webserver(
        fallback: 'index.html'
        defaultFile: 'index.html'
        livereload: true
        log: 'debug'
      )
    )

gulp.task 'watch', ->
  gulp.watch ['./app-frontend/style/**'],                  [ 'sass' ]
  gulp.watch ['./app-frontend/js/**', './app-frontend/js/**/**', './app-frontend/js/**/**/**'],           [ 'script' ]
  gulp.watch ['./app-frontend/*.html', './app-frontend/images/**'], [ 'copy' ]