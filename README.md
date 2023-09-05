# SunCalc.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/g-rppl/SunCalc.jl/blob/main/LICENSE)
[![Coverage](https://codecov.io/gh/g-rppl/SunCalc.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/g-rppl/SunCalc.jl)
[![Build status](https://github.com/g-rppl/SunCalc.jl/workflows/CI/badge.svg)](https://github.com/g-rppl/SunCalc.jl/actions)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)


[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://g-rppl.github.io/SunCalc.jl/dev)

## About 

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
