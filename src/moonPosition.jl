
"""
    getMoonPosition(
        time::Union{DateTime,ZonedDateTime},
        lat::Real,
        lon::Real;
        keep=[:altitude, :azimuth, :distance, :parallacticAngle])

Calculate the sun position for the given time and location. Return a `NamedTuple`
    or `DataFrame`.

Available variables:

| Variable           | Description                                |
| :----------------- | :----------------------------------------- |
| `altitude`         | Moon altitude above the horizon in radians |
| `azimuth`          | Moon azimuth in radians                    |
| `distance`         | Distance to moon in kilometres             |
| `parallacticAngle` | Parallactic angle of the moon in radians   |


# Examples 
```julia	
using Dates, SunCalc
getMoonPosition(DateTime(2000, 07, 01, 12, 00, 00), 54, 9)

getMoonPosition(now(), 54, 9; keep=[:altitude])
```
"""
function getMoonPosition(
    time::Union{DateTime,ZonedDateTime},
    lat::Real,
    lon::Real;
    keep=[:altitude, :azimuth, :distance, :parallacticAngle])
  
  available_var  = [:altitude, :azimuth, :distance, :parallacticAngle]

  @assert all(keep .∈ [available_var]) "
  $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

  if isa(time, ZonedDateTime)
      time = DateTime(time, UTC)
  end

  data = moonPosition(time, lat, lon)

  return data[keep]
end

function getMoonPosition(
    time::Union{Vector{DateTime},Vector{ZonedDateTime}},
    lat::Real,
    lon::Real;
    keep=[:altitude, :azimuth, :distance, :parallacticAngle])

    available_var = [:altitude, :azimuth, :distance, :parallacticAngle]

    @assert all(keep .∈ [available_var]) "
    $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

    time = map(x -> isa(x, ZonedDateTime) ? DateTime(x, UTC) : x, time)

    data = DataFrame(time=time, lat=lat, lon=lon)

    pos = DataFrame(moonPosition.(data.time, data.lat, data.lon))

    data = hcat(data, pos[:, keep])

    return data
end