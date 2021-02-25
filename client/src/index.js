import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";

const getWindowSize = () => ({
  x: window.innerWidth,
  y: window.innerHeight,
});

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: {
    path: window.location.pathname,
    size: getWindowSize(),
  },
});

window.onresize = () => {
  app.ports.windowSize.send(getWindowSize());
};

app.ports.pathChanged.subscribe((path) =>
  window.history.pushState(null, "Elm App", path)
);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
