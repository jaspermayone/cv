# CV

This is my CV and is adapted from the [jitinnair1/autoCV](https://github.com/jitinnair1/autoCV) project.

![preview of the cv](https://cv.jaspermayone.com/jaspermayone-cv.jpeg)

### Setup

For this to work you need `latexmk` installed which can be done with `brew` on darwin:

```bash
brew install latexmk
```

then just run the following to rebuild the pdf each time you change something

```bash
make # build the pd
make clean # rm the latex steps
make distclean # rm the output
```
