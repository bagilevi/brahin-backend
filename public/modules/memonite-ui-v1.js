console.log('ui module loaded');

(() => {
  const { loadScript, loadCss } = Memonite;
  const ui = Memonite.ui = {
    dialog: dialog,
  };

  loadJqueryUi().then(() => {
    // openSampleDialog()
  })

  function loadJqueryUi() {
    return Promise.all([
      loadScript('/jquery-ui/jquery-ui.min.js'),
      loadCss('/jquery-ui/jquery-ui.min.css'),
      loadCss('/jquery-ui/jquery-ui.structure.min.css'),
      loadCss('/jquery-ui/jquery-ui.theme.min.css'),
    ])
  }

  function dialog({ title, body} = {}) {
    const dialogEl = $('<div style="display: none"></div>')
    dialogEl.attr('title', title)
    dialogEl.html(body)

    $('body').append(dialogEl)
    dialogEl.dialog({
      autoOpen: false,
      classes: {
        "ui-dialog": "ui-memonite",
        "ui-dialog-titlebar": "ui-memonite",
      }
    })
    dialogEl.dialog('open')
  }

  function openSampleDialog() {
    dialog({
      title: "Hello",
      body: $('<h1>').html("Hello JQuery-UI")
    })
  }

})()
