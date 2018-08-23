console.log("init")

var Memonite;

(() => {
  Memonite = {
    editors: [],
    loadScript,
    loadCss,
    debounce,
  }

  $(document).ready(() => {
    loadScript('/assets/ui.js')
    initResourceEditor()
  })

  // Find the main resource on the page and load its editor
  function initResourceEditor() {
    const $el = $('.m-resource').first()
    const resourceId = $el.data('m-id')
    const resourceUrl = window.location.href
    const resourcePath = window.location.pathname
    const editorName = $el.data('m-editor')
    const editorUrl = $el.data('m-editor-url') || `/assets/${editorName}.js`
    console.log('loading', name)

    loadScript(editorUrl).then(() => {
      console.log('loaded')
      const editor = Memonite.editors[editorName]
      const onChange = (newBody) => {
        console.log('change', newBody)
        saveResource(resourcePath, resourceId, newBody)
      }
      const debouncedOnChange = Memonite.debounce(onChange, 1000)
      editor.init($el, debouncedOnChange)
    })
  }

  function saveResource(path, id, body) {
    $.ajax({
      url: path,
      method: 'patch',
      data: {
        authenticity_token: authenticityToken,
        body: body,
      }
    })
  }

  function loadScript(url) {
    return new Promise((resolve, reject) => {
      $.ajax({
        url: url,
        dataType: 'script',
        success: resolve,
        async: true
      });
    })
  }

  function loadCss(url) {
    return new Promise((resolve, reject) => {
      const linkEl = $('<link>').attr('rel', 'stylesheet').attr('href', url).attr('type', 'text/css')
      linkEl.get(0).onload = resolve
      $('head').append(linkEl)
    })
  }

  function debounce(func, wait, immediate) {
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

  function isUrl(s) {
    return s.startsWith('http:') || s.startsWith('https:')
  }
})();
