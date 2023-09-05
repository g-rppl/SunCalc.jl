var documenterSearchIndex = {"docs":
[{"location":"functions/#Sun-position","page":"Functions","title":"Sun position","text":"","category":"section"},{"location":"functions/","page":"Functions","title":"Functions","text":"SunCalc.getSunPosition","category":"page"},{"location":"functions/#SunCalc.getSunPosition","page":"Functions","title":"SunCalc.getSunPosition","text":"getSunPosition(\n    time::Union{DateTime,ZonedDateTime}\n    lat::Real,\n    lon::Real;\n    keep=[:altitude, :azimuth])\n\nCalculate the sun position for the given time and location. Return a NamedTuple     or DataFrame.\n\nAvailable variables:\n\nVariable Description\naltitude sun altitude above the horizon in radians, e.g. 0 at the horizon and π/2 at the zenith (straight over your head).\nazimuth sun azimuth in radians (direction along the horizon, measured from south to west), e.g. 0 is south and π * 3/4 is northwest.\n\nExamples\n\njulia> using Dates, SunCalc\njulia> getSunPosition(DateTime(2000, 07, 01, 12, 00, 00), 54, 9.0)\n(altitude = 1.021444013872015, azimuth = 0.23904867335099955)\n\n\n\n\n\n","category":"function"},{"location":"functions/#Sun-light-times","page":"Functions","title":"Sun light times","text":"","category":"section"},{"location":"functions/","page":"Functions","title":"Functions","text":"SunCalc.getSunlightTimes","category":"page"},{"location":"functions/#SunCalc.getSunlightTimes","page":"Functions","title":"SunCalc.getSunlightTimes","text":"getSunlightTimes(\n    date::Date, \n    lat::Real,\n    lon::Real,\n    tz::TimeZone; \n    keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,\n    :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,\n    :nightEnd, :night, :goldenHourEnd, :goldenHour])\n\nCalculate sunlight times for the given date and location. Return a NamedTuple      or DataFrame.\n\nAvailable variables:\n\nVariable Description\nsunrise sunrise (top edge of the sun appears on the horizon)\nsunriseEnd sunrise ends (bottom edge of the sun touches the horizon)\ngoldenHourEnd morning golden hour (soft light, best time for photography) ends\nsolarNoon solar noon (sun is in the highest position)\ngoldenHour evening golden hour starts\nsunsetStart sunset starts (bottom edge of the sun touches the horizon)\nsunset sunset (sun disappears below the horizon, evening civil twilight starts)\ndusk dusk (evening nautical twilight starts)\nnauticalDusk nautical dusk (evening astronomical twilight starts)\nnight night starts (dark enough for astronomical observations)\nnadir nadir (darkest moment of the night, sun is in the lowest position)\nnightEnd night ends (morning astronomical twilight starts)\nnauticalDawn nautical dawn (morning nautical twilight starts)\ndawn dawn (morning nautical twilight ends, morning civil twilight starts)\n\nExamples\n\njulia> using Dates, SunCalc\njulia> getSunlightTimes(Date(2000, 07, 01), 54, 9; keep=[:sunrise, :sunset])\n(sunrise = DateTime(\"2000-07-01T02:57:50\"), sunset = DateTime(\"2000-07-01T20:00:20\"))\n\njulia> using TimeZones\njulia> getSunlightTimes(Date(2000, 07, 01), 54, 9, tz\"UTC-3\"; keep=[:sunrise, :sunset])\n(sunrise = ZonedDateTime(2000, 7, 1, 2, 57, 50, tz\"UTC-03:00\"), \nsunset = ZonedDateTime(2000, 7, 1, 20, 0, 20, tz\"UTC-03:00\"))\n\njulia> using DataFrames\njulia> days = collect(Date(2000, 07, 01):Day(1):Date(2000, 12, 31))\njulia> getSunlightTimes(days, 54, 9)\n184×17 DataFrame\n[...]\n\n\n\n\n\n","category":"function"},{"location":"#About","page":"Getting started","title":"About","text":"","category":"section"},{"location":"","page":"Getting started","title":"Getting started","text":"Julia implementation of the SunCalc package for calculating sun position and sunlight phases  (times for sunrise, sunset, dusk, etc.) for the given location and time.","category":"page"},{"location":"","page":"Getting started","title":"Getting started","text":"Most calculations are based on the formulas given in the Astronomy Answers articles about position of the sun and the planets. You can find more information on twilight phases calculated by SunCalc.jl in the Twilight article on Wikipedia.","category":"page"},{"location":"#Installation","page":"Getting started","title":"Installation","text":"","category":"section"},{"location":"","page":"Getting started","title":"Getting started","text":"using Pkg\npkg.add(\"SunCalc\")","category":"page"}]
}
