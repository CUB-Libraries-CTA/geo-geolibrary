//= require geoblacklight/viewers/viewer

// CUBL - GeoBlacklight 2.4 override: selectBasemap backported from upstream PR #1957.
GeoBlacklight.Viewer.Map = GeoBlacklight.Viewer.extend({

  options: {
    /**
    * Initial bounds of map
    * @type {L.LatLngBounds}
    */
    bbox: [[-82, -144], [77, 161]],
    opacity: 0.75
  },

  overlay: L.layerGroup(),

  load: function() {
    if (this.data.mapBbox) {
      this.options.bbox = L.bboxToBounds(this.data.mapBbox);
    }
    this.map = L.map(this.element).fitBounds(this.options.bbox);

    // Add initial bbox to map element for easier testing
    if (this.map.getBounds().isValid()) {
      this.element.setAttribute('data-js-map-render-bbox', this.map.getBounds().toBBoxString());
    }

    this.map.addLayer(this.selectBasemap());
    this.map.addLayer(this.overlay);
    if (this.data.map !== 'index') {
      this.addBoundsOverlay(this.options.bbox);
    }
  },

  /**
   * Add a bounding box overlay to map.
   * @param {L.LatLngBounds} bounds Leaflet LatLngBounds
   */
  addBoundsOverlay: function(bounds) {
    if (bounds instanceof L.LatLngBounds) {
      this.overlay.addLayer(L.polygon([
        bounds.getSouthWest(),
        bounds.getSouthEast(),
        bounds.getNorthEast(),
        bounds.getNorthWest()
      ]));
    }
  },

  /**
   * Remove bounding box overlay from map.
   */
  removeBoundsOverlay: function() {
    this.overlay.clearLayers();
  },

  /**
  * Selects basemap if specified in data options, if not return positron.
  *
  * Applications can change a basemap's URL -- to add a CARTO API key, for
  * example -- or define basemaps of their own by setting LEAFLET.BASEMAPS in
  * settings.yml. Those values are merged over the shipped definition, so an
  * override that gives only a url keeps the shipped attribution and zoom.
  */
  selectBasemap: function() {
    var name = this.data.basemap || 'positron';
    var options = this.data.leafletOptions || {};
    var overrides = options.BASEMAPS || {};
    var definition;

    // URL-only overrides retain the shipped attribution and layer options.
    if (overrides[name]) {
      definition = L.extend(
        {}, GeoBlacklight.BasemapDefinitions[name], overrides[name]
      );
      if (definition.url) {
        return L.tileLayer(definition.url, definition);
      }
    }

    // Preserve application replacements of the public layer registry.
    return GeoBlacklight.Basemaps[name] || GeoBlacklight.Basemaps.positron;
  }
});
