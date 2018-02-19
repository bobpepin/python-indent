`atom/src/text-mate-language-mode.js`
```python
suggestedIndentForBufferRow (bufferRow, tabLength, options)
suggestedIndentForLineAtBufferRow (bufferRow, line, tabLength) 
suggestedIndentForEditedBufferRow (bufferRow, tabLength) 
```

`atom/src/tree-sitter-language-mode.js`
```python

 /*
  Section - Indentation
  */

  suggestedIndentForLineAtBufferRow (row, line, tabLength) {
    return this._suggestedIndentForLineWithScopeAtBufferRow(
      row,
      line,
      this.rootScopeDescriptor,
      tabLength
    )
  }

  suggestedIndentForBufferRow (row, tabLength, options) {
    return this._suggestedIndentForLineWithScopeAtBufferRow(
      row,
      this.buffer.lineForRow(row),
      this.rootScopeDescriptor,
      tabLength,
      options
    )
  }

// TODO: Remove this once TreeSitterLanguageMode implements its own auto-indent system.
[
  '_suggestedIndentForLineWithScopeAtBufferRow',
  'suggestedIndentForEditedBufferRow',
  'increaseIndentRegexForScopeDescriptor',
  'decreaseIndentRegexForScopeDescriptor',
  'decreaseNextIndentRegexForScopeDescriptor',
  'regexForPattern'
].forEach(methodName => {
  module.exports.prototype[methodName] = TextMateLanguageMode.prototype[methodName]
})
```
