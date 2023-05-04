# Contributing

Pull requests are most welcome.

This project does not aim to duplicate Orca and Front50 schema.
Functions must only provide minimal defaults that match Deck. Users can extend
or override output via jsonnet composition.

## Validating Changes

There is no published schema for applications or pipelines so everything is
reverse engineered based off creating pipelines with the UI (Deck microservice).

Adding jsonnet `assert ...`, and `error ...` conditions to each function is
onerous and brittle. See the `kube-libsonnet` project for good usage of these
features.

There are three strategies for validating json:

### Local file diff

Render jsonnet to json:

```
jsonnet example.jsonnet > example.json
```

Change file:

```
vim example.jsonnet
```

Render jsonnet to a different json file:

```
jsonnet example.jsonnet > example2.json
```

Diff files:

```
diff example.json example2.json
```

### API Loop

Render jsonnet to json:

```
jsonnet example.jsonnet > example.json
```

Submit to Spinnaker API:

```
spin application save --application-name example --file example.json
```

Retrieve from Spinnaker API:

```
spin pipeline get --application example --name deploy --quiet > example_got.json
```

Compare output

```
diff example.json example_got.json
```

### Deck UI

1. Render jsonnet to json.
1. Copy json into a new or existing pipeline in Deck.
1. Check if Deck displayes the pipeline structure as intended.
1. Check if Deck changes anything such as adding default values or formatting.
   After saving the pipeline you can compare the Deck json to your rendered
   json.
1. Check if the pipeline executes.
