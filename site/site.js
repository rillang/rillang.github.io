// Theme toggle, a tiny syntax highlighter and heading anchors. No dependencies.
// Highlighted: <code class="rill"> on the website; on the documentation pages (Markdown,
// see _layouts/doc.html) fenced blocks tagged swift or rill (Rill code), text (output and
// shell sessions: "$ " lines are commands) and sh.
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

  function esc(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  var kw = /^(fn|let|var|if|else|guard|for|in|while|return|switch|case|default|where|struct|enum|interface|import|pub|test|group|spawn|break|continue|inout|extern|export|true|false|nil|self)$/;
  var token = /(\/\/[^\n]*)|("(?:\\.|[^"\\])*")|('(?:\\.|[^'\\])')|(\b\d[\d_]*(?:\.\d+)?\b)|([A-Za-z_][A-Za-z0-9_]*)/g;

  function rill(el) {
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
  }

  // output and sessions: commands ("$ ...") stand out from what they print
  function text(el) {
    el.innerHTML = el.textContent.split("\n").map(function (line) {
      return /^\$ /.test(line) ? '<span class="cmd">' + esc(line) + "</span>" : esc(line);
    }).join("\n");
  }

  var shToken = /((?:^|\s)#[^\n]*)|("(?:\\.|[^"\\])*"|'[^']*')/g;
  function sh(el) {
    var src = el.textContent, out = "", last = 0, m;
    shToken.lastIndex = 0;
    while ((m = shToken.exec(src))) {
      out += esc(src.slice(last, m.index));
      out += m[1] ? esc(m[1].match(/^\s*/)[0]) + '<span class="tok-com">' + esc(m[1].replace(/^\s*/, "")) + "</span>"
        : '<span class="tok-str">' + esc(m[0]) + "</span>";
      last = shToken.lastIndex;
    }
    el.innerHTML = out + esc(src.slice(last));
  }

  function each(sel, f) {
    document.querySelectorAll(sel).forEach(f);
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

    each("code.rill, .language-swift pre code, .language-rill pre code", rill);
    each(".language-text pre code", text);
    each(".language-sh pre code, .language-shell pre code", sh);

    each(".doc h2[id], .doc h3[id]", function (h) {
      var a = document.createElement("a");
      a.className = "anchor";
      a.href = "#" + h.id;
      a.setAttribute("aria-label", "Link to this section");
      a.textContent = "#";
      h.appendChild(a);
    });
  });
})();
