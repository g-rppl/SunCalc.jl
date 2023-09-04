
function toDays(date::Union{Date,DateTime})
    J2000 = 2451545
    return datetime2julian(DateTime(date)) - J2000
end

function toDateTime(j::Union{Real,Missing})
    return ismissing(j) ? missing : julian2datetime(j)
end


ϵ = (π / 180) * 23.4397 # obliquity of the Earth
rightAscension(l::Real, b::Real) = atan(sin(l) * cos(ϵ) - tan(b) * sin(ϵ), cos(l))
declination(l::Real, b::Real) = asin(sin(b) * cos(ϵ) + cos(b) * sin(ϵ) * sin(l))


function azimuth(hm::Real, ϕ::Real, dec::Real)
    return atan(sin(hm), cos(hm) * sin(ϕ) - tan(dec) * cos(ϕ))
end

function altitude(hm::Real, ϕ::Real, dec::Real)
    return asin(sin(ϕ) * sin(dec) + cos(ϕ) * cos(dec) * cos(hm))
end

function siderealTime(d::Real, lw::Real)
    return (π / 180) * (280.16 + 360.9856235 * d) - lw
end


function solarMeanAnomaly(d::Real)
    return (π / 180) * (357.5291 + 0.98560028 * d)
end


function eclipticLongitude(m::Real)
    # Equation of center
    C = (π / 180) * (1.9148 * sin(m) + 0.02 * sin(2 * m) + 0.0003 * sin(3 * m))
    # Perihelion of the Earth
    P = (π / 180) * 102.9372
    return m + C + P + π
end

function sunCoords(d::Real)
    m = solarMeanAnomaly(d)
    l = eclipticLongitude(m)
    return (dec=declination(l, 0.0), ra=rightAscension(l, 0.0))
end


# Calculate sun position for a given date and latitude/longitude
function getPosition(time::DateTime, lat::Real, lon::Real)

    lw = (π / 180) * -lon
    ϕ = (π / 180) * lat
    d = toDays(time)

    c = sunCoords(d)
    hm = siderealTime(d, lw) - c.ra

    return (altitude=altitude(hm, ϕ, c.dec),
        azimuth=azimuth(hm, ϕ, c.dec))
end


# Calculations for sun times
function julianCycle(d::Real, lw::Real)
    return round(d - 0.0009 - lw / 2π)
end

function approxTransit(ht::Union{Real,Missing}, lw::Real, n::Real)
    return 0.0009 + (ht + lw) / 2π + n
end

function solarTransitJ(ds::Union{Real,Missing}, m::Real, l::Real)
    J2000 = 2451545
    return J2000 + ds + 0.0053 * sin(m) - 0.0069 * sin(2 * l)
end

function hourAngle(h::Real, ϕ::Real, d::Real)
    tmp = (sin(h) - sin(ϕ) * sin(d)) / (cos(ϕ) * cos(d))
    return abs(tmp) <= 1 ? acos(tmp) : missing
end

# Return set time for the given sun altitude
function getSetJ(h::Real, lw::Real, ϕ::Real, dec::Real,
    n::Real, m::Real, l::Real)
    w = hourAngle(h, ϕ, dec)
    a = approxTransit(w, lw, n)
    return solarTransitJ(a, m, l)
end

# Calculate sun times for a given date and latitude/longitude
function getTimes(date::Date, lat::Real, lon::Real)

    rad = (π / 180)
    lw = rad * -lon
    ϕ = rad * lat

    d = toDays(date)
    n = julianCycle(d, lw)
    ds = approxTransit(0.0, lw, n)

    M = solarMeanAnomaly(ds)
    L = eclipticLongitude(M)
    dec = declination(L, 0.0)

    Jnoon = solarTransitJ(ds, M, L)

    result = (solarNoon=toDateTime(Jnoon),
        nadir=toDateTime(Jnoon - 0.5),
        sunrise=toDateTime(
            Jnoon - (getSetJ(-0.833 * rad, lw, ϕ, dec, n, M, L) - Jnoon)),
        sunset=toDateTime(getSetJ(-0.833 * rad, lw, ϕ, dec, n, M, L)),
        sunriseEnd=toDateTime(
            Jnoon - (getSetJ(-0.3 * rad, lw, ϕ, dec, n, M, L) - Jnoon)),
        sunsetStart=toDateTime(getSetJ(-0.3 * rad, lw, ϕ, dec, n, M, L)),
        dawn=toDateTime(Jnoon - (getSetJ(-6 * rad, lw, ϕ, dec, n, M, L) - Jnoon)),
        dusk=toDateTime(getSetJ(-6 * rad, lw, ϕ, dec, n, M, L)),
        nauticalDawn=toDateTime(
            Jnoon - (getSetJ(-12 * rad, lw, ϕ, dec, n, M, L) - Jnoon)),
        nauticalDusk=toDateTime(getSetJ(-12 * rad, lw, ϕ, dec, n, M, L)),
        nightEnd=toDateTime(
            Jnoon - (getSetJ(-18 * rad, lw, ϕ, dec, n, M, L) - Jnoon)),
        night=toDateTime(getSetJ(-18 * rad, lw, ϕ, dec, n, M, L)),
        goldenHourEnd=toDateTime(
            Jnoon - (getSetJ(6 * rad, lw, ϕ, dec, n, M, L) - Jnoon)),
        goldenHour=toDateTime(getSetJ(6 * rad, lw, ϕ, dec, n, M, L))
    )

    result = map(x -> ismissing(x) ? missing : round(x, Dates.Second), result)

    return result
end
