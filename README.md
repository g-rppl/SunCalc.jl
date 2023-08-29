# suncalc.jl

[![Coverage](https://codecov.io/gh/g-rppl/suncalc.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/g-rppl/suncalc.jl)
[![Build status](https://github.com/g-rppl/suncalc.jl/workflows/CI/badge.svg)](https://github.com/g-rppl/suncalc.jl/actions)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

Julia implementation of the [SunCalc](https://github.com/mourner/suncalc/) package for calculating sunlight phases (times for sunrise, sunset, dusk, etc.) for the given location and time.

Most calculations are based on the formulas given in the Astronomy Answers articles
about [position of the sun](https://www.aa.quae.nl/en/reken/zonpositie.html)
and [the planets](https://www.aa.quae.nl/en/reken/hemelpositie.html).
You can find more information on twilight phases calculated by suncalc.jl
in the [Twilight article on Wikipedia](https://en.wikipedia.org/wiki/Twilight).

## Installation

```julia
using Pkg
Pkg.add https://github.com/g-rppl/suncalc.jl.git
```

## Example

```julia
import suncalc
using Dates
getSunlightTimes(Date(2000,01,01), 54, 9)
getSunlightTimes(Date(2000,01,01), 54, 9; keep=[:sunrise, :sunset])

using TimeZones
getSunlightTimes(Date(2000,01,01), 54, 9, tz"UTC-3")

using DataFrames
days = collect(Date(2000,01,01):Day(1):Date(2000,12,31))
getSunlightTimes(days, 54, 9)
```

## Reference

### Sunlight times

Returns an object with the following properties (each is a `DateTime` or `ZonedDateTime` object):

| Property        | Description                                                              |
| --------------- | ------------------------------------------------------------------------ |
| `sunrise`       | sunrise (top edge of the sun appears on the horizon)                     |
| `sunriseEnd`    | sunrise ends (bottom edge of the sun touches the horizon)                |
| `goldenHourEnd` | morning golden hour (soft light, best time for photography) ends         |
| `solarNoon`     | solar noon (sun is in the highest position)                              |
| `goldenHour`    | evening golden hour starts                                               |
| `sunsetStart`   | sunset starts (bottom edge of the sun touches the horizon)               |
| `sunset`        | sunset (sun disappears below the horizon, evening civil twilight starts) |
| `dusk`          | dusk (evening nautical twilight starts)                                  |
| `nauticalDusk`  | nautical dusk (evening astronomical twilight starts)                     |
| `night`         | night starts (dark enough for astronomical observations)                 |
| `nadir`         | nadir (darkest moment of the night, sun is in the lowest position)       |
| `nightEnd`      | night ends (morning astronomical twilight starts)                        |
| `nauticalDawn`  | nautical dawn (morning nautical twilight starts)                         |
| `dawn`          | dawn (morning nautical twilight ends, morning civil twilight starts)     |
