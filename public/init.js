console.log('init loaded');

require.config({
  baseUrl: "/modules/",
  paths: {
    'jquery': '/jquery/jquery-3.3.1.min',
    'lodash': '/lodash/lodash.min',
  }
})

define(['/memonite-core-v0.2.1.js'], () => {

})
