// Theme toggle and a tiny syntax highlighter for <code class="rill">. No dependencies.
(function () {
  var root = document.documentElement;
  try {
    var saved = localStorage.getItem("rill-theme");
    if (saved === "light" || saved === "dark") root.setAttribute("data-theme", saved);
  } catch (e) {}

  function current() {
    var t = root.getAttribute("data-theme");
    if (t) return t;
    return window.matchMedia && matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }

  document.addEventListener("DOMContentLoaded", function () {
    var btn = document.querySelector(".theme-toggle");
    if (btn) {
      var label = function () { btn.textContent = current() === "dark" ? "Light" : "Dark"; };
      label();
      btn.addEventListener("click", function () {
        var next = current() === "dark" ? "light" : "dark";
        root.setAttribute("data-theme", next);
        try { localStorage.setItem("rill-theme", next); } catch (e) {}
        label();
      });
    }

    var kw = /^(fn|let|var|if|else|guard|for|in|while|return|switch|case|default|where|struct|enum|interface|import|pub|test|group|spawn|break|continue|inout|true|false|nil|self)$/;
    var token = /(\/\/[^\n]*)|("(?:\\.|[^"\\])*")|('(?:\\.|[^'\\])')|(\b\d[\d_]*(?:\.\d+)?\b)|([A-Za-z_][A-Za-z0-9_]*)/g;
    function esc(s) {
      return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }
    document.querySelectorAll("code.rill").forEach(function (el) {
      var src = el.textContent, out = "", last = 0, m;
      token.lastIndex = 0;
      while ((m = token.exec(src))) {
        out += esc(src.slice(last, m.index));
        var cls = m[1] ? "com" : m[2] || m[3] ? "str" : m[4] ? "num" :
          kw.test(m[5]) ? "kw" : /^[A-Z]/.test(m[5]) ? "type" : "";
        out += cls ? '<span class="tok-' + cls + '">' + esc(m[0]) + "</span>" : esc(m[0]);
        last = token.lastIndex;
      }
      el.innerHTML = out + esc(src.slice(last));
    });
  });
})();
