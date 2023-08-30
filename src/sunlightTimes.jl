
available_var = [:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
  :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
  :nightEnd, :night, :goldenHourEnd, :goldenHour]

"""
    getSunlightTimes(date, lat lon, tz; keep)

**Inputs**:

  - `date`: Single or multiple dates.
  - `lat`: Single or multiple latitudes.
  - `lon`: Single or multiple longitudes.
  - `tz`: Timezone of results, defaults to UTC.
  - `keep`: Vector of variables to keep.

**Returns**:

  - `NamedTuple` or `DateFrame` of `DateTime` or `ZonedDateTime` objects.

**Available variables are**:

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
  date::Date, lat::Real, lon::Real;
  keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
    :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
    :nightEnd, :night, :goldenHourEnd, :goldenHour])

  @assert all(keep .∈ [available_var]) "
  $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

  data = getTimes(date, lat, lon)

  return data[keep]
end

function getSunlightTimes(
  date::Date, lat::Real, lon::Real, tz::TimeZone;
  keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
    :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
    :nightEnd, :night, :goldenHourEnd, :goldenHour])

  @assert all(keep .∈ [available_var]) "
  $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

  data = getTimes(date, lat, lon)
  data = map(x -> ZonedDateTime(x, tz), data)

  return data[keep]
end

function getSunlightTimes(
  date::Union{Date,Vector{Date}},
  lat::Union{Real,Vector{<:Real}},
  lon::Union{Real,Vector{<:Real}};
  keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
    :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
    :nightEnd, :night, :goldenHourEnd, :goldenHour]
)

  @assert length(lat) == length(lon) "
  Latitude and Longitude must be of equal length."

  if length(lat) > 1
    @assert typeof(date) == Date || length(date) == length(lat) "
    For more than one Location, Date must be either length 1 
    or the same as Latitude/Longitude."
  end

  @assert all(keep .∈ [available_var]) "
  $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

  data = DataFrame(date=date, lat=lat, lon=lon)

  times = DataFrame(getTimes.(data.date, data.lat, data.lon))

  data = hcat(data, times[:, keep])

  return data
end

function getSunlightTimes(
  date::Union{Date,Vector{Date}},
  lat::Union{Real,Vector{<:Real}},
  lon::Union{Real,Vector{<:Real}},
  tz::TimeZone;
  keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
    :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
    :nightEnd, :night, :goldenHourEnd, :goldenHour]
)

  @assert length(lat) == length(lon) "
  Latitude and Longitude must be of equal length."

  if length(lat) > 1
    @assert typeof(date) == Date || length(date) == length(lat) "
    Date must be either length 1 or the same as Latitude/Longitude."
  end

  @assert all(keep .∈ [available_var]) "
  $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

  data = DataFrame(date=date, lat=lat, lon=lon)

  times = DataFrame(getTimes.(data.date, data.lat, data.lon))
  times = astimezone.(ZonedDateTime.(times, tz"UTC"), tz)

  data = hcat(data, times[:, keep])

  return data
end