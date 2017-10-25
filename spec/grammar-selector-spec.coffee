path = require 'path'
{last, invoke} = require 'underscore-plus'

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

      waitsFor ->
        atom.workspace.getModalPanels().length is 1

      runs ->
        grammarView = atom.workspace.getModalPanels()[0].getItem().element
        # TODO: Remove once Atom 1.23 reaches stable
        if parseFloat(atom.getVersion()) >= 1.23
          # Do not take into account the two JS regex grammars or language-with-no-name
          expect(grammarView.querySelectorAll('li').length).toBe(atom.grammars.grammars.length - 3)
        else
          expect(grammarView.querySelectorAll('li').length).toBe(atom.grammars.grammars.length - 1)
        expect(grammarView.querySelectorAll('li')[0].textContent).toBe 'Auto Detect'
        expect(grammarView.textContent.includes('source.a')).toBe(false)
        for li in grammarView.querySelectorAll('li')
          expect(li.textContent).not.toBe(atom.grammars.nullGrammar.name)

  describe "when a grammar is selected", ->
    it "sets the new grammar on the editor", ->
      atom.commands.dispatch(editorView, 'grammar-selector:show')

      waitsFor ->
        atom.workspace.getModalPanels().length is 1

      runs ->
        grammarView = atom.workspace.getModalPanels()[0].getItem()
        grammarView.props.didConfirmSelection(textGrammar)
        expect(editor.getGrammar()).toBe textGrammar

  describe "when auto-detect is selected", ->
    it "restores the auto-detected grammar on the editor", ->
      atom.commands.dispatch(editorView, 'grammar-selector:show')

      waitsFor ->
        atom.workspace.getModalPanels().length is 1

      runs ->
        grammarView = atom.workspace.getModalPanels()[0].getItem()
        grammarView.props.didConfirmSelection(textGrammar)
        expect(editor.getGrammar()).toBe textGrammar

        atom.commands.dispatch(editorView, 'grammar-selector:show')

      waitsFor ->
        atom.workspace.getModalPanels().length is 1

      runs ->
        grammarView = atom.workspace.getModalPanels()[0].getItem()
        grammarView.props.didConfirmSelection(grammarView.items[0])
        expect(editor.getGrammar()).toBe jsGrammar

  describe "when the editor's current grammar is the null grammar", ->
    it "displays Auto Detect as the selected grammar", ->
      editor.setGrammar(atom.grammars.nullGrammar)
      atom.commands.dispatch(editorView, 'grammar-selector:show')

      waitsFor ->
        atom.workspace.getModalPanels().length is 1

      runs ->
        grammarView = atom.workspace.getModalPanels()[0].getItem().element
        expect(grammarView.querySelector('li.active').textContent).toBe 'Auto Detect'

  describe "when editor is untitled", ->
    it "sets the new grammar on the editor", ->
      waitsForPromise ->
        atom.workspace.open()

      runs ->
        editor = atom.workspace.getActiveTextEditor()
        editorView = atom.views.getView(editor)
        expect(editor.getGrammar()).not.toBe jsGrammar

        atom.commands.dispatch(editorView, 'grammar-selector:show')

      waitsFor ->
        atom.workspace.getModalPanels().length is 1

      runs ->
        grammarView = atom.workspace.getModalPanels()[0].getItem()
        grammarView.props.didConfirmSelection(jsGrammar)
        expect(editor.getGrammar()).toBe jsGrammar

  describe "grammar label", ->
    [grammarStatus, grammarTile, statusBar] = []

    beforeEach ->
      atom.packages.emitter.emit('did-activate-all')
      statusBar = workspaceElement.querySelector("status-bar")
      grammarTile = last(statusBar.getLeftTiles())
      grammarStatus = grammarTile.getItem()
      jasmine.attachToDOM(grammarStatus)

      waitsFor ->
        grammarStatus.offsetHeight > 0

    it "displays the name of the current grammar", ->
      grammarStatus.querySelector('a').textContent is 'JavaScript'

    it "displays Plain Text when the current grammar is the null grammar", ->
      editor.setGrammar(atom.grammars.nullGrammar)

      waitsFor ->
        grammarStatus.querySelector('a').textContent is 'Plain Text'

      runs ->
        expect(grammarStatus).toBeVisible()
        editor.setGrammar(atom.grammars.grammarForScopeName('source.js'))

      waitsFor ->
        grammarStatus.querySelector('a').textContent is 'JavaScript'

      runs ->
        expect(grammarStatus).toBeVisible()

    it "hides the label when the current grammar is null", ->
      jasmine.attachToDOM(editorView)
      spyOn(editor, 'getGrammar').andReturn null
      editor.setGrammar(atom.grammars.nullGrammar)
      waitsFor ->
        grammarStatus.offsetHeight is 0

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

        waitsFor ->
          grammarStatus.querySelector('a').textContent is 'Plain Text'

        runs ->
          editor.setGrammar(atom.grammars.grammarForScopeName('source.a'))

        waitsFor ->
          grammarStatus.querySelector('a').textContent is 'source.a'

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
