module.exports =
  configDefaults:
    showOnRightSideOfStatusBar: true

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
  {statusBar} = atom.workspaceView
  if statusBar?
    GrammarStatusView = require './grammar-status-view'
    view = new GrammarStatusView()
    view.initialize(statusBar)
    view.attach()
