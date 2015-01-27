# atgc-core-physics

pour le moment les objets imprimés atterissent en 0, 0, 0
à cause de oimo.js

## Limitations

About 500 objects

### To enable / disable physics:

```Javascript
app.assets['atgc-core-physics'].enabled = true;
```

### To change gravity:

```Javascript
app.assets['atgc-core-physics'].world.gravity.y = -9.80665; // useful values between -20 and +20
```
