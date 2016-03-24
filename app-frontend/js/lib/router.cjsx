module.exports = Backbone.Router.extend
  routes:
    ''                                      : 'root'
    'index'                                 : 'index'
    'stats'                                 : 'stats'
    'login'                                 : 'login'
    'logout'                                : 'login'
    '*path'                                 : 'notFound'
  root: ->
    Router.navigate '/index', {trigger:true}

  login: -> 
    Login = require('../pages/login/login.cjsx')
    @content = <Login model={CurrentUser} />
    CurrentUser.signOut() if CurrentUser.signedIn()

  index: ->
    Index = require('../pages/index.cjsx')
    @content = <Index collection={UserCollection} />

  stats: ->
    Stats = require('../pages/stats.cjsx')
    @content = <Stats collection={UserCollection} />

  notFound: -> 
    @content = <div className="container">
      <div className="panel panel-warning">
        <div className="panel-heading">
          <h3 className="panel-title">Pagina niet gevonden</h3>
        </div>
        <div className="panel-body">
          Helaas deze pagina is niet gevonden.
        </div>
      </div>
    </div>
