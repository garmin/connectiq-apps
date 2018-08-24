# Semicircles
Garmin frequently stores latitude and longitude coordinates in a format we refer to as "semicircles." This is also the format for geographic positions that are stored in memory on Garmin GPS devices. This barrel provides an abstract coordinate type that internally uses a semicircles representation, does not use [Position](https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/Position.html) module, and does not require the Position permission.

## What is a Semicircle
Consider that [latitudes](https://en.wikipedia.org/wiki/Latitude) and [longitudes](https://en.wikipedia.org/wiki/Longitude) are both angular measures used in a system that is similar to a [spherical coordinate system](https://en.wikipedia.org/wiki/Spherical_coordinate_system) where _p_ is always equal to the radius of the Earth. 

Using this system provides a 2D coordinate system for the surface of the Earth, but uses real numbers to represent coordinates. Because of this, latitude and longitude are most readily stored as doubles. This can be costly in both RAM and computation time since Garmin devices frequently lack floating point co-processors.

Semicircle coordinates are used to address these problems on embedded devices. Instead of storing true, continuous angles, we store a discrete, fractional angle value. For example, longitude can theoretically divide the Equator into an infinite number of angular coordinates. Semicircles also divide the Equator into angular coordinates, but use a limited number of coordinates determined by how many bits can be devoted to storing a longitudinal value.

## Coordinate Class
This class uses 32-bit semicircles to represent positions, where `PI` (_&#960;_) radians are equal to `0x80000000` 32-bit semicircles. Semicircles handle wrap-around via integer overflow, and all angle math can be done using integer math, speeding up computation.

To convert from radians to semicircles, use the following formula:

 `angleInSemicircles = (angleInRadians * 0x80000000) / PI`

This class also includes a fast method to calculate the distance between two points.
