# labs-contracts

Canonical OpenAPI and AsyncAPI contracts shared by labs in
[specmatic/labs](https://github.com/specmatic/labs).

## Layout

- `common/` contains deduplicated contracts reused by multiple labs.
- `openapi/` contains OpenAPI contracts grouped by lab or shared scenario.
- `asyncapi/` contains AsyncAPI contracts grouped by lab or shared scenario.
- Shared contracts are deduplicated here and referenced from lab `specmatic.yaml`
  files via a git source.
