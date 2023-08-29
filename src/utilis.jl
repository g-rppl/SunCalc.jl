
round(x::Missing, r::Type{Second}) = missing
astimezone(zdt::Missing, tz::FixedTimeZone) = missing

function toDays(date::Date)
    J2000 = 2451545
    return datetime2julian(DateTime(date)) - J2000
end

function todatetime(f::Union{Number,Missing})
    d = ismissing(f) ? missing : ZonedDateTime(julian2datetime(f), tz"UTC")
    return d
end

function rightAscension(l::Float64, b::Float64)
    e = (pi / 180) * 23.4397
    return atan2(sin(l) * cos(e) - tan(b) * sin(e), cos(l))
end


function declination(l::Float64, b::Float64)
    e = (pi / 180) * 23.4397
    return asin(sin(b) * cos(e) + cos(b) * sin(e) * sin(l))
end


function solarMeanAnomaly(d::Float64)
    return (pi / 180) * (357.5291 + 0.98560028 * d)
end


function eclipticLongitude(m::Float64)
    # Equation of center
    C = (pi / 180) * (1.9148 * sin(m) + 0.02 * sin(2 * m) + 0.0003 * sin(3 * m))
    # Perihelion of the Earth
    P = (pi / 180) * 102.9372
    return m + C + P + pi
end


# Calculations for sun times
function julianCycle(d::Number, lw::Float64)
    return round(d - 0.0009 - lw / (2 * pi))
end

function approxTransit(ht::Union{Float64,Missing}, lw::Float64, n::Float64)
    return 0.0009 + (ht + lw) / (2 * pi) + n
end

function solarTransitJ(ds::Union{Float64,Missing}, m::Float64, l::Float64)
    J2000 = 2451545
    return J2000 + ds + 0.0053 * sin(m) - 0.0069 * sin(2 * l)
end

function hourAngle(h::Float64, phi::Float64, d::Float64)
    tmp = (sin(h) - sin(phi) * sin(d)) / (cos(phi) * cos(d))
    return abs(tmp) <= 1 ? acos(tmp) : missing
end

# Returns set time for the given sun altitude
function getSetJ(h::Float64, lw::Float64, phi::Float64, dec::Float64,
    n::Float64, m::Float64, l::Float64)
    w = hourAngle(h, phi, dec)
    a = approxTransit(w, lw, n)
    return solarTransitJ(a, m, l)
end

# Calculates sun times for a given date and latitude/longitude
function getTimes(date::Date, lat::Number, lng::Number)

    rad = (pi / 180)
    lw = rad * -lng
    phi = rad * lat

    d = toDays(date)
    n = julianCycle(d, lw)
    ds = approxTransit(0.0, lw, n)

    M = solarMeanAnomaly(ds)
    L = eclipticLongitude(M)
    dec = declination(L, 0.0)

    Jnoon = solarTransitJ(ds, M, L)

    result = (solarNoon=todatetime(Jnoon),
        nadir=todatetime(Jnoon - 0.5),
        sunrise=todatetime(Jnoon - (getSetJ(-0.833 * rad, lw, phi, dec, n, M, L) - Jnoon)),
        sunset=todatetime(getSetJ(-0.833 * rad, lw, phi, dec, n, M, L)),
        sunriseEnd=todatetime(Jnoon - (getSetJ(-0.3 * rad, lw, phi, dec, n, M, L) - Jnoon)),
        sunsetStart=todatetime(getSetJ(-0.3 * rad, lw, phi, dec, n, M, L)),
        dawn=todatetime(Jnoon - (getSetJ(-6 * rad, lw, phi, dec, n, M, L) - Jnoon)),
        dusk=todatetime(getSetJ(-6 * rad, lw, phi, dec, n, M, L)),
        nauticalDawn=todatetime(Jnoon - (getSetJ(-12 * rad, lw, phi, dec, n, M, L) - Jnoon)),
        nauticalDusk=todatetime(getSetJ(-12 * rad, lw, phi, dec, n, M, L)),
        nightEnd=todatetime(Jnoon - (getSetJ(-18 * rad, lw, phi, dec, n, M, L) - Jnoon)),
        night=todatetime(getSetJ(-18 * rad, lw, phi, dec, n, M, L)),
        goldenHourEnd=todatetime(Jnoon - (getSetJ(6 * rad, lw, phi, dec, n, M, L) - Jnoon)),
        goldenHour=todatetime(getSetJ(6 * rad, lw, phi, dec, n, M, L))
    )

    return map(x -> round(x, Dates.Second), result)
end
