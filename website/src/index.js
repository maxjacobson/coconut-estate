import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const TOKEN_KEY = "coconut-estate-token";

var flags = {
  currentUserToken: window.localStorage.getItem(TOKEN_KEY),
  apiUrl: process.env.ELM_APP_API_URL,
};

var app = Elm.Main.init({
  flags,
});

// app.ports.saveToken.subscribe(function(data) {
//   window.localStorage.setItem(TOKEN_KEY, data);
// });

// app.ports.clearToken.subscribe(function(_data) {
//   window.localStorage.removeItem(TOKEN_KEY);
// });

registerServiceWorker();
