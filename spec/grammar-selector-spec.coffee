path = require 'path'
{last, invoke} = require 'underscore-plus'
{$} = require 'atom-space-pen-views'

describe "GrammarSelector", ->
  [editor, editorView, workspaceElement, textGrammar, jsGrammar] =  []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    atom.config.set('grammar-selector.showOnRightSideOfStatusBar', false)

    waitsForPromise ->
      atom.packages.activatePackage('status-bar')

    waitsForPromise ->
      atom.packages.activatePackage('grammar-selector')

    waitsForPromise ->
      atom.packages.activatePackage('language-text')

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.packages.activatePackage(path.join(__dirname, 'fixtures', 'language-with-no-name'))

    waitsForPromise ->
      atom.workspace.open('sample.js')

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)
      textGrammar = atom.grammars.grammarForScopeName('text.plain')
      expect(textGrammar).toBeTruthy()
      jsGrammar = atom.grammars.grammarForScopeName('source.js')
      expect(jsGrammar).toBeTruthy()
      expect(editor.getGrammar()).toBe jsGrammar

  describe "when grammar-selector:show is triggered", ->
    it "displays a list of all the available grammars", ->
      atom.commands.dispatch(editorView, 'grammar-selector:show')
      grammarView = atom.workspace.getModalPanels()[0].getItem()
      expect(grammarView.list.children('li:first').text()).toBe 'Auto Detect'
      expect(grammarView.list.children('li:contains("Language with Name")')).toExist()
      for li in grammarView.list.children('li')
        expect($(li).text()).not.toBe atom.grammars.nullGrammar.name

    it "only shows grammars with a `name` property defined", ->
      atom.commands.dispatch(editorView, 'grammar-selector:show')
      grammarView = atom.workspace.getModalPanels()[0].getItem()
      expect(grammarView.list.children('li:contains(source.a)')).not.toExist()
      expect(grammarView.list.children('li').length).toBe atom.grammars.grammars.length - 1

  describe "when a grammar is selected", ->
    it "sets the new grammar on the editor", ->
      atom.commands.dispatch(editorView, 'grammar-selector:show')
      grammarView = atom.workspace.getModalPanels()[0].getItem()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

  describe "when auto-detect is selected", ->
    it "restores the auto-detected grammar on the editor", ->
      atom.commands.dispatch(editorView, 'grammar-selector:show')
      grammarView = atom.workspace.getModalPanels()[0].getItem()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

      atom.commands.dispatch(editorView, 'grammar-selector:show')
      grammarView = atom.workspace.getModalPanels()[0].getItem()
      grammarView.confirmed(grammarView.items[0])
      expect(editor.getGrammar()).toBe jsGrammar

  describe "when the editor's current grammar is the null grammar", ->
    it "displays Auto Detect as the selected grammar", ->
      editor.setGrammar(atom.grammars.nullGrammar)
      atom.commands.dispatch(editorView, 'grammar-selector:show')
      grammarView = atom.workspace.getModalPanels()[0].getItem()
      expect(grammarView.list.children('li.active').text()).toBe 'Auto Detect'

  describe "when editor is untitled", ->
    it "sets the new grammar on the editor", ->
      waitsForPromise ->
        atom.workspace.open()

      runs ->
        editor = atom.workspace.getActiveTextEditor()
        editorView = atom.views.getView(editor)

        atom.commands.dispatch(editorView, 'grammar-selector:show')
        expect(editor.getGrammar()).not.toBe jsGrammar
        grammarView = atom.workspace.getModalPanels()[0].getItem()
        grammarView.confirmed(jsGrammar)
        expect(editor.getGrammar()).toBe jsGrammar

  describe "grammar label", ->
    [grammarStatus, grammarTile, statusBar] = []

    beforeEach ->
      atom.packages.emitter.emit('did-activate-all')
      statusBar = workspaceElement.querySelector("status-bar")
      grammarTile = last(statusBar.getLeftTiles())
      grammarStatus = grammarTile.getItem()
      jasmine.attachToDOM(grammarStatus)

    it "displays the name of the current grammar", ->
      expect(grammarStatus.grammarLink.textContent).toBe 'JavaScript'

    it "displays Plain Text when the current grammar is the null grammar", ->
      editor.setGrammar(atom.grammars.nullGrammar)
      expect(grammarStatus).toBeVisible()
      expect(grammarStatus.grammarLink.textContent).toBe 'Plain Text'
      editor.setGrammar(atom.grammars.grammarForScopeName('source.js'))
      expect(grammarStatus).toBeVisible()
      expect(grammarStatus.grammarLink.textContent).toBe 'JavaScript'

    it "hides the label when the current grammar is null", ->
      jasmine.attachToDOM(editorView)
      spyOn(editor, 'getGrammar').andReturn null
      editor.setGrammar(atom.grammars.nullGrammar)
      expect(grammarStatus).toBeHidden()

    describe "when the grammar-selector.showOnRightSideOfStatusBar setting changes", ->
      it "moves the item to the preferred side of the status bar", ->
        expect(invoke(statusBar.getLeftTiles(), 'getItem')).toContain(grammarStatus)
        expect(invoke(statusBar.getRightTiles(), 'getItem')).not.toContain(grammarStatus)

        atom.config.set("grammar-selector.showOnRightSideOfStatusBar", true)

        expect(invoke(statusBar.getLeftTiles(), 'getItem')).not.toContain(grammarStatus)
        expect(invoke(statusBar.getRightTiles(), 'getItem')).toContain(grammarStatus)

        atom.config.set("grammar-selector.showOnRightSideOfStatusBar", false)

        expect(invoke(statusBar.getLeftTiles(), 'getItem')).toContain(grammarStatus)
        expect(invoke(statusBar.getRightTiles(), 'getItem')).not.toContain(grammarStatus)

    describe "when the editor's grammar changes", ->
      it "displays the new grammar of the editor", ->
        editor.setGrammar(atom.grammars.grammarForScopeName('text.plain'))
        expect(grammarStatus.grammarLink.textContent).toBe 'Plain Text'

        editor.setGrammar(atom.grammars.grammarForScopeName('source.a'))
        expect(grammarStatus.grammarLink.textContent).toBe 'source.a'

    describe "when clicked", ->
      it "shows the grammar selector modal", ->
        eventHandler = jasmine.createSpy('eventHandler')
        atom.commands.add(editorView, 'grammar-selector:show', eventHandler)
        grammarStatus.click()
        expect(eventHandler).toHaveBeenCalled()

    describe "when the package is deactivated", ->
      it "removes the view", ->
        spyOn(grammarTile, 'destroy')
        atom.packages.deactivatePackage('grammar-selector')
        expect(grammarTile.destroy).toHaveBeenCalled()
