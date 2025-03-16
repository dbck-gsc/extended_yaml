
Extended features for YAML parsing.

## Features

#### Map merging

Maps can be merged from anchors using the map merge key. Explicitly provided keys take precedence.

```yaml
base_map: &base
  a: 1
  b: 2
  c: 7

other_map:
 <<: *base
 c: 3
```

The resulting structure of `other_map` is equivalent to

```yaml
other_map:
  a: 1
  b: 2
  c: 3
```

When maps merge using this syntax, the deep is merge rather than shallow.

```yaml
i_have_a_pet: &ref
  dog:
    name: 'Buttercup'
    age: 7
    breed: 'beagle'

i_have_one_too:
  <<: ref
  dog:
    name: 'Snoopy'
    sex: 'male'
```

Equivalent yaml:

```yaml
i_have_one_too:
  <<: ref
  dog:
    name: 'Snoopy'
    age: 7
    breed: 'beagle'
    sex: 'male'
```

#### Including files

External definitions can be included using an `include` key defining a string or list of strings.

```yaml
include: path/to/file.yaml
```

#### Limitations

Currently, include directives are not recursively resolved. Only the root yaml has includes processed.

## Usage

Pass the string-encoded yaml into `loadExtendedYaml`.

```dart

Future<String> fileContents = File('file.yaml').readAsString();
dynamic parsed = await loadExtendedYaml(await fileContents);

```
