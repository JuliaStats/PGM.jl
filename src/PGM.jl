module PGM

import Base: ==, !=
import Base: eltype, ndims, size, length, show, keys, values
import Base: getindex, eachindex, start, next, done

export
    # classes
    ValueSpace,
    RealSpace,
    FiniteSpace,
    RangeSpace,
    Var,
    DVar,
    RVar,
    VarList,

    # functions
    indexof,
    dvar,
    rvar

include("variables.jl")

end # module
