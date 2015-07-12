Template.index.helpers
  services: -> Services.find {}, sort: name: 1
  lastCheckHuman: -> moment(@lastCheck).fromNow()
  statusClass: -> if @isUp then 'dash-tile-green' else 'dash-tile-red'
  statusText: -> if @isUp then 'Up' else 'Down'

Template.header.helpers
  upCount: -> Services.find({isUp: true}).count()
  downCount: -> Services.find({isUp: false}).count()
  upNumberClass: ->
    if Services.find({isUp: true}).count() then 'up' else 'ok'
  downNumberClass: ->
    if Services.find({isUp: false}).count() then 'down' else 'ok'

Template.simpleServiceStatusGraph.helpers
  statusColor: -> if @isUp then '#2ECC40' else '#FF4136'
  borderStatusColor: -> if @isUp then 'green' else 'red'
  serviceStatus: ->
    Meteor.subscribe 'service/status', {name: @name}
    ServiceStatus.find {name: @name}, sort: date: -1
  dateFromNow: -> moment(@date).fromNow()
