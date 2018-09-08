console.log('init loaded');

require.config({
  baseUrl: MEMONITE_PLUGIN_PATH,
  paths: {
    'jquery': '/jquery/jquery-3.3.1.min',
    'lodash': '/lodash/lodash.min',
  }
})
console.log('MEMONITE_VERSION', MEMONITE_VERSION)

define([`/memonite-core-v${MEMONITE_VERSION}.js`], () => {

})
