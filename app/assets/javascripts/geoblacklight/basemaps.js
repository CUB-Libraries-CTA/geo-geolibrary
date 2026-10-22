// GeoBlacklight 2.4 override: configurable basemaps backported from upstream PR #1957.
// Keep the 2.4 providers and defaults for compatibility.

GeoBlacklight.BasemapDefinitions = {
  darkMatter: {
    url: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{retina}.png',
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://carto.com/attributions">Carto</a>',
    maxZoom: 18,
    worldCopyJump: true,
    retina: '@2x',
    detectRetina: false
  },
  positron: {
    url: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{retina}.png',
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://carto.com/attributions">Carto</a>',
    maxZoom: 18,
    worldCopyJump: true,
    retina: '@2x',
    detectRetina: false
  },
  positronLite: {
    url: 'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{retina}.png',
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://carto.com/attributions">Carto</a>',
    maxZoom: 18,
    worldCopyJump: true,
    retina: '@2x',
    detectRetina: false
  },
  worldAntique: {
    url: 'https://cartocdn_{s}.global.ssl.fastly.net/base-antique/{z}/{x}/{y}{retina}.png',
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://carto.com/attributions">Carto</a>',
    maxZoom: 18,
    worldCopyJump: true,
    retina: '@2x',
    detectRetina: false
  },
  worldEco: {
    url: 'https://cartocdn_{s}.global.ssl.fastly.net/base-eco/{z}/{x}/{y}{retina}.png',
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://carto.com/attributions">Carto</a>',
    maxZoom: 18,
    worldCopyJump: true,
    retina: '@2x',
    detectRetina: false
  },
  flatBlue: {
    url: 'https://cartocdn_{s}.global.ssl.fastly.net/base-flatblue/{z}/{x}/{y}{retina}.png',
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://carto.com/attributions">Carto</a>',
    maxZoom: 18,
    worldCopyJump: true,
    retina: '@2x',
    detectRetina: false
  },
  midnightCommander: {
    url: 'https://cartocdn_{s}.global.ssl.fastly.net/base-midnight/{z}/{x}/{y}{retina}.png',
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://carto.com/attributions">Carto</a>',
    maxZoom: 18,
    worldCopyJump: true,
    retina: '@2x',
    detectRetina: false
  },
  openstreetmapHot: {
    url: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, Tiles courtesy of <a href="http://hot.openstreetmap.org/" target="_blank">Humanitarian OpenStreetMap Team</a>',
    maxZoom: 19,
    worldCopyJump: true,
    retina: '@2x',
    detectRetina: false
  },
  openstreetmapStandard: {
    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 19,
    worldCopyJump: true,
    retina: '@2x',
    detectRetina: false
  }
};

// Preserve the public layer registry for existing application customizations.
GeoBlacklight.Basemaps = {};
Object.keys(GeoBlacklight.BasemapDefinitions).forEach(function(name) {
  var definition = GeoBlacklight.BasemapDefinitions[name];
  GeoBlacklight.Basemaps[name] = L.tileLayer(definition.url, definition);
});
