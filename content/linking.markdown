---
title : OS-X Linking
category : tutorial
---

Compiling GNU/Linux Programs on OS X
------------------------------------
This does not have much to do with mathematics, but it is important and
obscure.

This is a somewhat obscure difference in how the linker behaves on Darwin. To
get GNU/Linux-style behavior, one must add the linker flag

```
-undefined dynamic_lookup
```

to the environment variable

```
LDFLAGS
```

to get the right result.
