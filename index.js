import Elm from './src/Main.elm';
import './src/Main.css';

const app = Elm.Main.embed(document.querySelector('#app'));

app.ports.init.subscribe(() => {
  const html = ace.edit('html');
  html.session.setMode('ace/mode/html');
  const elm = ace.edit('elm');
  elm.session.setMode('ace/mode/elm');
});
