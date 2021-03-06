module.exports = Backbone.Collection.extend
  parse: (data) ->
    return data.models if data.meta?
    data
  parseBeforeLocalSave: (data) -> @parse(data)
  url: ->
    @model::urlRoot
  storeName: ->
    @url().replace apiUrl, ''
  comparator: (a,b) ->
    if a.attributes.start_at?
      return if a.attributes.start_at > b.attributes.start_at then -1 else 1

    if a.id? and b.id?
      return if a.id > b.id then -1 else 1
      
    if a.cid > b.cid then -1 else 1
  selectValues: ->
    @.map (m,i) ->
      label: m.to_s()
      value: m.get('id')
  
  sort_key: 'id'
  sort_direction: 'desc'
  comparator: (a,b) ->
    resp = 0
    resp = 1  if a.get(@sort_key) < b.get(@sort_key)
    resp = -1 if a.get(@sort_key) > b.get(@sort_key)
    resp = resp * -1 if @sort_direction == 'asc'

    resp
  sortByField: (fieldName, direction='asc') ->
    @sort_key = fieldName
    @sort_direction = direction
    @sort()
  