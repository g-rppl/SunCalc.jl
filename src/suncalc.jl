module suncalc

using Dates
using TimeZones
using DataFrames

import Base: round
import TimeZones: astimezone

include("utilis.jl")

available_var = [:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
  :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
  :nightEnd, :night, :goldenHourEnd, :goldenHour]

"""
    getSunlightTimes(date::Date, lat::Number lon::Number, tz::FixedTimeZone= tz"UTC"; keep)

Inputs:

  - `date`: Single date or vector of dates.
  - `lat`: Single latitude.
  - `lon`: Single longitude.
  - `tz`: Timezone of results, defaults to UTC.
  - `keep`: Vector of variables to keep.

Returns:

  - 'NamedTuple' or 'DateFrame' of 'ZonedDateTime' Objects.

Available variables are:

  - `sunrise`: sunrise (top edge of the sun appears on the horizon)
  - `sunriseEnd`: sunrise ends (bottom edge of the sun touches the horizon)
  - `goldenHourEnd`: morning golden hour (soft light, best time for photography) ends
  - `solarNoon`: solar noon (sun is in the highest position)
  - `goldenHour`: evening golden hour starts
  - `sunsetStart`: sunset starts (bottom edge of the sun touches the horizon)
  - `sunset`: sunset (sun disappears below the horizon, evening civil twilight starts)
  - `dusk`: dusk (evening nautical twilight starts)
  - `nauticalDusk`: nautical dusk (evening astronomical twilight starts)
  - `night`: night starts (dark enough for astronomical observations)
  - `nadir`: nadir (darkest moment of the night, sun is in the lowest position)
  - `nightEnd`: night ends (morning astronomical twilight starts)
  - `nauticalDawn`: nautical dawn (morning nautical twilight starts)
  - `dawn`: dawn (morning nautical twilight ends, morning civil twilight starts)
"""
function getSunlightTimes(
  date::Date, lat::Number, lon::Number, tz::FixedTimeZone=tz"UTC";
  keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
    :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
    :nightEnd, :night, :goldenHourEnd, :goldenHour])

  @assert all(keep .∈ [available_var]) 
  "$(keep[Not(keep .∈ [available_var])]) is not a valid variable."

  data = getTimes(date, lat, lon)
  map(x -> astimezone(x, tz), data)

  return data[keep]
end

function getSunlightTimes(
  date::Vector{Date}, lat::Number, lon::Number, tz::FixedTimeZone=tz"UTC";
  keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
    :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
    :nightEnd, :night, :goldenHourEnd, :goldenHour]
)

  @assert all(keep .∈ [available_var])
  "$(keep[Not(keep .∈ [available_var])]) is not a valid variable."

  data = DataFrame(date=date,
    lat=lat,
    lon=lon)

  times = DataFrame(getTimes.(data.date, data.lat, data.lon))
  times .= astimezone.(times, tz)

  data = hcat(data, times[:, keep])

  return data
end

export getSunlightTimes

end  # module