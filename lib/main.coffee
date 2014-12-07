grammarStatusView = null

module.exports =
  configDefaults:
    showOnRightSideOfStatusBar: true

  activate: ->
    atom.workspaceView.command('grammar-selector:show', createGrammarListView)

    atom.services.consume "status-bar", "^0.50.0", (statusBar) ->
      GrammarStatusView = require './grammar-status-view'
      grammarStatusView = new GrammarStatusView().initialize(statusBar)
      grammarStatusView.attach()

  deactivate: ->
    grammarStatusView?.destroy()

createGrammarListView = ->
  editor = atom.workspace.getActiveEditor()
  if editor?
    GrammarListView = require './grammar-list-view'
    view = new GrammarListView(editor)
    view.attach()
