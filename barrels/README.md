# Barrels
A collection of Connect IQ libraries.

## Semicircles
This barrel provides an abstract coordinate type that internally uses a semicircles representation.
The Coordinate class does not use Position module and does not require the Position permission.

This class uses 32 bit semicircles, where PI radians are equal to 0x80000000 32 bit semicircles.
Semicircles handle wrap-around via integer overflow, and all angle math can be done using integer math
speeding up computation. This class also includes a fast distance between two point computation.