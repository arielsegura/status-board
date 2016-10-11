SlackAPI = Meteor.npmRequire( 'node-slack' )

@FailJob = (job, callback, err) ->
  jobData = job.data
  date = new Date()
  status =
    lastCheck: date
    lastDownTime: date
    isUp: false
  previousJobData = Services.findOne {name: jobData.name}
  Services.update {name: jobData.name, type: jobData.type, group: jobData.group}, $set: status
  ServiceStatus.insert
    serviceId: jobData._id
    date: jobData.lastCheck
    isUp: jobData.isUp
  console.log("deciding whether to notify or not")
  if previousJobData.isUp isnt false 
    slackHookUrl = jobData.slackHookUrl
    if typeof slackHookUrl isnt "undefined"
      try 
        Slack = new SlackAPI(slackHookUrl)
        console.log("Sending message to Slack")
        Slack.send({
          text: "<!everyone>"+JSON.stringify({name: jobData.name, group: jobData.group, url: jobData.url, status: "down"})
        });
      catch e 
        console.error(e)
    else
      console.log("Should have notified but slack is not configured")
  else
    console.log("Status already notified")
  callback()

@CompleteJob = (job, callback) ->
  jobData = job.data
  status =
    lastCheck: new Date()
    isUp: true
  Services.update {name: jobData.name, type: jobData.type, group: jobData.group}, $set: status
  ServiceStatus.insert
    serviceId: jobData._id
    date: jobData.lastCheck
    isUp: jobData.isUp
  callback()

@JobsCollection  = JobCollection 'jobs'

Meteor.startup ->

  processors =
    http: HttpStatusJob
    ssh: SshJob

  for p of processors when processors[p].job
    Cue.addJob "#{p}", {retryOnError:false, maxMs:30000}, processors[p].job.bind(processors[p])

  Cue.maxTasksAtOnce = 8
  Cue.dropTasks()
  Cue.dropInProgressTasks()
  Cue.start()

  scheduleChecks = ->
    console.log 'Looking for services to check'
    Services.find().fetch().forEach (service) ->
      if processors[service.type]
        Cue.addTask service.type, {isAsync:true, unique:true}, service
      else
        console.error 'No processors for service', service

  Meteor.setInterval scheduleChecks, 10000

  scheduleChecks() # perform initial checks
