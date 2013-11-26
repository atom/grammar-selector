GrammarStatusView = require './grammar-status-view'
GrammarSelectorView = require './grammar-selector-view'

module.exports =
  activate: ->
    atom.workspaceView.command 'grammar-selector:show', '.editor', =>
      new GrammarSelectorView()

    createStatusEntry = ->
      view = new GrammarStatusView(atom.workspaceView.statusBar)
      atom.workspaceView.statusBar.appendLeft(view)

    if atom.workspaceView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', ->
        createStatusEntry()
