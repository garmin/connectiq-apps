# Barrels
A collection of Connect IQ libraries. For more details on what Monkey Barrels are and how to define them, take a look at the [Monkey Barrels](https://developer.garmin.com/connect-iq/programmers-guide/monkey-barrels) section of the Programmer's Guide.

## Including Monkey Barrels
To include a Monkey Barrel in your project you need to declare a dependency on that Barrel within your Manifest file and then link to the Barrel within your project's Jungle file. See the [Programmer's Guide](https://developer.garmin.com/connect-iq/programmers-guide/monkey-barrels#how-to-include-barrels) for a detailed description of how to include Monkey Barrels in your project.

## Barrel Index

### LogMonkey
The [LogMonkey barrel](https://github.com/garmin/connectiq-apps/tree/master/barrels/LogMonkey) provides some basic logging utilities to aid in developing Connect IQ apps. Including LogMonkey within an app and building the app in release mode will automatically minimize the compiled output to save run time memory.

### Semicircles
The [Semicircles barrel](https://github.com/garmin/connectiq-apps/tree/master/barrels/Semicircles) provides an abstract coordinate type that speeds up position computation, does not use Position module, and does not require the Position permission. This class also includes a fast method to calculate the distance between two points.
