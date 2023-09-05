Julia implementation of the [SunCalc](https://github.com/mourner/suncalc/) package for calculating sun position and sunlight phases 
(times for sunrise, sunset, dusk, etc.) for the given location and time.

Most calculations are based on the formulas given in the Astronomy Answers articles
about [position of the sun](https://www.aa.quae.nl/en/reken/zonpositie.html)
and [the planets](https://www.aa.quae.nl/en/reken/hemelpositie.html).
You can find more information on twilight phases calculated by SunCalc.jl
in the [Twilight article on Wikipedia](https://en.wikipedia.org/wiki/Twilight).

## Installation

```julia
using Pkg
pkg.add("SunCalc")
```