import Elm from './src/Main.elm';
import './src/Main.css';

const app = Elm.Main.embed(document.querySelector('#app'));

const parse = html => {
  const parser = new DOMParser();
  const document = parser.parseFromString(html.trim(), 'text/html');
  if (document.body.childNodes.length === 0) {
    return {type: 'error', value: 'root node is empty'};
  }
  if (document.body.childNodes.length > 1) {
    return parse(`<div>${html}</div>`);
  }
  const firstChild = document.body.firstChild;
  if (firstChild.nodeType !== Node.ELEMENT_NODE) {
    return {type: 'error', value: 'root node is not an element'};
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
        };
        for (const name of node.getAttributeNames()) {
          ret.attributes.push({name, value: node.getAttribute(name)});
        }
        for (const childNode of node.childNodes) {
          ret.children.push(recur(childNode));
        }
        return ret;
      case Node.TEXT_NODE:
        return {type: 'text', value: node.nodeValue};
    }
  }

  return recur(firstChild);
};

app.ports.init.subscribe(() => {
  const html = ace.edit('html');
  html.session.setMode('ace/mode/html');
  html.getSession().on('change', function(e) {
    app.ports.receive.send(parse(html.getValue()));
  });

  const elm = ace.edit('elm');
  elm.session.setMode('ace/mode/elm');
});

app.ports.send.subscribe(elm => {
  const editor = ace.edit('elm');
  editor.setValue(elm);
  editor.clearSelection();
});
