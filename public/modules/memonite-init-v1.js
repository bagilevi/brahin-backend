console.log('init module loaded');

(() => {
  const Memonite = window.Memonite = {
    editors: [],
    loadScript,
    loadCss,
    debounce,
    initResourceEditor,
    isUrl,
  }

  const { display } = Memonite;

  $(document).ready(() => {
    Promise.all([
      loadScript('/modules/memonite-ui-v1.js'),
      loadScript('/modules/memonite-linking-v1.js'),
      loadScript('/modules/memonite-spa-v1.js'),
    ]).then(() => {
      initResourceEditorFromDocument()
    }).catch((err) => {
      console.error('Could not load all modules, editor cannot be initialized.')
    })
  })


  // Find the main resource on the page and load its editor
  function initResourceEditorFromDocument() {
    const el = $('.m-resource').first()
    const resource = {
      id: el.data('m-id'),
      url: window.location.href,
      path: window.location.pathname,
      editor: el.data('m-editor'),
      editor_url: el.data('m-editor-url'),
      body: el.html(),
    }
    initResourceEditor(resource, el)
  }

  function initResourceEditor(resource, el) {
    loadScript(getEditorUrl(resource)).then(() => {
      const editor = Memonite.editors[resource.editor]
      if (!editor) {
        throw new Error(`Script loaded from "${resource.editor_url}" expected to define editor "${resource.editor}"`)
      }
      const onChange = (newBody) => {
        if (newBody != resource.body) {
          console.log('change', newBody)
          resource.body = newBody
          saveResource(resource, { body: newBody })
        }
      }
      const debouncedOnChange = Memonite.debounce(onChange, 1000)
      editor.init(el, debouncedOnChange)
    })
  }

  function saveResource(resource, updatedAttributes) {
    const data = _.assign({ authenticity_token: authenticityToken }, updatedAttributes)

    $.ajax({
      url: resource.path,
      method: 'patch',
      data: data
    })
  }

  var scripts = {}

  function loadScript(url) {
    if (!url) throw new Error('blank url given to loadScript')
    var s = scripts[url];
    if (s) return Promise.resolve();
    return new Promise((resolve, reject) => {
      $.ajax({
        url: url,
        dataType: 'script',
        success: () => {
          scripts[url] = true;
          resolve();
        },
        error: (jqXHR, textStatus, errorThrown) => {
          console.error(`loadScript(${url})`, '$.ajax failed', textStatus, errorThrown)
          reject(errorThrown)
        },
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

  function getEditorUrl(resource) {
    const { editor, editor_url } = resource;
    if (editor_url) return editor_url;
    if (!editor) throw new Error('resource does not have "editor" property')
    return `/assets/${editor}.js`
  }

})();
