import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const TOKEN_KEY = "coconut-estate-token";

var app = Elm.Main.init({
  flags: window.localStorage.getItem(TOKEN_KEY),
});

// app.ports.setToken.subscribe(function(data) {
//   console.log(data);
//   // TODO: write to local storage
// });

registerServiceWorker();
