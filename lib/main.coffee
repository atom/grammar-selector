grammarStatusView = null

module.exports =
  config:
    showOnRightSideOfStatusBar:
      type: 'boolean'
      default: true

  activate: ->
    @commandDisposable = atom.commands.add 'atom-workspace', 'grammar-selector:show', createGrammarListView
    atom.packages.onDidActivateAll(createGrammarStatusView)

  deactivate: ->
    @commandDisposable.dispose()
    grammarStatusView?.destroy()

createGrammarListView = ->
  editor = atom.workspace.getActiveTextEditor()
  if editor?
    GrammarListView = require './grammar-list-view'
    view = new GrammarListView(editor)
    view.attach()

createGrammarStatusView = ->
  statusBar = atom.views.getView(atom.workspace).querySelector("status-bar")
  if statusBar?
    GrammarStatusView = require './grammar-status-view'
    grammarStatusView = new GrammarStatusView().initialize(statusBar)
    grammarStatusView.attach()
