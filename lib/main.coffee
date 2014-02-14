module.exports =
  activate: ->
    atom.workspaceView.command('grammar-selector:show', createGrammarListView)
    atom.packages.once('activated', createGrammarStatusView)

createGrammarListView = ->
  editor = atom.workspace.getActiveEditor()
  if editor?
    GrammarListView = require './grammar-list-view'
    view = new GrammarListView(editor)
    view.attach()

createGrammarStatusView = ->
  statusBarView = atom.workspaceView.statusBar
  if statusBarView?
    GrammarStatusView = require './grammar-status-view'
    view = new GrammarStatusView(statusBarView)
    view.attach()
