import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';
import devtools from 'solid-devtools/vite';

export default defineConfig({
  plugins: [
    /* 
    Uncomment the following line to enable solid-devtools.
    For more info see https://github.com/thetarnav/solid-devtools/tree/main/packages/extension#readme
    */
    devtools({
        /* features options - all disabled by default */
        autoname: true, // e.g. enable autoname
      }),
    // solidPlugin(),
    // solid
    solidPlugin({
        // currently HMR breaks displaying components
        // https://github.com/solidjs/solid-refresh/pull/41 will fix this
        hot: false,
    }),
  ],
  server: {
    port: 3000,
  },
  build: {
    target: 'esnext',
  },
});
