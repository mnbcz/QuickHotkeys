
const { build } = require("esbuild");
const { solidPlugin } = require("esbuild-plugin-solid");

build({
  // Что компилировать.
  entryPoints: ["src/index.jsx"],
  bundle: true,
  // Где будет скомпилированный проект.
  outfile: "www/main.js",
  // Не минифицировать.
  minify: false,
  loader: {
    ".svg": "dataurl",
  },
  logLevel: "info",
  plugins: [solidPlugin()],
}).catch(() => process.exit(1));
