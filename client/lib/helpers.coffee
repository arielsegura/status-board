Session.set 'displayType', 'tiles' if not Session.get 'displayType'
Session.set 'mode', 'default' if not Session.get 'mode'

@groups = new ReactiveVar null
@visibleGroups = new ReactiveVar null

@findServicesByGroup = -> Services.find {group: @group}, sort: name: 1

@IsUp = (service) -> service.isUp
@IsDown = (service) -> service.isUp == false and service.isUp != undefined
