# Install
#
#     bower install jsonml2html
#     npm install jsonml2html
#
#
# Simple conversion of jsonml to html
#
#     > jsonml2html.toString(["div", "hello world", ["img", {src: "smiley.png"}]]);
#     '<div>hello world<img src="smiley"></div>'
#
# Implicit class and id
#
#     > jsonml2html.toString(["div#root.red", "hello world", ["img.cool.im", {src: "smiley.png"}]]);
#     '<div id="root" class="red">hello world<img class="cool im" src="smiley"></div>'
#
# Inline style
#
#     > jsonml2html.toString(["div", {style: {background: "blue", fontSize: 16}}, "hello world"]);
#     '<div style="background:blue;font-size:16px">hello world</div>'
#
# Automatic escaping
#
#     > jsonml2html.toString(["div", "<blåbærgrød>"]);
#     '<div>&#60;bl&#229;b&#230;rgr&#248;d&#62;</div>'
#
# Raw html passthrough
#
#     > jsonml2html.toString(["script", ["rawhtml", "a<b"]]);
#     '<script>a<b</script>'
#
# Notics empty tags must have empty string content to emit endtag:
#
#     > jsonml2html.toString(["i.fa.fa-book"]); // WRONG
#     <i class="fa fa-book">
#     > jsonml2html.toString(["i.fa.fa-book",""]); // RIGHT
#     <i class="fa fa-book"></i>
#
#{{{1 Literate source code
#
#{{{2 Globals
#
# Define `isNodeJs` and `runTest` in such a way that they will be fully removed by `uglifyjs -mc -d isNodeJs=false -d runTest=false `
#
if typeof isNodeJs == "undefined" or typeof runTest == "undefined" then do ->
  root = if typeof global == "undefined" then window else global
  root.isNodeJs = (typeof window == "undefined") if typeof isNodeJs == "undefined"
  root.runTest = isNodeJs and process.argv[2] == "test" if typeof runTest == "undefined"

jsonml2html = if isNodeJs then exports else window.jsonml2html = {}
#{{{2 xmlEscape
xmlEscape = (str) -> String(str).replace RegExp("[\x00-\x1f\x80-\uffff&<>\"']", "g"), (c) -> "&##{c.charCodeAt 0};"

jsonml2html.xmlEscape = xmlEscape
#{{{2 obj2style
obj2style = (obj) ->
  (for key, val of obj
    key = key.replace /[A-Z]/g, (c) -> "-" + c.toLowerCase()
    val = "#{val}px" if typeof val == "number"
    "#{key}:#{val}"
  ).join ";"

jsonml2html.obj2style = obj2style
#{{{2 toString
toString = (arr) ->
  return "#{xmlEscape arr}" if !Array.isArray(arr)
  # raw html, useful for stuff which shouldn't be xmlescaped etc.
  return arr[1] if arr[0] == "rawhtml"
  # normalise jsonml, make sure it contains attributes
  arr = [arr[0], {}].concat arr.slice(1) if arr[1]?.constructor != Object
  attr = {}
  attr[key] = val for key, val of arr[1]
  # convert style objects to strings
  attr.style = obj2style attr.style if attr.style?.constructor == Object
  # shorthand for classes and ids
  tag = arr[0].replace /#([^.#]*)/, ((_, id) -> attr.id = id; "")
  tag = tag.replace /\.([^.#]*)/g, (_, cls) ->
    attr["class"] = if attr["class"] == undefined then cls else "#{attr["class"]} #{cls}"
    ""
  # create actual tag string
  result = "<#{tag}#{(" #{key}=\"#{xmlEscape val}\"" for key, val of attr).join ""}>"
  # add children and endtag, if there are children. `<foo></foo>` is done with `["foo", ""]`
  result += "#{arr.slice(2).map(toString).join ""}</#{tag}>" if arr.length > 2
  return result
jsonml2html.toString = toString


#{{{2 Test / examples
if runTest then process.nextTick ->
  assert = require "assert"
  jsonml = ["div.main",
      style:
        background: "red"
        textSize: 12
    ["h1#theHead.foo.bar", "Blåbærgrød"],
    ["img",
      src: "foo"
      alt: 'the "quoted"'],
    ["script", ["rawhtml", "console.log(foo<bar)"]]]
      
  assert.equal jsonml2html.toString(jsonml),
    """<div style="background:red;text-size:12px" class="main"><h1 id="theHead" class="foo bar">Bl&#229;b&#230;rgr&#248;d</h1><img src="foo" alt="the &#34;quoted&#34;"><script>console.log(foo<bar)</script></div>"""




