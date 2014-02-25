// Generated by CoffeeScript 1.6.3
(function() {
  var jsonml2html, obj2style, toString, xmlEscape;

  if (typeof isNodeJs === "undefined" || typeof runTest === "undefined") {
    (function() {
      var root;
      root = typeof global === "undefined" ? window : global;
      if (typeof isNodeJs === "undefined") {
        root.isNodeJs = typeof window === "undefined";
      }
      if (typeof runTest === "undefined") {
        return root.runTest = isNodeJs && process.argv[2] === "test";
      }
    })();
  }

  jsonml2html = isNodeJs ? exports : window.jsonml2html = {};

  xmlEscape = function(str) {
    return String(str).replace(RegExp("[\x00-\x1f\x80-\uffff&<>\"']", "g"), function(c) {
      return "&#" + (c.charCodeAt(0)) + ";";
    });
  };

  jsonml2html.xmlEscape = xmlEscape;

  obj2style = function(obj) {
    var key, val;
    return ((function() {
      var _results;
      _results = [];
      for (key in obj) {
        val = obj[key];
        key = key.replace(/[A-Z]/g, function(c) {
          return "-" + c.toLowerCase();
        });
        if (typeof val === "number") {
          val = "" + val + "px";
        }
        _results.push("" + key + ":" + val);
      }
      return _results;
    })()).join(";");
  };

  jsonml2html.obj2style = obj2style;

  toString = function(arr) {
    var attr, key, result, tag, val, _ref, _ref1, _ref2;
    if (!Array.isArray(arr)) {
      return "" + (xmlEscape(arr));
    }
    if (arr[0] === "rawhtml") {
      return arr[1];
    }
    if (((_ref = arr[1]) != null ? _ref.constructor : void 0) !== Object) {
      arr = [arr[0], {}].concat(arr.slice(1));
    }
    attr = {};
    _ref1 = arr[1];
    for (key in _ref1) {
      val = _ref1[key];
      attr[key] = val;
    }
    if (((_ref2 = attr.style) != null ? _ref2.constructor : void 0) === Object) {
      attr.style = obj2style(attr.style);
    }
    tag = arr[0].replace(/#([^.#]*)/, (function(_, id) {
      attr.id = id;
      return "";
    }));
    tag = tag.replace(/\.([^.#]*)/g, function(_, cls) {
      attr["class"] = attr["class"] === void 0 ? cls : "" + attr["class"] + " " + cls;
      return "";
    });
    result = "<" + tag + (((function() {
      var _results;
      _results = [];
      for (key in attr) {
        val = attr[key];
        _results.push(" " + key + "=\"" + (xmlEscape(val)) + "\"");
      }
      return _results;
    })()).join("")) + ">";
    if (arr.length > 2) {
      result += "" + (arr.slice(2).map(toString).join("")) + "</" + tag + ">";
    }
    return result;
  };

  jsonml2html.toString = toString;

  if (runTest) {
    process.nextTick(function() {
      var assert, jsonml;
      assert = require("assert");
      jsonml = [
        "div.main", {
          style: {
            background: "red",
            textSize: 12
          }
        }, ["h1#theHead.foo.bar", "Blåbærgrød"], [
          "img", {
            src: "foo",
            alt: 'the "quoted"'
          }
        ], ["script", ["rawhtml", "console.log(foo<bar)"]]
      ];
      return assert.equal(jsonml2html.toString(jsonml), "<div style=\"background:red;text-size:12px\" class=\"main\"><h1 id=\"theHead\" class=\"foo bar\">Bl&#229;b&#230;rgr&#248;d</h1><img src=\"foo\" alt=\"the &#34;quoted&#34;\"><script>console.log(foo<bar)</script></div>");
    });
  }

}).call(this);
