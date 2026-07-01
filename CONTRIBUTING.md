# Contributing Guide

## Development Standard

Every change should improve at least one of these:

- engineering clarity
- calculation trust
- report quality
- customer usability
- product readiness

## Rule Set

1. Do not expand scope without clear product value.
2. Keep calculation logic separate from UI.
3. Prefer technical language that a welding engineer would respect.
4. Technical drawings must explain geometry, not decorate it.
5. Every non-trivial UI or formula change should be covered by a test.

## Required Checks Before Merge

```bash
dart analyze
flutter test
flutter build web
```

## Pull Request Expectations

Each PR should state:

- what changed
- why it matters
- what was tested
- what risk remains

## Preferred Work Sequence

1. Review product goal
2. Inspect current behavior
3. Implement the smallest strong improvement
4. Verify in UI
5. Run checks
6. Update docs if the product behavior changed
