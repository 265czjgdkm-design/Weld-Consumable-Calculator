# assets/

Drop the exported Rive splash animation here as:

```
assets/splash.riv
```

`lib/ui/splash_screen.dart` looks for that exact path at startup. If it's
not there (or fails to load), the app quietly falls back to the built-in
hand-coded animation — nothing breaks either way.
