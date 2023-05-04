# spin-libsonnet - Spinnaker Jsonnet

Spinnaker application, pipeline and projects as code, inspired by
[kube-libsonnet](https://github.com/bitnami-labs/kube-libsonnet).

NOTE: this is a different take to the upstream library:
[spinnaker/sponnet](https://github.com/spinnaker/sponnet)

## Getting started

Install dependencies:

```shell
go install github.com/google/go-jsonnet/cmd/jsonnet@latest
go install github.com/google/go-jsonnet/cmd/jsonnetfmt@latest
go install github.com/google/go-jsonnet/cmd/jsonnet-lint@latest
go install github.com/spinnaker/spin@latest
```

Create working directory:

```shell
mkdir -p tutorial
cd tutorial/
```

Create application:

```shell
cat <<EOF > myapp.jsonnet
local spin = import '../spin.libsonnet';

spin.application('myapp', 'me@example.com')
EOF

# render jsonnet to json
jsonnet myapp.jsonnet > myapp.json
```

Optionally save application to Spinnaker:

```shell
spin application save --application-name myapp --file myapp.json
```

Create pipeline with a Wait stage:

```shell
cat <<EOF > mypipeline.jsonnet
local spin = import '../spin.libsonnet';

spin.pipeline('mypipeline', 'myapp') + {
  stages+: [
    spin.wait(),
  ],
}
EOF

# render jsonnet to json
jsonnet mypipeline.jsonnet > mypipeline.json
```

Optionally save pipeline to Spinnaker:

```shell
spin pipeline save --file mypipeline.json
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Alternatives

There are other Spinnaker pipeline solutions available:

- [Shore](https://github.com/Autodesk/shore/)
- [Foremast](https://github.com/foremast/foremast)
- Terraform
- [Sponnet](https://github.com/spinnaker/sponnet)
- Proprietary or non-OSS inside companies

### Why not sponnet

Initially we assisted with the sponnet project and used it to generate all
applications and pipelines. Each pipeline looked something like the example
pipeline in the sponnet repository.

This client-side pipeline templating was a good improvement from our previous
`roer` pipeline templating but presented challenges.

For our platform team, making changes to all pipeline files was tedious. This
was a common occurrence as we added new target accounts and other pipeline
functionality.

For our product teams, changing an application name and updating artifact names
was awkward. We declared these variables at the top of the file, but the entire
pipeline complexity was exposed. This was at odds with our desire to scale our
platform team sublinearly and enable product teams to self service.

We decided to approach the problem from first principles and looked around for
inspiration with the following requirements:

- client-side templating that enables a git workflow
- supports a simple DSL for product teams with ability to extend
- uses jsonnet composition (`myObject+: { newKey: someValue }`) to enable
  adhoc extension or replacement anywhere in json object (explorable compexity)
- basic constructors of common elements

#### Builder Pattern vs Composition

The Sponnet library (application.libsonnet, pipeline.libsonnet) resembles the
one of the largest open source jsonnet projects around; Ksonnet.

The Ksonnet library uses a `object.withKey1(value),withKey2(value)`
[builder pattern](https://dzone.com/articles/creational-design-patterns-builder-pattern),
chaining attributes together.

This has two main drawbacks:

1. duplication of key names in function definitions: with**Key1**(**Key1**)
1. referencing other keys within a `.with...()` method is hard to follow.

See the below contrast between a `builder` pattern and jsonnet composition.

```jsonnet
{
  local doSomeConvention(v) = std.asciiUpper(v),

  // builder pattern
  object():: {
    key1: 'some-default-value',
    withKey1(key1):: self + { key1: key1 },
    withKey2(key2):: self + { key2: key2 },
  },

  myObject: $.object()  // plus chained values below
            .withKey1('some value')  // overwrite default
            .withKey2(doSomeConvention($.myObject.key1)) // full path required!
            { key3: 'extra value' }, // still possible to compose


  // composition pattern
  object2:: {
    key1: 'some-default-value',
  },
  myObject2: $.object2 {
    key1: 'some override value',  // overwrite default
    key2: doSomeConvention(self.key1), // use of self keyword
    key3: 'extra value',
  },

}
```

Builder example: https://github.com/grafana/jsonnet-libs/blob/master/oauth2-proxy/oauth2-proxy.libsonnet

Composition example: https://github.com/bitnami-labs/kube-libsonnet/blob/master/examples/wordpress/frontend.jsonnet
