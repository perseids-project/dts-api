# DTS API

The Perseids Project implementation of the
[Distributed Text Services](https://distributed-text-services.github.io/specifications/)
(DTS) specification.

## Example usage

### GET /

```
curl 'http://localhost:3001/'
```

```json
{
  "@context":"dts/EntryPoint.jsonld",
  "@id":"/",
  "@type":"EntryPoint",
  "collections":"/collections",
  "documents":"/documents",
  "navigation":"/navigation"
}
```

### GET /collections

```
curl 'http://localhost:3001/collections?id=urn:cts:greekLit:tlg0016.tlg001.perseus-grc2'
```

```json
{
  "@id":"urn:cts:greekLit:tlg0016.tlg001.perseus-grc2",
  "@type":"Resource",
  "totalItems":0,
  "title":"Histories, Herodotus with an English translation",
  "description":"Herodotus, creator; Godley, Alfred Denis, 1856-1926, editor",
  "@context":{
    "@vocab":"https://www.w3.org/ns/hydra/core#",
    "dc":"http://purl.org/dc/terms/",
    "dts":"https://w3id.org/dts/api#"
  },
  "dts:passage":"/documents?id=urn%3Acts%3AgreekLit%3Atlg0016.tlg001.perseus-grc2",
  "dts:references":"/navigation?id=urn%3Acts%3AgreekLit%3Atlg0016.tlg001.perseus-grc2",
  "dts:download":"/documents?id=urn%3Acts%3AgreekLit%3Atlg0016.tlg001.perseus-grc2",
  "dts:citeDepth":3,
  "dts:citeStructure":[
    {
      "dts:citeType":"book",
      "dts:citeStructure":[
        {
          "dts:citeType":"chapter",
          "dts:citeStructure":[
            {
              "dts:citeType":"section"
            }
          ]
        }
      ]
    }
  ],
  "dts:dublincore":{
    "dc:title":[
      {
        "@language":"en",
        "@value":"Histories, Herodotus with an English translation"
      }
    ],
    "dc:description":[
      {
        "@language":"en",
        "@value":"Herodotus, creator; Godley, Alfred Denis, 1856-1926, editor"
      }
    ],
    "dc:language":"grc"
  }
}
```

### GET /navigation

```
curl 'http://localhost:3001/navigation?id=urn:cts:greekLit:tlg0016.tlg001.perseus-grc2'
```

```json
{
  "@context":{
    "@vocab":"https://www.w3.org/ns/hydra/core#",
    "dc":"http://purl.org/dc/terms/",
    "dts":"https://w3id.org/dts/api#"
  },
  "@id":"/navigation?groupBy=1&id=urn%3Acts%3AgreekLit%3Atlg0016.tlg001.perseus-grc2&level=1",
  "dts:citeDepth":3,
  "dts:level":1,
  "dts:passage":"/documents?id=urn%3Acts%3AgreekLit%3Atlg0016.tlg001.perseus-grc2{&ref}{&start}{&end}",
  "member":[
    {
      "ref":"1"
    },
    {
      "ref":"2"
    },
    {
      "ref":"3"
    },
    {
      "ref":"4"
    },
    {
      "ref":"5"
    },
    {
      "ref":"6"
    },
    {
      "ref":"7"
    },
    {
      "ref":"8"
    },
    {
      "ref":"9"
    }
  ]
}
```

### GET /documents

```
curl 'http://localhost:3001/documents?id=urn:cts:greekLit:tlg0016.tlg001.perseus-grc2&ref=1.1.0'
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0">
  <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
    <div type="textpart" subtype="section" n="0">
    <p>
    <milestone unit="para"/>Ἡροδότου Ἁλικαρνησσέος ἱστορίης ἀπόδεξις ἥδε, ὡς μήτε τὰ γενόμενα ἐξ ἀνθρώπων τῷ χρόνῳ ἐξίτηλα γένηται, μήτε ἔργα μεγάλα τε καὶ θωμαστά, τὰ μὲν Ἕλλησι τὰ δὲ βαρβάροισι ἀποδεχθέντα, ἀκλεᾶ γένηται, τά τε ἄλλα καὶ διʼ ἣν αἰτίην ἐπολέμησαν ἀλλήλοισι.</p>
    </div>
  </dts:fragment>
</TEI>
```

## Installation

### Requirements

* Docker
* Docker Compose

### Setup

* `docker-compose build`
* `docker-compose run app rails db:create db:migrate`
* `docker-compose run app rails texts:download`
* `docker-compose run app rails texts:import`

### Configuration

The texts that are processed and served through the API are configured
in `config/application.rb`:

```ruby
config.dts_collections = [
  { match: /^urn:cts:latinLit:/, title: 'Latin', urn: 'urn:perseids:latinLit' },
  { match: /^urn:cts:greekLit:/, title: 'Ancient Greek', urn: 'urn:perseids:greekLit' },
  { match: /^urn:cts:farsiLit:/, title: 'Farsi', urn: 'urn:perseids:farsiLit' },
  { match: /^urn:cts:hebrewlit:/, title: 'Hebrew', urn: 'urn:perseids:hebrewLit' },
  { match: /^urn:cts:ancJewLit:/, title: 'Hebrew', urn: 'urn:perseids:hebrewLit' },
  { match: //, title: 'Other', urn: 'urn:perseids:otherLit' },
]

config.dts_repositories = [
  { name: 'csel-dev', url: 'https://github.com/OpenGreekAndLatin/csel-dev' },
  { name: 'canonical-pdlrefwk', url: 'https://github.com/PerseusDL/canonical-pdlrefwk' },
  { name: 'First1KGreek', url: 'https://github.com/OpenGreekAndLatin/First1KGreek' },
  { name: 'priapeia', url: 'https://github.com/lascivaroma/priapeia' },
  { name: 'ancJewLitCTS', url: 'https://github.com/hlapin/ancJewLitCTS' },
  { name: 'canonical-latinLit', url: 'https://github.com/PerseusDL/canonical-latinLit' },
  { name: 'canonical-greekLit', url: 'https://github.com/PerseusDL/canonical-greekLit' },
  { name: 'canonical-farsiLit', url: 'https://github.com/PerseusDL/canonical-farsiLit' },
  { name: 'canonical-pdlpsci', url: 'https://github.com/PerseusDL/canonical-pdlpsci' },
]
```

`config.dts_collections` configures the top-level collections
and `config.dts_repositories` specifies what Git repositories the
text is pulled from.

## Running the application

* `docker-compose up`

Visit `localhost:3000` to access the Rails application directly
or visit `localhost:3001` to hit the cache (which uses Nginx).

### Including in other compose files

The instructions above are for building the Docker image locally. You can use
a prebuilt image by including `perseidsproject/dts-api` as one of your services in
`docker-compose.yml`.
A simple configuration is:

```yaml
version: '3'
services:
  db:
    image: postgres
    ports:
      - 5434:5432
  app:
    image: perseidsproject/dts-api
    command: bundle exec rails server -b 0.0.0.0 -p 3000
    ports:
      - 3000:3000
    environment:
      - DATABASE_URL=postgres://postgres@db
    links:
      - db
```

(See project on [Docker Hub](https://hub.docker.com/r/perseidsproject/dts-api/).)

## Bugs and feature requests

For any bugs or feature requests, please create
[a GitHub issue](https://github.com/perseids-tools/dts-api/issues).
