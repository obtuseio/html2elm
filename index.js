import Elm from './src/Main.elm';
import './src/Main.css';

const app = Elm.Main.embed(document.querySelector('#app'));

app.ports.init.subscribe(() => {
  const html = ace.edit('html');
  html.session.setMode('ace/mode/html');
  html.getSession().on('change', function(e) {
    app.ports.receive.send(html.getValue());
  });

  const elm = ace.edit('elm');
  elm.session.setMode('ace/mode/elm');
});
