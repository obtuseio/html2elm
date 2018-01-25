import Elm from './src/Main.elm';
import './src/Main.css';
import './node_modules/semantic-ui-css/components/button.css';
import './node_modules/semantic-ui-css/components/site.css';

const app = Elm.Main.embed(document.querySelector('#app'));

const parse = html => {
  const parser = new DOMParser();
  const document = parser.parseFromString(html.trim(), 'text/html');
  const childNodes = document.body.childNodes;
  if (
    childNodes.length === 0 ||
    childNodes.length > 1 ||
    childNodes[0].nodeType !== Node.ELEMENT_NODE
  ) {
    return parse(`<div>${html}</div>`);
  }

  function recur(node) {
    switch (node.nodeType) {
      case Node.COMMENT_NODE:
        return {type: 'comment', value: node.nodeValue};
      case Node.ELEMENT_NODE:
        const ret = {
          type: 'element',
          name: node.nodeName.toLowerCase(),
          attributes: [],
          children: [],
          styles: [],
        };
        for (const name of node.getAttributeNames()) {
          ret.attributes.push({name, value: node.getAttribute(name)});
        }
        for (const childNode of node.childNodes) {
          ret.children.push(recur(childNode));
        }
        for (const name of node.style) {
          ret.styles.push({name, value: node.style[name]});
        }
        return ret;
      case Node.TEXT_NODE:
        return {type: 'text', value: node.nodeValue};
    }
  }

  return recur(childNodes[0]);
};

app.ports.init.subscribe(() => {
  const html = ace.edit('html');
  html.session.setMode('ace/mode/html');
  // Disable warnings.
  html.session.setUseWorker(false);
  html.setShowPrintMargin(false);
  html.getSession().on('change', function(e) {
    app.ports.receive.send(parse(html.getValue()));
  });

  requestAnimationFrame(() => {
    html.setValue(`<div id=container class=column style="display: flex; font-size: 14px;">
  <header>
    <a href="/">Home</a>
    <a href="/contact-us">Contact Us</a>
  </header>
    <main class=column>
      <!-- TODO: Make this a <label>. -->
      Name: <input required>
      <!-- This one too. -->
      Message: <textarea required rows=25 cols=80 data-validate=".{10,}"></textarea>
    </main>
    <footer class=row>
      <!-- Do we really need this? -->
      &copy; ${new Date().getFullYear()}
    </footer>
</div>`);
    html.clearSelection();
  });

  const elm = ace.edit('elm');
  elm.session.setMode('ace/mode/elm');
  elm.setReadOnly(true);
  elm.setShowPrintMargin(false);
});

app.ports.send.subscribe(elm => {
  const editor = ace.edit('elm');
  editor.setValue(elm);
  editor.clearSelection();
});
