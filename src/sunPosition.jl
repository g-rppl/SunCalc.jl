
"""
    getSunPosition(time, lat lon; keep)

**Inputs**:

- `time`: Single or multiple `DateTime` or `ZonedDateTime`.
- `lat`: Single latitude.
- `lon`: Single longitude.
- `keep`: Vector of variables to keep. See Details.

**Returns**:

- `NamedTuple` or `DateFrame`.

**Details**:

Available variables are:

- `altitude`: sun altitude above the horizon in radians, 
    e.g. 0 at the horizon and PI/2 at the zenith (straight over your head)	
- `azimuth`: sun azimuth in radians 
    (direction along the horizon, measured from south to west), 
    e.g. 0 is south and Math.PI * 3/4 is northwest

"""
function getSunPosition(time::Union{DateTime,ZonedDateTime}, lat::Real, lon::Real;
    keep=[:altitude, :azimuth])

    available_var = [:altitude, :azimuth]

    @assert all(keep .∈ [available_var]) "
    $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

    if isa(time, ZonedDateTime)
        time = DateTime(time, UTC)
    end

    data = getPosition(time, lat, lon)

    return data[keep]
end

function getSunPosition(time::Union{Vector{DateTime},Vector{ZonedDateTime}}, 
    lat::Real, lon::Real; keep=[:altitude, :azimuth])

    available_var = [:altitude, :azimuth]

    @assert all(keep .∈ [available_var]) "
    $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

    time = map(x -> isa(x, ZonedDateTime) ? DateTime(x, UTC) : x, time)

    data = DataFrame(time=time, lat=lat, lon=lon)

    pos = DataFrame(getPosition.(data.time, data.lat, data.lon))

    data = hcat(data, pos[:, keep])

    return data
end