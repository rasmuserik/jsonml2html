#{{{1 Actual code
require("platformenv").define global if typeof isNodeJs != "boolean"
jsonml2html = exports
if isNodeJs
  jsonml2html.about =
    title: "jsonml2html"
    description: "Converts sugared jsonml into html strings"
    npmjs: true
    webjs: true

#{{{2 xmlEscape
jsonml2html.xmlEscape = (str) -> String(str).replace RegExp("[\x00-\x1f\x80-\uffff&<>\"']", "g"), (c) -> "&##{c.charCodeAt 0};"
#{{{2 obj2style
jsonml2html.obj2style = (obj) ->
  (for key, val of obj
    key = key.replace /[A-Z]/g, (c) -> "-" + c.toLowerCase()
    val = "#{val}px" if typeof val == "number"
    "#{key}:#{val}"
  ).join ";"
#{{{2 jsonml2html
jsonml2html.jsonml2html = (arr) ->
  return "#{jsonml2html.xmlEscape arr}" if !Array.isArray(arr)
  # raw html, useful for stuff which shouldn't be xmlescaped etc.
  return arr[1] if arr[0] == "rawhtml"
  # normalise jsonml, make sure it contains attributes
  arr = [arr[0], {}].concat arr.slice(1) if arr[1]?.constructor != Object
  attr = {}
  attr[key] = val for key, val of arr[1]
  # convert style objects to strings
  attr.style = jsonml2html.obj2style attr.style if attr.style?.constructor == Object
  # shorthand for classes and ids
  tag = arr[0].replace /#([^.#]*)/, ((_, id) -> attr.id = id; "")
  tag = tag.replace /\.([^.#]*)/g, (_, cls) ->
    attr["class"] = if attr["class"] == undefined then cls else "#{attr["class"]} #{cls}"
    ""
  # create actual tag string
  result = "<#{tag}#{(" #{key}=\"#{jsonml2html.xmlEscape val}\"" for key, val of attr).join ""}>"
  # add children and endtag, if there are children. `<foo></foo>` is done with `["foo", ""]`
  result += "#{arr.slice(2).map(jsonml2html.jsonml2html).join ""}</#{tag}>" if arr.length > 2
  return result


