console.log("init")

var Memonite = {
  editors: []
};

(() => {

  const loadScript = Memonite.loadScript = (url) => {
    return new Promise((resolve, reject) => {
      $.ajax({
        url: url,
        dataType: 'script',
        success: resolve,
        async: true
      });
    })
  }

  const loadCss = Memonite.loadCss = (url) => {
    return new Promise((resolve, reject) => {
      const linkEl = $('<link>').attr('rel', 'stylesheet').attr('href', url).attr('type', 'text/css')
      linkEl.get(0).onload = resolve
      $('head').append(linkEl)
    })
  }

  const debounce = Memonite.debounce = function(func, wait, immediate) {
    var timeout;
    return function() {
      var context = this, args = arguments;
      var later = function() {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  };

  const saveResource = (path, id, body) => {
    $.ajax({
      url: path,
      method: 'patch',
      data: {
        authenticity_token: authenticityToken,
        body: body,
      }
    })
  }

  $(document).ready(() => {
    const $el = $('.m-resource').first()
    const resourceId = $el.data('m-id')
    const resourceUrl = window.location.href
    const resourcePath = window.location.pathname
    const editorName = $el.data('m-editor')
    console.log('loading', name)

    loadScript(`/assets/ui.js`, () => {})

    loadScript(`/assets/${editorName}.js`).then(() => {
      console.log('loaded')
      const editor = Memonite.editors[editorName]
      const onChange = (newBody) => {
        console.log('change', newBody)
        saveResource(resourcePath, resourceId, newBody)
      }
      const debouncedOnChange = Memonite.debounce(onChange, 1000)
      editor.init($el, debouncedOnChange)
    })
  })

})();
