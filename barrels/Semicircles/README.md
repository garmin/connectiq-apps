# Semicircles
At Garmin we frequently store latitude and longitude coordinates in a format that we refer to as "semicircles." This is also the format for geographic positions that are stored in memory on Garmin GPS devices. 

This barrel provides an abstract coordinate type that internally uses a semicircles representation. The Coordinate class does not use Position module and does not require the Position permission.

## What is a Semicircle

Consider that latitudes and longitudes are both angular measures used in a system that is similar to a spherical coordinate system where p is always equal to the radius of the Earth. For more information on lat/lons, see the Wikipedia article on spherical coordinates, or Latitude, or Longitude.

Using this system provides a 2D coordinate system for the surface of the Earth, but uses real numbers to represent coordinates. Because of this, lat and lon are most readily stored as doubles. On an embedded device this can be too expensive, both in RAM space and computation time, since our devices frequently lack floating point co-processors.

To address these problems the system of semicircle coordinates is used. The idea here is that instead of storing true continuous angles, we will store a discrete fractional angle value. With longitude, for instance, the Equator is divided into an infinite number of angular coordinates. With semicircles we still divide the Equator into angular coordinates, but now we use a limited number of coordinates. How many coordinates depends on how many bits can be devoted to storing a longitude.

## Coordinate Class

This class uses 32 bit semicircles, where PI radians are equal to 0x80000000 32 bit semicircles. Semicircles handle wrap-around via integer overflow, and all angle math can be done using integer math speeding up computation.

To convert from radians to semicircles, use the following formula:

  angleInSemicircles = (angleInRadians * 0x80000000) / Pi

This class also includes a function to compute distance between two points. The function trades accuracy for speed of computation.