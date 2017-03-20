# kargos

A Plasma port of [Argos](https://github.com/p-e-w/argos/blob/master/README.md) and [BitBar plugins](https://github.com/matryer/bitbar-plugins) to fast create
custom plasmoids.

Note: This is a alpha project. By now, it only was tested on Kubuntu 16.04 LTS.

## What is implemented

- Basic menu level.
- "href" attribute.
- "bash" attribute.
- "size" attribute.
- "iconName" attribute (it should be a valid KDE icon name)
- HTML support. Only the subset [supported by QML](http://doc.qt.io/qt-5/richtext-html-subset.html).
- Interval detection on the command filename.

## Installation

```
git clone git@github.com:lipido/kargos.git
cd kargos
plasmapkg2 -t plasmoid --install .plasmoid
```

That's all. You can add the a kargo plasmoid to your panel. You have to configure 
it to indicate the command or executable.

