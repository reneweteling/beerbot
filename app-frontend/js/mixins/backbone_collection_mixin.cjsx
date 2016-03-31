module.exports = 
  componentWillMount: ->
    self = @
    callback = ( ->
      self.setCollectionState() if self.setCollectionState
    ).bind(@)
    @props.collection.on("sync add", _.throttle( callback, 20 ) )

  componentWillUnmount: ->
    @props.collection.off("sync add", @callback)