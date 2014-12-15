grammarListView = null
grammarStatusView = null

module.exports =
  config:
    showOnRightSideOfStatusBar:
      type: 'boolean'
      default: true

  activate: ->
    @commandDisposable = atom.commands.add('atom-text-editor', 'grammar-selector:show', createGrammarListView)
    atom.packages.onDidActivateAll(createGrammarStatusView)

  deactivate: ->
    @commandDisposable.dispose()
    grammarStatusView?.destroy()
    grammarStatusView = null
    grammarListView?.destroy()
    grammarListView = null

createGrammarListView = ->
  editor = atom.workspace.getActiveTextEditor()
  if editor?
    GrammarListView = require './grammar-list-view'
    grammarListView ?= new GrammarListView(editor)
  grammarListView.attach()

createGrammarStatusView = ->
  statusBar = atom.views.getView(atom.workspace).querySelector("status-bar")
  if statusBar?
    GrammarStatusView = require './grammar-status-view'
    grammarStatusView = new GrammarStatusView().initialize(statusBar)
    grammarStatusView.attach()
