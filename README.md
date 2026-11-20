# GeoLibrary

GeoLibrary is the University of Colorado Boulder Libraries' geospatial discovery
application, built on GeoBlacklight. It provides search, map previews, metadata,
and access to geospatial datasets.

Solr stores searchable catalog metadata; GeoServer provides map and data services 
referenced by catalog records. These services are deployed separately from the Rails 
application.

## Configuration

Supply environment variables through your shell or the EKS deployment's
configuration and secrets. Do not commit credentials or local `.env` files.

| Variable | Purpose / default |
| --- | --- |
| `SOLR_URL` | Solr core URL used by Rails and sitemap generation. Defaults to `http://127.0.0.1:8983/solr/blacklight-core`; set explicitly in EKS. |
| `SITE_URL` | Absolute public hostname used when generating sitemaps. Always set explicitly for generation. |
| `SECRET_KEY_BASE` | Rails production secret; supply at runtime. Docker build placeholder values are only for compilation and boot checks. |
| `CARTO_API_KEY` | Optional CARTO basemap key, read at application boot. |
| `RAILS_ENV` | Rails environment; the Docker image sets `production`, including for the EKS test deployment. |
| `RAILS_LOG_TO_STDOUT` | Enables container logging to standard output; set by the Dockerfile. |
| `PORT` | Puma listening port; defaults to `3000`. |
| `RAILS_MAX_THREADS` | Puma thread count and SQLite connection pool size; defaults to `5`. |
| `EMAIL_FROM`, `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_USERNAME`, `EMAIL_PASSWORD` | SMTP configuration when email delivery is used. |

## Docker and EKS deployment

Build the full application image from the repository root:

```sh
docker build --no-cache=true -t culibraries/geolibrary:version .
```

[Dockerfile](Dockerfile) installs dependencies and compiles assets in its build
stage. The runtime image excludes Node.js and Yarn, disables runtime asset
compilation, and sets `EXECJS_RUNTIME=Disabled`. A build check boots production
Rails and verifies that a JavaScript runtime is not present. No live Solr or
GeoServer connection is needed to generate assets; sitemap generation is a
separate operation.

[Dockerfile-basemaps](Dockerfile-basemaps) is a temporary overlay based on
`culibraries/geolibrary:2.0.12`. It copies only the catalog controller and header
partial. Use the full Dockerfile for dependency, asset, sitemap, and runtime
changes.

Publish the image to the registry used by EKS and update the deployment's image
reference through your deployment workflow. Supply the environment-specific
Solr URL and Rails secret, and configure ingress/service routing to port 3000.
Deployment manifests and registry automation are not included in this repository.

The [container entrypoint](bin/docker-entrypoint.sh) runs
`bundle exec rails db:schema:load` before starting Rails. SQLite supports
Blacklight internally; login, guest accounts, bookmarks, and search history are
disabled in this application. The entrypoint recreates the schema on every
container start, so this database must not be used for persistent user data.
Catalog metadata remains in the external Solr service.

After deployment, check the home page, a catalog search, a record page, and a map
preview. When deploying sitemaps, also verify `/robots.txt`, `/sitemap.xml`, and
every compressed sitemap referenced by the index.

## Sitemaps

The catalog changes infrequently, so generate sitemaps when catalog URLs or the
site hostname change, then include the files in the deployment image. ***Generation
is not part of the Docker build or container startup, and no recurring job is
installed.***

The generator reads only `layer_slug_s` from Solr in batches of 1,000. It includes
the home page, About page, and catalog record URLs; it does not crawl the website
or contact GeoServer.

### Generate for an environment

Run from a checkout with dependencies installed and network access to Solr, or
from `/app` in a running GeoBlacklight pod using a shell. Replace the example
Solr hostname with the reachable core URL for that environment.

Production:

```sh
RAILS_ENV=production \
SITE_URL=https://geo.colorado.edu \
SOLR_URL=http://production-solr:8983/solr/blacklight-core \
  bundle exec rake sitemap:refresh:no_ping
```

In a pod with `SOLR_URL` already configured, keep that existing value instead of
using the example hostname. Both deployed environments use `RAILS_ENV=production`;
`SITE_URL` determines the hostname written into the XML.

Output is written to `public/`:

- `sitemap.xml`: uncompressed index pointing to the numbered sitemap files.
- `sitemap1.xml.gz`: compressed page URLs.
- `sitemap2.xml.gz`, etc.: additional files if the catalog needs splitting.

XML on one line is normal. Inspect a compressed sitemap with:

```sh
gzip -dc public/sitemap1.xml.gz
```

Both environments write to the same filenames. Generate in separate checkouts or
save each set before generating the other environment. A generated sitemap's
hostname is fixed; changing `SITE_URL` at runtime does not modify existing files.

### Preserve files generated in EKS

Files generated inside a pod are available only in that pod unless the directory
uses shared storage. They are lost when the pod is replaced. To include the
output in future images, copy it back to your local checkout before replacement.
For this static catalog, committing the production sitemap files is a simple way
to include them in clean builds.

Replacing sitemap files in a running pod normally needs no web server restart.
To distribute files bundled into an image, deploy that new image to all replicas.
If an older version is still served, check browser and proxy caching.

## Basemaps

The selected basemap is currently `positron` in `app/controllers/catalog_controller.rb`. 
This application backports configurable Leaflet basemap URLs from 
[GeoBlacklight PR #1957](https://github.com/geoblacklight/geoblacklight/pull/1957) to GeoBlacklight 2.4.

Set `CARTO_API_KEY` in the runtime environment to configure authenticated URLs for
`positron`, `positronLite`, and `darkMatter`. The key is URL-encoded by
`config/settings.yml`. Unset, empty, or whitespace-only values leave
GeoBlacklight's shipped URLs in place. Obtain a key through
[CARTO](https://carto.com/basemaps/apikey/); it is visible to browsers in tile
requests.

For local container runs, pass an exported key using `--env CARTO_API_KEY`.
For EKS, supply it in the deployment environment. Changing the key requires
restarting/recreating the application pods; asset rebuilding is not required.

Overrides under `LEAFLET.BASEMAPS` merge with shipped provider options, preserving
attribution, zoom limits, and retina settings unless explicitly overridden.
Additional providers require a URL and should include attribution. Unknown
provider names fall back to Positron.

The overrides live under `app/assets/javascripts/geoblacklight/`; the viewer
manifest ensures Sprockets loads them before viewer subclasses. Review these
backports when upgrading GeoBlacklight.

## Project references

- [GeoBlacklight source at v2.4.0](https://github.com/geoblacklight/geoblacklight/tree/v2.4.0)
