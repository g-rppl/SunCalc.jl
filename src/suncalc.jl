module suncalc

using Dates
using TimeZones
using DataFrames

import Base: round
import Dates: julian2datetime
import TimeZones: ZonedDateTime, astimezone

include("utilis.jl")

include("sunlightTimes.jl")
export getSunlightTimes

end  # module