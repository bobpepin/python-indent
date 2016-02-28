describe 'python-indent', ->
  PythonIndent = require '../lib/python-indent'
  grammar = 'Python'
  FILE_NAME = 'fixture.py'
  editor = null
  buffer = null
  pythonIndent = null

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open(FILE_NAME).then (ed) ->
        editor = ed
        editor.setSoftTabs true
        editor.setTabLength 4

        buffer = editor.buffer

    waitsForPromise ->
        packages = atom.packages.getAvailablePackageNames()

        if 'language-python' in packages
          languagePackage = 'language-python'
        else if 'MagicPython' in packages
          languagePackage = 'MagicPython'

        atom.packages.activatePackage languagePackage

    waitsForPromise ->
      atom.packages.activatePackage('python-indent').then ->
        pythonIndent = new PythonIndent()

  describe 'package', ->
    it 'loads python file and package', ->
      expect(editor.getPath()).toContain FILE_NAME
      expect(atom.packages.isPackageActive('python-indent')).toBe true

  # Aligned with opening delimiter
  describe 'aligned with opening delimiter', ->

    describe 'when indenting after newline', ->

      '''
      def test(param_a, param_b, param_c,
               param_d):
          pass
      '''
      it 'indents after open def params', ->
        editor.insertText 'def test(param_a, param_b, param_c,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 9

      '''
      x = [0, 1, 2,
           3, 4, 5]
      '''
      it 'indents after open bracket with multiple values on the first line', ->
        editor.insertText 'x = [0, 1, 2,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 5

      '''
      x = [0,
           1]
      '''
      it 'indents after open bracket with one value on the first line', ->
        editor.insertText 'x = [0,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 5

      '''
      x = [0, 1, 2, [3, 4, 5,
                     6, 7, 8]]
      '''
      it 'indeents in nested lists when inner list is on the same line', ->
        editor.insertText 'x = [0, 1, 2, [3, 4, 5,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 15

      '''
      x = [0, 1, 2,
           [3, 4, 5,
            6, 7, 8]]
      '''
      it 'indeents in nested lists when inner list is on a new line', ->
        editor.insertText 'x = [0, 1, 2,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 5

        editor.insertText '[3, 4, 5,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(2)).toBe ' '.repeat 6

      '''
      x = (0, 1, 2,
           3, 4, 5)
      '''
      it 'indents after open tuple with multiple values on the first line', ->
        editor.insertText 'x = (0, 1, 2,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 5

      '''
      x = (0,
           1)
      '''
      it 'indents after open tuple with one value on the first line', ->
        editor.insertText 'x = (0,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 5

      '''
      x = (0, 1, 2, [3, 4, 5,
                     6, 7, 8],
           9, 10, 11)
      '''
      it 'indents in nested lists when inner list is on a new line and a different type', ->
        editor.insertText 'x = (0, 1, 2, [3, 4, 5,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 15

        editor.insertText '6, 7, 8],\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(2)).toBe ' '.repeat 5

      '''
      x = {0: 0, 1: 1,
           2: 2, 3: 3}
      '''
      it 'indents dictionaries when multiple pairs are on the same line', ->
        editor.insertText 'x = {0: 0, 1: 1,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 5

      '''
      x = {0: 0, 1: 1,
           2: 2, 3: 3, 4: [4, 4,
                           4, 4]}
      '''
      it 'indents dictionaries with a list as a value', ->
        editor.insertText 'x = {0: 0, 1: 1,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 5

        editor.insertText '2: 2, 3: 3, 4: [4, 4,\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(2)).toBe ' '.repeat 21

      '''
      s = '[ will this \'break \( the parsing?'
      '''
      it 'does not indent with delimiters that are quoted', ->
        editor.insertText 's = \'[ will this \\\'break \( the parsing?\'\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ''

      '''
      x = ['here(\'(', 'is', 'a',
           'list', 'of', ['nested]',
                          'strings\\'],
           r'some \[\'[of which are raw',
           'and some of which are not']
      '''
      it 'knows when to indent when some delimiters are literal, and some are not', ->
        editor.insertText 'x = [\'here(\\\'(\', \'is\', \'a\',\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 5

        editor.insertText '\'list\', \'of\', [\'nested]\',\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(2)).toBe ' '.repeat 20

        editor.insertText '\'strings\\\\\'],\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(3)).toBe ' '.repeat 5

        editor.insertText 'r\'some \\[\\\'[of which are raw\',\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(4)).toBe ''

      '''
      def test(param_a, param_b, param_c,
               param_d):
          pass
      '''
      it 'indents normally when delimiter is closed', ->
        editor.insertText 'def test(param_a, param_b, param_c):\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 4

      '''
      def test(param_a,
               param_b,
               param_c):
          pass
      '''
      it 'keeps indentation on succeding open lines', ->
        editor.insertText 'def test(param_a,\n'
        pythonIndent.properlyIndent()
        editor.insertText 'param_b,\n'
        editor.autoIndentSelectedRows(2)
        expect(buffer.lineForRow(2)).toBe ' '.repeat 9

      '''
      class TheClass(object):
          def test(param_a, param_b,
                   param_c):
              a_list = ["1", "2", "3",
                        "4"]
      '''
      it 'allows for fluid indent in multi-level situations', ->
        editor.insertText 'class TheClass(object):\n'
        editor.autoIndentSelectedRows(1)
        editor.insertText 'def test(param_a, param_b,\n'
        pythonIndent.properlyIndent()
        editor.insertText 'param_c):\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(3)).toBe ' '.repeat 8

        editor.insertText 'a_list = ["1", "2", "3",\n'
        pythonIndent.properlyIndent()
        editor.insertText('"4"]\n')
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(5)).toBe ' '.repeat 8

    describe 'when unindenting after newline :: aligned with opening delimiter', ->
      it 'unindents after close def params', ->
        editor.insertText 'def test(param_a,\n'
        pythonIndent.properlyIndent()
        editor.insertText 'param_b):\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(2)).toBe ' '.repeat 4

      it 'unindents after close tuple', ->
        editor.insertText 'tup = (True, False,\n'
        pythonIndent.properlyIndent()
        editor.insertText 'False)\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(2)).toBe ''

      it 'unindents after close bracket', ->
        editor.insertText 'a_list = ["1", "2",\n'
        pythonIndent.properlyIndent()
        editor.insertText '"3"]\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(2)).toBe ''

      it 'unindents after close curly brace', ->
        editor.insertText 'a_dict = {0: 0}\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ''

  # Hanging
  describe 'hanging', ->

    describe 'when indenting after newline', ->

      '''
      def test(
          param_a
      )
      '''
      it 'hanging indents after open def params', ->
        editor.insertText 'def test(\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 4

      '''
      tup = (
          "elem"
      )
      '''
      it 'indents after open tuple', ->
        editor.insertText 'tup = (\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 4

      '''
      a_list = [
          "elem"
      ]
      '''
      it 'indents after open bracket', ->
        editor.insertText 'a_list = [\n'
        pythonIndent.properlyIndent()
        expect(buffer.lineForRow(1)).toBe ' '.repeat 4

      '''
      def test(
          param_a,
          param_b,
          param_c
      )
      '''
      it 'indents on succeding open lines', ->
        editor.insertText 'def test(\n'
        pythonIndent.properlyIndent()
        editor.insertText 'param_a,\n'
        editor.autoIndentSelectedRows(2)
        editor.insertText 'param_b,\n'
        editor.autoIndentSelectedRows(3)
        expect(buffer.lineForRow(3)).toBe ' '.repeat 4

      '''
      class TheClass(object):
          def test(
              param_a, param_b,
              param_c):
              a_list = [
                  "1", "2", "3",
                  "4"
              ]
      '''
      it 'allows for indent in multi-level situations', ->
        editor.insertText 'class TheClass(object):\n'
        editor.autoIndentSelectedRows(1)
        editor.insertText 'def test(\n'
        pythonIndent.properlyIndent()
        editor.insertText 'param_a, param_b,\n'
        editor.autoIndentSelectedRows(3)
        editor.insertText 'param_c):\n'
        editor.autoIndentSelectedRows(4)
        expect(buffer.lineForRow(4)).toBe ' '.repeat 4

        editor.insertText 'a_list = [\n'
        pythonIndent.properlyIndent()
        editor.insertText '"1", "2", "3",\n'
        editor.autoIndentSelectedRows(6)
        editor.insertText('"4"]\n')
        editor.autoIndentSelectedRows(7)
        expect(buffer.lineForRow(7)).toBe ' '.repeat 4
