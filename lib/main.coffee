grammarStatusView = null

module.exports =
  configDefaults:
    showOnRightSideOfStatusBar: true

  activate: ->
    @commandDisposable = atom.commands.add 'atom-workspace', 'grammar-selector:show', createGrammarListView
    atom.packages.once('activated', createGrammarStatusView)

  deactivate: ->
    @commandDisposable.dispose()
    grammarStatusView?.destroy()

createGrammarListView = ->
  editor = atom.workspace.getActiveEditor()
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
