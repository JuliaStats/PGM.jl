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
    JointPMF,

    # functions
    indexof,
    dvar,
    rvar,
    nvars,
    vars,
    probs,
    marginal_i,
    marginal

# sources

include("utils.jl")
include("variables.jl")
include("discrete/jointpmf.jl")

end # module
