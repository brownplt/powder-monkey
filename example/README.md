This folder contains a basic 'assignment' which is evaluated using [evaluate-many.sh](../evaluate/evaluate-many.sh). This example is a guideline. The layout of the [corpus](./corpus) folder is optimized for showcasing the variety of execution results and keeping [evaluate-example.sh](./evaluate-example.sh) simple and does not necessarily reflect a good layout for storing student submissions.

The contents of the [result](./result) folder are produced by executing:

```
$ ./evaluate-example.sh /path/to/pyret-lang
```

Make sure you have modified [evaluate.sh](../evaluate/evaluate.sh#L4) such that `PATH` includes an appropriate version of node.

