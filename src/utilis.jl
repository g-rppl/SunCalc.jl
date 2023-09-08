
# Date/time conversions
J2000 = 2451545
toDays(date::Union{Date,DateTime}) = datetime2julian(DateTime(date)) - J2000
toDateTime(j::Union{Real,Missing}) = ismissing(j) ? missing : julian2datetime(j)


# General calculations for position
ϵ = (π / 180) * 23.4397  # Obliquity of the Earth
rightAscension(l::Real, b::Real) = atan(sin(l) * cos(ϵ) - tan(b) * sin(ϵ), cos(l))
declination(l::Real, b::Real) = asin(sin(b) * cos(ϵ) + cos(b) * sin(ϵ) * sin(l))

azimuth(hm::Real, ϕ::Real, dec::Real) = atan(sin(hm), cos(hm) * sin(ϕ) - tan(dec) * cos(ϕ))

function altitude(hm::Real, ϕ::Real, dec::Real)
    return asin(sin(ϕ) * sin(dec) + cos(ϕ) * cos(dec) * cos(hm))
end

siderealTime(d::Real, lw::Real) = (π / 180) * (280.16 + 360.9856235 * d) - lw

function astroRefraction(h::Real)
    # the following formula works for positive altitudes only.
    # if h = -0.08901179 a div/0 would occur.
    h = h < 0 ? 0 : h

    return 0.0002967 / tan(h + 0.00312536 / (h + 0.08901179))
end


# General sun calculations
solarMeanAnomaly(d::Real) = (π / 180) * (357.5291 + 0.98560028 * d)

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
function sunPosition(time::DateTime, lat::Real, lon::Real)
    lw = (π / 180) * -lon
    ϕ = (π / 180) * lat
    d = toDays(time)

    c = sunCoords(d)
    hm = siderealTime(d, lw) - c.ra

    return (altitude=altitude(hm, ϕ, c.dec), azimuth=azimuth(hm, ϕ, c.dec))
end


# Calculations for sun times
julianCycle(d::Real, lw::Real) = round(d - 0.0009 - lw / 2π)

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

# return set time for the given sun altitude
function getSetJ(h::Real, lw::Real, ϕ::Real, dec::Real, n::Real, m::Real, l::Real)
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


# Moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas

# geocentric ecliptic coordinates of the moon
function moonCoords(d::Real)
    l = (π / 180) * (218.316 + 13.176396 * d)  # ecliptic longitude
    m = (π / 180) * (134.963 + 13.064993 * d)  # mean anomaly
    f = (π / 180) * (93.272 + 13.229350 * d)  # mean distance

    l = l + (π / 180) * 6.289 * sin(m)  # longitude
    b = (π / 180) * 5.128 * sin(f)  # latitude
    dt = 385001 - 20905 * cos(m)  # distance to the moon in km

    return (
        ra=rightAscension(l, b),
        dec=declination(l, b),
        dist=dt)
end

function moonPosition(time::DateTime, lat::Real, lon::Real)

    lw = (π / 180) * -lon
    phi = (π / 180) * lat
    d = toDays(time)

    c = moonCoords(d)
    hm = siderealTime(d, lw) - c.ra
    h = altitude(hm, phi, c.dec)
    # formula 14.1 of "Astronomical Algorithms" 2nd edition by Jean meeus 
    # (Willmann-Bell, Richmond) 1998.
    pa = atan(sin(hm), tan(phi) * cos(c.dec) - sin(c.dec) * cos(hm))

    h = h + astroRefraction(h)  # altitude correction for refraction

    return (
        altitude=h,
        azimuth=azimuth(hm, phi, c.dec),
        distance=c.dist,
        parallacticAngle=pa)
end

# calculations for illumination parameters of the moon, based on
# http://idlastro.gsfc.nasa.gov/ftp/pro/astro/mphase.pro formulas and Chapter 48 of
# "Astronomical Algorithms" 2nd edition by Jean meeus (Willmann-Bell, Richmond) 1998.
function moonIllumination(time::DateTime)
    d = toDays(time)
    s = sunCoords(d)
    m = moonCoords(d)

    sdist = 149598000 # distance from Earth to Sun in km

    phi = acos(sin(s.dec) * sin(m.dec) + cos(s.dec) * cos(m.dec) * cos(s.ra - m.ra))
    inc = atan(sdist * sin(phi), m.dist - sdist * cos(phi))
    angle = atan(cos(s.dec) * sin(s.ra - m.ra), sin(s.dec) * cos(m.dec) -
                                                cos(s.dec) * sin(m.dec) * cos(s.ra - m.ra))


    return (
        fraction=((1 + cos(inc)) / 2),
        phase=(0.5 + 0.5 * inc * ifelse(angle < 0, -1, 1) / π),
        angle=angle)
end