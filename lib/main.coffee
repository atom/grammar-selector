module.exports =
  activate: ->
    atom.workspaceView.command 'grammar-selector:show', ->
      createGrammarSelectorView()

    atom.packages.once 'activated', ->
      createGrammarStatusView()

createGrammarSelectorView = ->
  editor = atom.workspace.getActiveEditor()
  if editor?
    GrammarSelectorView = require './grammar-selector-view'
    new GrammarSelectorView(editor)

createGrammarStatusView = ->
  statusBarView = atom.workspaceView.statusBar
  if statusBarView?
    GrammarStatusView = require './grammar-status-view'
    view = new GrammarStatusView(statusBarView)
    statusBarView.appendLeft(view)
