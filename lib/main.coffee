commandDisposable = null
grammarListView = null
grammarStatusView = null

module.exports =
  config:
    showOnRightSideOfStatusBar:
      type: 'boolean'
      default: true

  activate: ->
    commandDisposable = atom.commands.add('atom-text-editor', 'grammar-selector:show', createGrammarListView)
    atom.packages.onDidActivateAll(createGrammarStatusView)

  deactivate: ->
    commandDisposable?.dispose()
    commandDisposable = null

    grammarStatusView?.destroy()
    grammarStatusView = null

    grammarListView?.destroy()
    grammarListView = null

createGrammarListView = ->
  unless grammarListView?
    GrammarListView = require './grammar-list-view'
    grammarListView = new GrammarListView()
  grammarListView.toggle()

createGrammarStatusView = ->
  statusBar = atom.views.getView(atom.workspace).querySelector("status-bar")
  if statusBar?
    GrammarStatusView = require './grammar-status-view'
    grammarStatusView = new GrammarStatusView().initialize(statusBar)
    grammarStatusView.attach()
