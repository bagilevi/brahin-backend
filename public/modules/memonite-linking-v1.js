console.log('linking module loaded');

(() => {
  const { loadScript, loadCss, initResourceEditor } = Memonite;
  const linking = Memonite.linking = {
    followLink,
    getLinkPropertiesForInsertion,
  };

  window.onpopstate = onPopState

  function followLink(link) {
    if (!Memonite.spa) {
      console.warn('spa not defined => followLink reverting to page load')
      location.href = link.href;
      return;
    }
    const stateObj = { };
    console.log('pushState', stateObj, link.href, link)
    history.pushState(stateObj, '', link.href);
    replaceResourceByCurrentLocation()
  }

  function replaceResourceByCurrentLocation() {
    // Load resource from the backend // TODO: or cache
    $.ajax({
      url: location.href + '.json',
      method: 'get',
      dataType: 'json',
      success: (resource) => {
        resource.url = location.href
        console.log('backend returned', resource)
        Memonite.spa.showResource(resource)
      }
    })
  }

  function onPopState(stateObj) {
    console.log('popState', stateObj)
    if (!Memonite.spa) {
      console.warn('spa not defined => onPopState reverting to page load')
      location.href = location.href;
      return;
    }
    replaceResourceByCurrentLocation();
  }

  function getLinkPropertiesForInsertion() {
    return new Promise((resolve, reject) => {
      var label;
      Memonite.ui.prompt('Link label:').then((label) => {
        if (!label || label === '') return;

        const defaultHref = `/${label.toLowerCase().replace(/[^a-z0-9-]/g, '-')}`
        // const defaultHref = `${Math.random().toString(36).substring(2)}`
        Memonite.ui.prompt('Target URL or href', defaultHref).then((href) => {
          resolve({
            label: label,
            href: href,
          })
        })
      })
    })
  }
})()
