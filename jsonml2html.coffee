#!/usr/bin/env coffee
require("platformenv").define global if typeof isNodeJs != "boolean"
if isNodeJs 
  exports.about =
    title: "jsonml2html"
    description: "..."
    html5:
      css: [
        "//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.min.css"
        "//netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css"
      ]
      js: [
        "//code.jquery.com/jquery-1.10.2.min.js"
        "//netdna.bootstrapcdn.com/bootstrap/3.0.3/js/bootstrap.min.js"
      ]
      files: [
      ]
    dependencies:
      solapp: "*"

#{{{1 Main
exports.main = (opt) ->
  opt.setStyle {h1: {backgroundColor: "green"}}
  opt.setContent ["div", ["h1", "hello world"]]
  opt.done()