timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Project, DataAdapter, Message, State, Option, Resource, Analytics, IssueEditState, Const) ->

  # data
  $scope.data = DataAdapter
  $scope.Const = Const

  # typeahead data
  $scope.queryData = null

  $scope.searchField = text: ''
  $scope.tooltipPlace = 'top'
  $scope.totalItems = 0
  $scope.state = State
  $scope.isOpen = false

  # typeahead options
  $scope.inputOptions =
    highlight: true
    minLength: 0

  $scope.tabState = {}

  # http request canceled.
  STATUS_CANCEL = 0

  # don't use query
  QUERY_ALL_ID = 0


  ###
   Initialize.
  ###
  init = () ->

    $scope.options = Option.getOptions()

    $scope.editState = new IssueEditState($scope)
    initializeSearchform()

    # on change selected Project, load issues and queries.
    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_CHANGED, () ->
      loadIssues()

   # on change selected Query, set query to project, and load issues.
    DataAdapter.addEventListener DataAdapter.SELECTED_QUERY_CHANGED, () ->
      setQueryAndloadIssues()

    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_UPDATED, () ->
      $scope.$apply()


  ###
   Initialize.
  ###
  initializeSearchform = () ->
    # query
    $scope.queryData =
      displayKey: 'name'
      source: util.substringMatcher(DataAdapter.queries, ['name', 'id'])
      templates:
        suggestion: (n) -> "<div class='list-item'><span class='list-item__name'>#{n.name}</span><span class='list-item__description list-item__id'>#{n.id}</span></div>"


  ###
   on change selected Query, set query to project, and udpate issues.
  ###
  setQueryAndloadIssues = () ->
    if not DataAdapter.selectedProject then return
    if not DataAdapter.selectedQuery then return
    targetId  = DataAdapter.selectedProject.id
    targetUrl = DataAdapter.selectedProject.url
    queryId   = DataAdapter.selectedQuery.id
    if queryId is QUERY_ALL_ID then queryId = undefined
    DataAdapter.selectedProject.queryId = queryId
    Project.setParam(targetUrl, targetId, { 'queryId': queryId })
    loadIssues()


  # load issues on P.1
  loadIssues = () ->
    $scope.editState.loadAllTicketOnProject()


  ###
   on checkBox == All is clicked, change all property state.
   on checkBox != All is clicked, change All's property state.
  ###
  $scope.clickCheckbox = (propertyName, option, $event) ->
    if option.name is "All"
      DataAdapter.selectedProject[propertyName].map((p) -> p.checked = option.checked)
    else if option.checked is false
      DataAdapter.selectedProject[propertyName][0].checked = false
    else if DataAdapter.selectedProject[propertyName].slice(1).all((p) -> p.checked)
      DataAdapter.selectedProject[propertyName][0].checked = true

    $event.stopPropagation()

  ###
   on change state.currentPage, start loading.
  ###
  $scope.$watch 'editState.currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.loadAllTicketOnProject()


  ###
   Start Initialize.
  ###
  init()
