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
bower          = require 'gulp-bower'
rename         = require 'gulp-rename'
buffer         = require 'vinyl-buffer'
uglify         = require 'gulp-uglify'

config =
  sassPath: './z-app/style'
  bowerDir: './bower_components'
  npmDir: './node_modules'

gulp.task 'default', (cb) ->
  sequence 'clean', 'bower', ['copy', 'sass', 'script'], 'manifest', 'watch', 'webserver', cb

gulp.task 'production', (cb) ->
  sequence 'clean', 'bower', ['copy', 'sass', 'script'], 'manifest', cb

gulp.task 'bower', ->
  bower()
  .pipe(gulp.dest(config.bowerDir))

gulp.task 'script', ->
  b = browserify {
    fullPaths: true,
    debug: true,
    cache: {}
  }
  browserifyInc(b, {cacheFile: './browserify-cache.json'})
  b.transform(reactify)
  b.add('./z-app/js/main.cjsx')

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
    .pipe gulp.dest('./z-cordova/www/assets')

gulp.task 'copy', ->
  gulp.src('./z-app/images/**').pipe gulp.dest('./public/app/assets/images')
  gulp.src('./z-app/images/*').pipe gulp.dest('./z-cordova/www/assets/images')
  gulp.src('./z-app/*.html').pipe gulp.dest('./public/app')
  gulp.src('./z-app/cordova.html').pipe(rename('index.html')).pipe gulp.dest('./z-cordova/www')
  gulp.src("#{config.npmDir}/bootstrap-sass/assets/fonts/**").pipe gulp.dest('./public/app/fonts')
  gulp.src("#{config.npmDir}/bootstrap-sass/assets/fonts/**").pipe gulp.dest('./z-cordova/www/fonts')


gulp.task 'clean', ->
  del(['./public/app/*','./browserify-cache.json', './z-cordova/www/*'])

gulp.task 'sass', ->
  gulp.src './z-app/style/app.sass'
    .pipe sourcemaps.init()
      .pipe sass(
        loadPath: [
          config.sassPath
          config.bowerDir + '/bootstrap-sass-official/assets/stylesheets'
        ]
      ).on('error', sass.logError)
    .pipe sourcemaps.write('./maps')
    .pipe gulp.dest('./public/app/assets')
    .pipe gulp.dest('./z-cordova/www/assets')

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
  gulp.watch ['./z-app/style/**'],                  [ 'sass' ]
  gulp.watch ['./z-app/js/**', './z-app/js/**/**', './z-app/js/**/**/**'],           [ 'script' ]
  gulp.watch ['./z-app/*.html', './z-app/images/**'], [ 'copy' ]