# Barrels
A collection of Connect IQ libraries. For more details on what Monkey Barrels are and how to define
them checkout the [Monkey Barrels](https://developer.garmin.com/connect-iq/programmers-guide/monkey-barrels)
section of the Programmer's Guide.

## Including Monkey Barrels
To include a Monkey Barrel in your project you need to declare a dependency on that Barrel within
your Manifest file and then link to the Barrel within your project's Jungle file. See the
[Programmer's Guide](https://developer.garmin.com/connect-iq/programmers-guide/monkey-barrels#how-to-include-barrels)
for a detailed description of how to include Monkey Barrels in your project.

## Barrel Index

### LogMonkey
The [LogMonkey barrel](https://github.com/garmin/connectiq-apps/tree/master/barrels/LogMonkey)
provides some basic logging utilities to aid in developing Connect IQ apps. Inclusions of the
LogMonkey within an app will automatically be compiled out or minimized when building a release
version of the app.

### Semicircles
The [Semicircles barrel](https://github.com/garmin/connectiq-apps/tree/master/barrels/Semicircles)
provides an abstract coordinate type that internally uses a semicircles representation.
The Coordinate class does not use Position module and does not require the Position permission.

This class uses 32 bit semicircles, where PI radians are equal to 0x80000000 32 bit semicircles.
Semicircles handle wrap-around via integer overflow, and all angle math can be done using integer math
speeding up computation. This class also includes a fast distance between two point computation.