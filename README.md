# Fidelity Check Template with JSON-Controlled Watermark

This version moves watermark settings into the JSON layout file.

Edit `config/check-layout-fidelity.json` under the `"watermark"` block:

```json
"watermark": {
  "text": "FIDELITY INVESTMENTS",
  "angle": 30,
  "opacity": 0.15,
  "size": 24,
  "x": 100,
  "y": 110
}
```

Run:
```bash
zef install PDF::Lite JSON::Fast
raku bin/make-fidelity-check.raku
```
